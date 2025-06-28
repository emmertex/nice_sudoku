extends Control

@onready var puzzle_input: LineEdit = $VBoxContainer/PuzzleInput
@onready var solve_button: Button = $VBoxContainer/SolveButton
@onready var result_output: LineEdit = $VBoxContainer/ResultOutput
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
			return true
			
	return false

func _get_grid_as_string(sudoku: Sudoku) -> String:
	var s = ""
	for r in range(9):
		for c in range(9):
			s += str(sudoku.grid[r][c])
	return s 
