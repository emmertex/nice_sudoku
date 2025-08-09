extends Control

@onready var puzzle_input: LineEdit = $VBoxContainer/PuzzleInput
@onready var solve_button: Button = $VBoxContainer/SolveButton
@onready var result_output: LineEdit = $VBoxContainer/ResultOutput
@onready var log_box: RichTextLabel = $VBoxContainer/LogBox
@onready var status_label: Label = $VBoxContainer/StatusLabel

const Sudoku = preload("res://sudoku_code.gd")
const Hint = preload("res://hint.gd")
const SudokuHintGenerator = preload("res://hint_generator.gd")

func _ready() -> void:
	solve_button.pressed.connect(self._on_solve_button_pressed)

func _on_solve_button_pressed() -> void:
	var puzzle_string: String = puzzle_input.text
	if puzzle_string.length() != 81:
		status_label.text = "Error: Invalid puzzle string. Must be 81 digits (0 or . for empty)."
		return

	puzzle_string = puzzle_string.replace(".", "0")

	status_label.text = "Solving..."
	result_output.text = ""
	if is_instance_valid(log_box):
		log_box.bbcode_enabled = true
		log_box.clear()

	var sudoku = Sudoku.new()
	sudoku.load_puzzle_from_string(puzzle_string)

	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku

	var applied_hint = true
	var iteration_limit = 100 # safety break
	var iterations = 0
	while applied_hint and iterations < iteration_limit:
		iterations += 1
		applied_hint = false
		if sudoku.sbrc_grid.is_complete():
			break
			
		var hints = hint_generator.get_hints()
		if hints.is_empty():
			break

		# Prioritize placement hints
		var best_hint = _find_best_hint(hints)

		if best_hint:
			if _apply_hint(sudoku, best_hint):
				applied_hint = true
	
	if sudoku.sbrc_grid.is_complete():
		status_label.text = "Solved! (in %d iterations)" % iterations
	else:
		status_label.text = "Could not fully solve. Stuck after %d iterations." % iterations

	result_output.text = _get_grid_as_string(sudoku)

func _find_best_hint(hints: Array[Hint]) -> Hint:
	# Priority 1: Single Candidate / Hidden Single (direct placement)
	for hint in hints:
		if hint.technique == Hint.HintTechnique.SINGLE_CANDIDATE or hint.technique == Hint.HintTechnique.HIDDEN_SINGLE:
			if hint.cells.size() == 1 and hint.numbers.size() == 1:
				return hint
	
	# Priority 2: Any other hint that provides eliminations
	for hint in hints:
		if not hint.elim_cells.is_empty():
			return hint
			
	return null

func _apply_hint(sudoku: Sudoku, hint: Hint) -> bool:
	# Case 1: Placement Hint
	if hint.cells.size() == 1 and hint.numbers.size() == 1 and hint.elim_cells.is_empty():
		var cell = hint.cells[0]
		var num = hint.numbers[0]
		if sudoku.grid[cell.x][cell.y] == 0:
			sudoku.set_number(cell.x, cell.y, num)
			_log_hint_applied(hint, true)
			return true
	
	# Case 2: Elimination Hint
	if not hint.elim_cells.is_empty() and not hint.elim_numbers.is_empty():
		var changed = false
		for cell in hint.elim_cells:
			for num in hint.elim_numbers:
				if not sudoku.has_exclude_mark(cell.x, cell.y, num):
					sudoku.set_exclude_mark(cell.x, cell.y, num, true)
					changed = true
		if changed:
			sudoku.sbrc_grid.update_grid(sudoku.grid) # Re-evaluate candidates
			# After updating, we need to manually remove the excluded ones
			# because update_grid doesn't know about exclude_bits
			for r in range(9):
				for c in range(9):
					var bits_to_exclude = sudoku.exclude_bits[r][c]
					if bits_to_exclude > 0:
						sudoku.sbrc_grid.candidates[r][c].data[0] &= ~bits_to_exclude
			_log_hint_applied(hint, false)
			return true
			
	return false

func _get_grid_as_string(sudoku: Sudoku) -> String:
	var s = ""
	for r in range(9):
		for c in range(9):
			s += str(sudoku.grid[r][c])
	return s 

func _log_hint_applied(hint: Hint, is_placement: bool) -> void:
	if not is_instance_valid(log_box):
		return
	var level: int = _difficulty_level(hint.technique)
	var color_hex: String = _level_color_hex(level)
	var line: String
	if is_placement:
		var cell := hint.cells[0]
		var num := hint.numbers[0]
		line = "%s: set %d at (%d,%d)" % [hint.title, num, cell.x + 1, cell.y + 1]
	else:
		var cells_str := _format_cells(hint.elim_cells)
		var nums_str := ", ".join(hint.elim_numbers.map(func(n): return str(n)))
		line = "%s: eliminate %s from %s" % [hint.title, nums_str, cells_str]
	log_box.append_text("[color=%s]%s[/color]\n" % [color_hex, line])
	log_box.scroll_to_line(log_box.get_line_count() - 1)

func _format_cells(cells: Array[Vector2i]) -> String:
	return ", ".join(cells.map(func(c): return "(%d,%d)" % [c.x + 1, c.y + 1]))

func _difficulty_level(tech: int) -> int:
	# 1 (green) simple -> 5 (red) advanced
	match tech:
		Hint.HintTechnique.SINGLE_CANDIDATE, Hint.HintTechnique.HIDDEN_SINGLE:
			return 1
		Hint.HintTechnique.NAKED_PAIR_ROW, Hint.HintTechnique.NAKED_PAIR_COL, Hint.HintTechnique.NAKED_PAIR_BOX, Hint.HintTechnique.POINTING_PAIR, Hint.HintTechnique.BOX_LINE_REDUCTION:
			return 2
		Hint.HintTechnique.NAKED_TRIPLE_ROW, Hint.HintTechnique.NAKED_TRIPLE_COL, Hint.HintTechnique.NAKED_TRIPLE_BOX, Hint.HintTechnique.NAKED_QUAD_ROW, Hint.HintTechnique.NAKED_QUAD_COL, Hint.HintTechnique.NAKED_QUAD_BOX, Hint.HintTechnique.SIMPLE_COLORING, Hint.HintTechnique.X_WING_ROW, Hint.HintTechnique.X_WING_COL:
			return 3
		Hint.HintTechnique.SWORDFISH_ROW, Hint.HintTechnique.SWORDFISH_COL, Hint.HintTechnique.XY_CHAIN, Hint.HintTechnique.W_WING:
			return 4
		Hint.HintTechnique.JELLYFISH_ROW, Hint.HintTechnique.JELLYFISH_COL, Hint.HintTechnique.AIC_CHAIN, Hint.HintTechnique.NISHIO:
			return 5
		_:
			return 3

func _level_color_hex(level: int) -> String:
	match level:
		1:
			return "#4CAF50" # green
		2:
			return "#9CCC65" # yellow-green
		3:
			return "#FFC107" # amber
		4:
			return "#FF7043" # deep orange
		5:
			return "#E53935" # red
		_:
			return "#FFFFFF"
