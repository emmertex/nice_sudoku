extends Control

# Constants
const CLR_BOARD = Color(0.21, 0.21, 0.21)
const CLR_BOARD2 = Color(0.26, 0.26, 0.26)
const CLR_GIVEN = Color(0.1, 0.3, 0.4, 0.8)
const CLR_SELECT = Color(0.13, 0.4, 0.65, 0.8)
const CLR_HOVER = Color(0.13, 0.4, 0.65, 0.4)
const CLR_SAME = Color(0.13, 0.4, 0.55, 0.8)
const CLR_PLUS = Color(0.25, 0.35, 0.6, 0.8)
const CLR_BLOCK = Color(0.2, 0.3, 0.55, 0.8)
const CLR_ROW = Color(0.2, 0.3, 0.55, 0.8)
const CLR_BLOCKED = Color(0.2, 0.3, 0.55, 0.8)
const CLR_BACKGROUND = Color(0.1, 0.1, 0.1)
const CLR_PENCIL = Color(0.95, 0.95, 0.95)
const CLR_PENCIL_HIGHLIGHT = Color(0.3, 1.0, 0.3)
const CLR_PENCIL_EXCLUDE = Color(1.00, 0.3, 0.3)
const CLR_HINT_AFFECTED = Color.PALE_GREEN

const SAVE_STATE_PATH = "user://save_state.cfg"
const Hint = preload("res://hint.gd")

# Enums
enum HighlightMode { NUM, NRC, NRCB, ALL, ALLC }
enum Mode { NUMBER, NUMBER_CLR, PENCIL, PENCIL_EXCLUDE }

# Variables
var sudoku: Sudoku
var hint_generator: SudokuHintGenerator
var selected_cell: Vector2 = Vector2(-1, -1)
var selected_num = 0
var highlight_mode: HighlightMode = HighlightMode.ALLC
var mode: Mode = Mode.NUMBER
var viewport_size: Vector2
var orientation: bool = true
var vertical_aspect_ratio: float = 1/(1.638)
var current_aspect_ratio: float = 1
var button_size: int = 70
var font_size: int = 10
var timer_running: bool = false
var permissions_requested = false
var _pending_updates: Array = []
var _update_timer: Timer
var current_hint: Hint = null

# Onready variables
@onready var number_buttons = $Panel/AspectRatioContainer/VBoxContainer/NumberButtons
@onready var grid_container = $Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid/AspectRatioContainer/GridContainer
@onready var puzzle_info = $Panel/AspectRatioContainer/VBoxContainer/PuzzleInfo
@onready var highlight_button = $Panel/AspectRatioContainer/VBoxContainer/MenuLayer2/HighlightButton
@onready var game_timer_text = $Panel/AspectRatioContainer/VBoxContainer/MenuLayer1/Timer
@onready var menu_layer1 = $Panel/AspectRatioContainer/VBoxContainer/MenuLayer1
@onready var menu_layer2 = $Panel/AspectRatioContainer/VBoxContainer/MenuLayer2
@onready var aspect_container = $Panel/AspectRatioContainer/ColorRect2

func _ready():
	await get_tree().process_frame
	_initialize()
	_setup_ui()
	_connect_signals()
	_setup_update_batching()
	if !load_game_state():
		_load_initial_puzzle()

func _initialize():
	sudoku = Sudoku.new()
	hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku
	$ColorRect.color = CLR_BACKGROUND
	
func _setup_ui():
	_create_grid()
	_setup_number_buttons()
	_update_highlight_button_text()
	update_ui()

func update_ui():
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")
	queue_update("info")

func _setup_update_batching():
	_update_timer = Timer.new()
	_update_timer.wait_time = 0.016  # ~60 FPS
	_update_timer.timeout.connect(_process_pending_updates)
	add_child(_update_timer)
	_update_timer.start()

func queue_update(update_type: String):
	if not _pending_updates.has(update_type):
		_pending_updates.append(update_type)

func _process_pending_updates():
	if _pending_updates.is_empty():
		return

	for update_type in _pending_updates:
		match update_type:
			"grid": _update_grid()
			"buttons": _update_buttons()
			"pencil": _update_pencil()
			"highlights": _update_grid_highlights()
			"info": update_puzzle_info()

	_pending_updates.clear()

func _load_initial_puzzle():
	load_puzzle(0, "easy")
	_on_viewport_size_changed()

func _update_grid():
	for row in range(9):
		for col in range(9):
			var button = grid_container.get_child(row * 9 + col)
			var number = sudoku.grid[row][col]
			button.text = str(number) if number != 0 else ""
			if sudoku.is_given_number(row, col):
				button.add_theme_color_override("font_color", Color.GRAY)
			else:
				button.add_theme_color_override("font_color", Color.WHITE)
	if sudoku.is_completed():
		timer_running = false
		save_completed_puzzle()
		show_puzzle_done_popup()

func _create_pencil_marks(container: Control):
	for i in range(3):
		for j in range(3):
			var label = Label.new()
			label.position = Vector2(i * (button_size / 3), j * (button_size / 3))  # Position the label
			label.size = Vector2(button_size / 3, button_size / 3)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.add_theme_color_override("font_color", CLR_PENCIL)  # Use add_theme_color_override
			container.add_child(label)

func _create_grid():
	grid_container.columns = 9
	grid_container.add_theme_constant_override("hseparation", 0)
	grid_container.add_theme_constant_override("vseparation", 0)

	for row in range(9):
		for col in range(9):
			var button = Button.new()
		   
			var pencil_marks_container = Control.new()
			pencil_marks_container.set_custom_minimum_size (Vector2(button_size, button_size))
			pencil_marks_container.mouse_filter = Control.MOUSE_FILTER_PASS
			button.add_child(pencil_marks_container)
			_create_pencil_marks(pencil_marks_container)
		   
			button.set_custom_minimum_size(Vector2(button_size, button_size))
			button.add_theme_font_size_override("font_size", button_size * 0.5)
			var hover_style = StyleBoxFlat.new()
			hover_style.set_bg_color(CLR_HOVER)
			button.add_theme_stylebox_override("hover", hover_style)
			button.pressed.connect(_on_cell_pressed.bind(row, col))
		   
			# Add thicker borders for 3x3 subgrids
			var style = StyleBoxFlat.new()
			if ((col * 9) + row) % 2 == 0:
				style.set_bg_color(CLR_BOARD)
			else:
				style.set_bg_color(CLR_BOARD2)
			style.set_border_width_all(0)
			style.set_border_color(Color.BLACK)
		   
			if col % 3 == 0:
				style.set_border_width(SIDE_LEFT, 5)
			if col % 3 == 2:
				style.set_border_width(SIDE_RIGHT, 5)
			if row % 3 == 0:
				style.set_border_width(SIDE_TOP, 5)
			if row % 3 == 2:
				style.set_border_width(SIDE_BOTTOM, 5)
			if (col % 3 == 0) && (row % 3 == 2):
				grid_container.add_theme_constant_override("hseparation", 3)
				grid_container.add_theme_constant_override("vseparation", 3)
			button.add_theme_stylebox_override("normal", style)
			grid_container.add_child(button)

func _setup_number_buttons():
	for i in range(1, 13):
		var button = number_buttons.get_node("Button" + str(i))
		button.set_custom_minimum_size(Vector2(button_size,button_size))
		button.add_theme_font_size_override("font_size", button_size * 0.5)
		var hover_style = StyleBoxFlat.new()
		hover_style.set_bg_color(CLR_HOVER)
		button.add_theme_stylebox_override("hover", hover_style)
		if i < 10:
			button.set_text(str(i))
			button.pressed.connect(_on_number_button_pressed.bind(i))
	   

func _on_cell_pressed(row: int, col: int):
	if selected_cell == Vector2(row, col):
		selected_cell = Vector2(-1, -1)
		_update_grid_highlights()
		return
	selected_cell = Vector2(row, col)
	if mode == Mode.NUMBER_CLR:
		if !sudoku.is_given_number(row, col):
			sudoku.clear_number(row, col)
			selected_cell = Vector2(-1, -1)

	if mode == Mode.NUMBER:
		if sudoku.grid[row][col] == 0:
			if selected_num != 0:
				sudoku.set_number(row, col, selected_num)
				selected_cell = Vector2(-1, -1)
		else:
			selected_num = sudoku.grid[row][col]

	if mode == Mode.PENCIL:
		if sudoku.grid[row][col] == 0:
			sudoku.swap_pencil(row, col, selected_num)
		selected_cell = Vector2(-1, -1)
	if mode == Mode.PENCIL_EXCLUDE:
		if sudoku.grid[row][col] == 0:
			sudoku.swap_exclude(row, col, selected_num)
		selected_cell = Vector2(-1, -1)
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")

func _update_pencil():
	for row in range(9):
		for col in range(9):
			for num_idx in range(9):
				var num = num_idx + 1
				var pencil_button = grid_container.get_child(row * 9 + col).get_child(0).get_child(num_idx)
				
				# Skip updating colors if this pencil mark is part of a hint elimination
				if current_hint and current_hint.elim_cells.has(Vector2i(row, col)) and current_hint.elim_numbers.has(num):
					continue
				
				var pencil = sudoku.has_pencil_mark(row, col, num)
				var exclude = sudoku.has_exclude_mark(row, col, num)
				
				if exclude:
					pencil_button.text = str(Cardinals.PencilN[num_idx])
					pencil_button.add_theme_color_override("font_color", CLR_PENCIL_EXCLUDE)
				elif pencil:
					pencil_button.text = str(Cardinals.PencilN[num_idx])
					pencil_button.add_theme_color_override("font_color", CLR_PENCIL)
				else:
					pencil_button.text = ""

func _on_number_button_pressed(number: int):
	if number > 0:
		if mode == Mode.NUMBER_CLR:
			mode = Mode.NUMBER
			selected_num = number
			selected_cell = Vector2(-1,-1)
			queue_update("buttons")
			return
	if selected_num == number:
		if mode == Mode.NUMBER:
			mode = Mode.PENCIL
	selected_num = number
	if selected_cell.x >= 0 and selected_cell.y >= 0:
		if mode == Mode.NUMBER:
			selected_cell = Vector2(-1,-1)
		selected_num = 0
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")
	update_ui()

func _update_buttons():
	var needed = sudoku.get_needed_numbers()
	for i in range(0, 9):
		var button = number_buttons.get_node("Button" + str(i+1))
		var style = StyleBoxFlat.new()
		if !needed[i]:
			button.disabled = true
			style.bg_color = CLR_BACKGROUND
			button.add_theme_color_override("font_color", Color.GRAY)
			continue
		else:
			button.disabled = false

		if selected_num == i + 1:
			style.bg_color = CLR_SELECT
			button.add_theme_color_override("font_color", Color.WHITE)
			button.add_theme_stylebox_override("normal", style)
			continue
		else:
			if (sudoku.is_valid_move(selected_cell.x, selected_cell.y, i+1) || \
					selected_cell.x < 0 || selected_cell.y < 0) && \
					!sudoku.is_given_number(selected_cell.x, selected_cell.y):
				button.add_theme_color_override("font_color", Color.WHITE)
				style.bg_color = CLR_BOARD2
			else:
				button.add_theme_color_override("font_color", Color.WHITE)
				style.bg_color = CLR_BACKGROUND
			button.add_theme_stylebox_override("normal", style)
   
	for i in range(10, 13):
		var button = number_buttons.get_node("Button" + str(i))
		var style = StyleBoxFlat.new()
		button.add_theme_color_override("font_color", Color.WHITE)
		style.bg_color = CLR_BACKGROUND
		if mode == Mode.NUMBER_CLR && i == 10:
			style.bg_color = CLR_SELECT
		if mode == Mode.PENCIL && i == 11:
			style.bg_color = CLR_SELECT
		if mode == Mode.PENCIL_EXCLUDE && i == 12:
			style.bg_color = CLR_SELECT
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)

func _update_grid_highlights():
	var row_data = sudoku.sbrc_grid.row_data
	var col_data = sudoku.sbrc_grid.col_data
	var box_data = sudoku.sbrc_grid.box_data
	# 1. Clear all highlights
	for row in range(9):
		for col in range(9):
			var button = grid_container.get_child(row * 9 + col)
			var style = button.get_theme_stylebox("normal").duplicate()
			if sudoku.is_given_number(row, col):
				style.set_bg_color(CLR_GIVEN)
			elif sudoku.grid[row][col] == 0:
				if ((col * 9) + row) % 2 == 0:
					style.set_bg_color(CLR_BOARD)
				else:
					style.set_bg_color(CLR_BOARD2)
			else:
				style.set_bg_color(CLR_BLOCKED)
			button.add_theme_stylebox_override("normal", style)

	# 2. Highlight selected cell
	if selected_cell.x >= 0 and selected_cell.y >= 0:
		var button = grid_container.get_child(selected_cell.x * 9 + selected_cell.y)
		var style = button.get_theme_stylebox("normal").duplicate()
		style.set_bg_color(CLR_SELECT)
		button.add_theme_stylebox_override("normal", style)

	# 3. Highlight logic by mode
	var highlight_number = selected_num
	if highlight_number == 0 and selected_cell.x >= 0 and selected_cell.y >= 0:
		highlight_number = sudoku.grid[selected_cell.x][selected_cell.y]

	if (highlight_mode == HighlightMode.ALL or highlight_mode == HighlightMode.ALLC) and highlight_number != 0:
		for row in range(9):
			for col in range(9):
				if sudoku.grid[row][col] == highlight_number:
					# Highlight Block
					var block_row = int(row / 3) * 3
					var block_col = int(col / 3) * 3
					for r in range(block_row, block_row + 3):
						for c in range(block_col, block_col + 3):
							var block_button = grid_container.get_child(r * 9 + c)
							var block_style = block_button.get_theme_stylebox("normal").duplicate()
							block_style.set_bg_color(CLR_BLOCK)
							block_button.add_theme_stylebox_override("normal", block_style)
		for row in range(9):
			for col in range(9):
				if sudoku.grid[row][col] == highlight_number:
					# Highlight Row
					for c in range(9):
						var row_button = grid_container.get_child(row * 9 + c)
						var row_style = row_button.get_theme_stylebox("normal").duplicate()
						row_style.set_bg_color(CLR_PLUS)
						row_button.add_theme_stylebox_override("normal", row_style)
					# Highlight Column
					for r in range(9):
						var col_button = grid_container.get_child(r * 9 + col)
						var col_style = col_button.get_theme_stylebox("normal").duplicate()
						col_style.set_bg_color(CLR_PLUS)
						col_button.add_theme_stylebox_override("normal", col_style)
		for row in range(9):
			for col in range(9):
				# Highlight Exclude
				if sudoku.has_exclude_mark(row, col, highlight_number):
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					style.set_bg_color(CLR_BLOCK)
					button.add_theme_stylebox_override("normal", style)
				if sudoku.get_grid_value(row, col) > 0:
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					if sudoku.get_grid_given(row, col):
						style.set_bg_color(CLR_GIVEN)
					else:
						style.set_bg_color(CLR_BLOCKED)
					button.add_theme_stylebox_override("normal", style)
				if sudoku.grid[row][col] == highlight_number:
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					style.set_bg_color(CLR_SAME)
					button.add_theme_stylebox_override("normal", style)

	# Restore NUM, NRC, NRCB highlight logic
	elif highlight_mode == HighlightMode.NUM and highlight_number != 0:
		# Highlight all cells with the same number as selected cell
		for row in range(9):
			for col in range(9):
				if sudoku.grid[row][col] == highlight_number:
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					style.set_bg_color(CLR_SAME)
					button.add_theme_stylebox_override("normal", style)
	elif highlight_mode == HighlightMode.NRC and selected_cell.x >= 0 and selected_cell.y >= 0:
		# Highlight row and column of selected cell
		for i in range(9):
			var row_button = grid_container.get_child(selected_cell.x * 9 + i)
			var col_button = grid_container.get_child(i * 9 + selected_cell.y)
			var row_style = row_button.get_theme_stylebox("normal").duplicate()
			var col_style = col_button.get_theme_stylebox("normal").duplicate()
			row_style.set_bg_color(CLR_PLUS)
			col_style.set_bg_color(CLR_PLUS)
			row_button.add_theme_stylebox_override("normal", row_style)
			col_button.add_theme_stylebox_override("normal", col_style)
	elif highlight_mode == HighlightMode.NRCB and selected_cell.x >= 0 and selected_cell.y >= 0:
		# Highlight row, column, and block of selected cell
		for i in range(9):
			var row_button = grid_container.get_child(selected_cell.x * 9 + i)
			var col_button = grid_container.get_child(i * 9 + selected_cell.y)
			var row_style = row_button.get_theme_stylebox("normal").duplicate()
			var col_style = col_button.get_theme_stylebox("normal").duplicate()
			row_style.set_bg_color(CLR_PLUS)
			col_style.set_bg_color(CLR_PLUS)
			row_button.add_theme_stylebox_override("normal", row_style)
			col_button.add_theme_stylebox_override("normal", col_style)
		# Highlight block
		var block_row = int(selected_cell.x / 3) * 3
		var block_col = int(selected_cell.y / 3) * 3
		for r in range(block_row, block_row + 3):
			for c in range(block_col, block_col + 3):
				var block_button = grid_container.get_child(r * 9 + c)
				var block_style = block_button.get_theme_stylebox("normal").duplicate()
				block_style.set_bg_color(CLR_BLOCK)
				block_button.add_theme_stylebox_override("normal", block_style)

	if current_hint:
		highlight_hint(current_hint)

func _on_HintButton_pressed():
	current_hint = null # Clear previous hint
	update_ui() # Update to clear old highlights
	
	var hints = hint_generator.get_hints()
	var hint_popup = preload("res://hint_popup.tscn").instantiate()
	add_child(hint_popup)
	hint_popup.set_hints(hints)
	hint_popup.popup_centered()
	
	hint_popup.connect("hint_selected", self._on_hint_selected)
	hint_popup.connect("next_hint_requested", self._on_hint_selected)
	hint_popup.connect("hint_dismissed", self._on_hint_dismissed)

func _on_hint_selected(hint: Hint):
	current_hint = hint
	update_ui()

func _on_hint_dismissed():
	current_hint = null
	update_ui()

func highlight_hint(hint: Hint):
	# Highlight primary cells
	for cell in hint.cells:
		var button = grid_container.get_child(cell.x * 9 + cell.y)
		var style = button.get_theme_stylebox("normal").duplicate()
		style.set_bg_color(Color.PALE_VIOLET_RED)
		button.add_theme_stylebox_override("normal", style)
	
	# Highlight elimination cells and their specific pencil marks
	for cell in hint.elim_cells:
		var button = grid_container.get_child(cell.x * 9 + cell.y)
		var style = button.get_theme_stylebox("normal").duplicate()
		style.set_bg_color(CLR_HINT_AFFECTED)
		button.add_theme_stylebox_override("normal", style)
		
		var pencil_container = button.get_child(0)
		for num in hint.elim_numbers:
			# Check if this pencil mark actually exists before highlighting
			if sudoku.has_pencil_mark(cell.x, cell.y, num):
				var pencil_label = pencil_container.get_child(num - 1)
				pencil_label.add_theme_color_override("font_color", Color.ORANGE_RED)

func _on_NewGameButton_pressed():
	show_puzzle_selection_popup()

func show_puzzle_selection_popup():
	var popup = PopupPanel.new()
	var window_size = get_viewport().get_visible_rect().size
	popup.set_size(Vector2((min(window_size.y, window_size.x)) * 0.8, window_size.y * 0.8))
	popup.name = "PuzzleSelectionPopup"
	add_child(popup)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.add_child(vbox)

	var difficulty_options = OptionButton.new()
	for difficulty in sudoku.puzzles.keys():
		difficulty_options.add_item(difficulty.capitalize())
	difficulty_options.add_theme_font_size_override("font_size", button_size * 0.6)
	difficulty_options.get_popup().add_theme_font_size_override("font_size", button_size * 0.6)
	difficulty_options.selected = sudoku.difficulty_index[sudoku.puzzle_selected]
	vbox.add_child(difficulty_options)

	var scroll_container = ScrollContainer.new()
	scroll_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	scroll_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	vbox.add_child(scroll_container)

	var puzzle_list = VBoxContainer.new()
	puzzle_list.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	scroll_container.add_child(puzzle_list)

	difficulty_options.connect("item_selected", self._on_difficulty_selected.bind(puzzle_list))
	_on_difficulty_selected(sudoku.difficulty_index[sudoku.puzzle_selected], puzzle_list)

	popup.popup_centered()

func _on_difficulty_selected(index: int, puzzle_list: VBoxContainer):
	var difficulty = sudoku.puzzles.keys()[index]
	var window_size = get_viewport().get_visible_rect().size
	print("Selected difficulty:", difficulty)
	print("Window size:", window_size)

	# Clear existing children
	for child in puzzle_list.get_children():
		child.queue_free()

	var completed_puzzles = _load_completed_puzzles(difficulty)

	print("Number of puzzles:", sudoku.get_puzzle_count())
	sudoku.load_puzzle_data(difficulty)
	sudoku.fast_load_save_states(SAVE_STATE_PATH)

	var min_width = min(window_size.y, window_size.x) * 0.75
	print("Calculated min_width:", min_width)

	for i in range(sudoku.get_puzzle_count()-1):
		var puzzle_data = sudoku.get_puzzle_data(i)
		if puzzle_data:
			var puzzle_row = preload("res://loadListItem.tscn").instantiate()
			puzzle_row.custom_minimum_size = Vector2(min_width, 0)
			puzzle_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			# Update labels
			_set_label_text(puzzle_row, "Index", str(i+1))
			_set_label_text(puzzle_row, "Difficulty", puzzle_data["difficulty"])
			
			var completed_time = ""
			if completed_puzzles.has(i):
				completed_time = _format_time(completed_puzzles[i])
			_set_label_text(puzzle_row, "Time", completed_time)
			
			# Connect buttons
			_connect_button(puzzle_row, "Res", self._on_resume_button_pressed.bind(difficulty, i), i, difficulty)
			_connect_button(puzzle_row, "New", self._on_load_puzzle_pressed.bind(difficulty, i), i, difficulty)
			
			puzzle_list.add_child(puzzle_row)

	# Force layout update
	puzzle_list.queue_sort()
	
	# Add a yield to allow the GUI to update
	await get_tree().process_frame
	
	# Print the size of the first child for debugging
	if puzzle_list.get_child_count() > 0:
		print("First child size:", puzzle_list.get_child(0).size)

	# Ensure the ScrollContainer updates its scroll size
	var scroll_container = puzzle_list.get_parent()
	if scroll_container is ScrollContainer:
		scroll_container.queue_sort()

# Helper function to set label text
func _set_label_text(parent: Node, label_name: String, text: String):
	var label = parent.find_child(label_name)
	if label and (label is Label or label is TextEdit):
		label.text = text
	else:
		print("Warning: Label '%s' not found or not a Label node" % label_name)

# Helper function to connect button signals
func _connect_button(parent: Node, button_name: String, callback: Callable, index: int, difficulty: String):
	var button = parent.find_child(button_name)
	if button and button is BaseButton:
		button.pressed.connect(callback)
	else:
		print("Warning: Button '%s' not found or not a button node" % button_name)
	if (not sudoku.has_save_state(difficulty, index)) && button_name == "Res":
		button.disabled = true

func _create_label(text: String, is_header: bool = false) -> Label:
	var font_size = button_size * 0.375
	var label = Label.new()
	label.text = text
	label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	label.set_custom_minimum_size(Vector2(100, 30))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	if is_header:
		label.add_theme_color_override("font_color", Color.YELLOW)
	return label

func _load_completed_puzzles(difficulty: String) -> Dictionary:
	print("Loading completed puzzles for difficulty:", difficulty)
	var config = ConfigFile.new()
	var file_path = "user://" + difficulty + ".cfg"
	if config.load(file_path) == OK:
		var completed_puzzles = config.get_value("completed", "puzzles", [])
		var result = {}
		for puzzle in completed_puzzles:
			result[puzzle.current_puzzle_index] = puzzle.puzzle_time
		return result
	return {}

func _format_time(seconds: int) -> String:
	var minutes = seconds / 60
	seconds = seconds % 60
	return "%d:%02d" % [minutes, seconds]

func _on_load_puzzle_pressed(difficulty: String, index: int):
	sudoku.puzzle_selected = difficulty
	load_puzzle(index, difficulty)
	selected_cell = Vector2(-1, -1)
	selected_num = 0
	timer_running = true
	sudoku.puzzle_time = 0
	current_hint = null
	var popup = get_node_or_null("PuzzleSelectionPopup")
	if popup:
		popup.queue_free()
	else:
		print("PuzzleSelectionPopup not found, it may have been already closed.")
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")
	queue_update("info")

func _on_resume_button_pressed(difficulty: String, index: int):
	print("Loading state for difficulty: " + difficulty + " and index: " + str(index))
	sudoku.load_state(SAVE_STATE_PATH, difficulty, index)
	timer_running = true
	var popup = get_node_or_null("PuzzleSelectionPopup")
	if popup:
		popup.queue_free()
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")
	queue_update("info")

func _on_LoadPuzzleButton_pressed():
	load_puzzle(sudoku.current_puzzle_index+1, sudoku.puzzle_selected)
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")
	queue_update("info")

func _on_puzzle_file_selected(path):
	if sudoku.puzzle_file(path):
		selected_cell = Vector2(-1, -1)
		selected_num = 0
		timer_running = true
		sudoku.puzzle_time = 0
		queue_update("grid")
		queue_update("buttons")
		queue_update("pencil")
		queue_update("highlights")
		queue_update("info")
	else:
		print("Failed to load puzzle from file")

func _request_permissions():
	if OS.get_name() == "Android" and not permissions_requested:
		permissions_requested = true
		var permissions = OS.get_granted_permissions()
		if not "android.permission.READ_EXTERNAL_STORAGE" in permissions or not "android.permission.WRITE_EXTERNAL_STORAGE" in permissions:
			OS.request_permissions()

func _on_button_c_pressed():
	if mode == Mode.NUMBER_CLR:
		mode = Mode.NUMBER
	else:
		mode = Mode.NUMBER_CLR
	selected_cell = Vector2(-1,-1)
	selected_num = 0
	queue_update("buttons")

func _on_button_p_pressed():
	if mode == Mode.PENCIL:
		mode = Mode.NUMBER
	else:
		mode = Mode.PENCIL
	queue_update("buttons")

func _on_button_pc_pressed():
	if mode == Mode.PENCIL_EXCLUDE:
		mode = Mode.NUMBER
	else:
		mode = Mode.PENCIL_EXCLUDE
	queue_update("buttons")
	
func _on_UndoButton_pressed():
	selected_cell = Vector2(-1,-1)
	selected_num = 0
	sudoku.undo_history()
	current_hint = null
	update_ui()

func _on_timer_timeout():
	if timer_running:
		sudoku.puzzle_time += 1
		var minimum = int(sudoku.puzzle_time / 60)
		var sec = sudoku.puzzle_time % 60
		var str_sec = "00"
		if sec < 10:
			str_sec = "0" + str(sec)
		else:
			str_sec = str(sec)
		game_timer_text.text = str(minimum) + ":" + str_sec + "s"

		# Auto-save every minute
		if sudoku.puzzle_time % 10 == 0:
			save_game_state()

func _input(event):
	if event is InputEventKey and event.pressed:
		var key = event.as_text()
		if key >= "1" and key <= "9":
			_on_number_button_pressed(int(key))
	if event.is_action_pressed("0"):
		_on_number_button_pressed(0)
	if event.is_action_pressed("clear"):
		_on_button_c_pressed()
	if event.is_action_pressed("pencil"):
		_on_button_p_pressed()
	if event.is_action_pressed("clearpencil"):
		_on_button_pc_pressed()
	if event.is_action_pressed("undo"):
		_on_UndoButton_pressed()

func _on_AutoP_pressed():
	sudoku.auto_fill_pencil_marks()
	queue_update("pencil")
	queue_update("highlights")

func _on_highlight_button_pressed():
	highlight_mode = HighlightMode.values()[(int(highlight_mode) + 1) % HighlightMode.size()]
	_update_highlight_button_text()
	queue_update("highlights")

func _update_highlight_button_text():
	match highlight_mode:
		HighlightMode.NUM:
			highlight_button.text = "Num"
		HighlightMode.NRC:
			highlight_button.text = "RC"
		HighlightMode.NRCB:
			highlight_button.text = "RCB"
		HighlightMode.ALL:
			highlight_button.text = "ALL"
		HighlightMode.ALLC:
			highlight_button.text = "ALLC"

func _on_window_focus_in():
	timer_running = true
	print("Window focus in")

func _on_window_focus_out():
	timer_running = false
	print("Window focus out")
	save_game_state()

func _on_paste_puzzle_button_pressed():
	var pastePanel = preload("res://paste.tscn").instantiate()
	var dimensions = get_viewport().get_visible_rect().size
	pastePanel.size = Vector2(dimensions.x * 0.8, dimensions.y * 0.8)
	pastePanel.popup_centered()
	add_child(pastePanel)

	var loadInput = pastePanel.find_child("LoadBox")
	_connect_generic_button(pastePanel, "LoadButton", self._on_load_button_pressed.bind(loadInput, pastePanel))
	_connect_generic_button(pastePanel, "CloseButton", self._on_close_paste_panel.bind(pastePanel))
	var given = ""
	var puzzle = ""
	var p891 = ""
	for i in range(81):
		given += str(sudoku.original_grid[i/9][i%9])
		puzzle += str(sudoku.grid[i/9][i%9])
	p891 = puzzle
	for i in range(81):
		for j in range(9):
			if (sudoku.has_exclude_mark(i/9, i%9, j+1)):
				p891 += "2"
			elif (sudoku.has_pencil_mark(i/9, i%9, j+1)):
				p891 += "1"
			else:
				p891 += "0"
	_set_label_text(pastePanel, "Game81Given", given)
	_set_label_text(pastePanel, "Game81State", puzzle)
	_set_label_text(pastePanel, "Game891", p891)
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")
	queue_update("info")

func _on_close_paste_panel(popup):
	popup.queue_free()

func _connect_generic_button(parent: Node, button_name: String, callback: Callable):
	var button = parent.find_child(button_name)
	if button and button is BaseButton:
		button.pressed.connect(callback)
	else:
		print("Warning: Button '%s' not found or not a button node" % button_name)

func _on_load_button_pressed(text_input, popup):
	var input_text = text_input.text.strip_edges()
	if sudoku.load_puzzle_from_string(input_text):
		selected_cell = Vector2(-1, -1)
		timer_running = true
		sudoku.puzzle_time = 0
		popup.hide()
		queue_update("grid")
		queue_update("buttons")
		queue_update("pencil")
		queue_update("highlights")
		queue_update("info")
	else:
		print("Invalid input.")

func _on_viewport_size_changed():
	viewport_size = get_viewport().get_visible_rect().size

	# Calculate button size based on available space
	var available_width = min(viewport_size.x, viewport_size.y * 1.2)
	var available_height = min(viewport_size.y, viewport_size.x / 1.2)
	
	if orientation:
		# Vertical layout: prioritize height, use width for number buttons
		button_size = int(min(available_height / 15, available_width / 8))
	else:
		# Horizontal layout: prioritize width
		button_size = int(min(available_width / 15, available_height / 8))
	
	# Ensure minimum button size
	button_size = max(button_size, 20)
	
	# Check if orientation changed
	if orientation != _get_orientation():
		orientation = _get_orientation()
		_adjust_number_buttons_layout()
	
	_resize_number_buttons()
	_resize_menu_buttons()
	_resize_grid_buttons()
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")
	queue_update("info")

func _get_orientation():
	return viewport_size.x < viewport_size.y / 1.2

func _adjust_number_buttons_layout():
	if orientation:
		# For vertical layout, move NumberButtons to VBoxContainer
		if number_buttons.get_parent() != $Panel/AspectRatioContainer/VBoxContainer:
			number_buttons.get_parent().remove_child(number_buttons)
			$Panel/AspectRatioContainer/VBoxContainer.add_child(number_buttons)
		number_buttons.columns = 6
		$Panel/AspectRatioContainer.ratio = vertical_aspect_ratio
		current_aspect_ratio = vertical_aspect_ratio
	else:
		# For horizontal layout, move NumberButtons to HBoxContainerGrid
		if number_buttons.get_parent() != $Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid:
			number_buttons.get_parent().remove_child(number_buttons)
			$Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid.add_child(number_buttons)
		number_buttons.columns = 2
		$Panel/AspectRatioContainer.ratio = 1
		current_aspect_ratio = 1

func _resize_number_buttons():
	for button in number_buttons.get_children():
		button.set_custom_minimum_size(Vector2(button_size*(1.5), button_size*(1.5)))
		button.add_theme_font_size_override("font_size", button_size*0.75)

func _resize_menu_buttons():
	for layer in [menu_layer1, menu_layer2]:
		for child in layer.get_children():

			child.set_custom_minimum_size(Vector2(aspect_container.size.x/4.2, button_size))
			child.add_theme_font_size_override("font_size", button_size*.375)
	
	puzzle_info.set_custom_minimum_size(Vector2(aspect_container.size.x/1.5, button_size*.75))
	puzzle_info.add_theme_font_size_override("font_size", button_size*.375)

func _resize_grid_buttons():
	for row in range(9):
		for col in range(9):
			var grid_button = grid_container.get_child(row * 9 + col)
			var pencil_container = grid_button.get_child(0)
			grid_button.set_custom_minimum_size(Vector2(button_size, button_size))
			pencil_container.set_custom_minimum_size(Vector2(button_size, button_size))
			grid_button.add_theme_font_size_override("font_size", button_size * 0.5)
			_resize_pencil_cells(pencil_container)

func _resize_pencil_cells(pencil_container):
	for pencil in range(9):
		var pencil_cell = pencil_container.get_child(pencil)
		pencil_cell.position = Vector2((pencil%3) * (button_size / 3), (pencil/3) * (button_size / 3))
		pencil_cell.size = Vector2(button_size / 3, button_size / 3)
		pencil_cell.add_theme_font_size_override("font_size", button_size * (0.7 / 3))

func _ui_hack(): #YUCK
	# Only trigger resize if there's a significant size mismatch
	var size_threshold = 0.05  # 5% threshold
	
	if aspect_container.size.y >= viewport_size.y * (1.0 + size_threshold) || aspect_container.size.x >= viewport_size.x * (1.0 + size_threshold):
		_on_viewport_size_changed()
		print("BAD UI BIG")

	if aspect_container.size.y <= viewport_size.y * (1.0 - size_threshold) && aspect_container.size.x <= viewport_size.x * (1.0 - size_threshold):
		_on_viewport_size_changed()
		print("BAD UI SMALL")

func save_game_state():
	if sudoku.save_state(SAVE_STATE_PATH):
		print("Game state saved successfully")
	else:
		print("Failed to save game state")

func load_game_state() -> bool:
	if sudoku.load_state(SAVE_STATE_PATH):
		queue_update("grid")
		queue_update("buttons")
		queue_update("pencil")
		queue_update("highlights")
		queue_update("info")
		timer_running = true
		return true
	return false

func save_completed_puzzle():
	if sudoku.save_completed_puzzle():
		print("Completed puzzle saved successfully")
	else:
		print("Failed to save completed puzzle")

func _connect_signals():
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	get_window().focus_entered.connect(_on_window_focus_in)
	get_window().focus_exited.connect(_on_window_focus_out)
	if OS.get_name() == "Android":
		_request_permissions()

func update_puzzle_info():
	var info = sudoku.get_puzzle_info()
	puzzle_info.text = "Puzzle: %s\nDifficulty: %s" % [info.name, info.difficulty]

func load_puzzle(index: int, difficulty: String):
	sudoku.puzzle_selected = difficulty
	if sudoku.load_puzzle(sudoku.puzzles[sudoku.puzzle_selected], index):
		selected_cell = Vector2(-1, -1)
		timer_running = true
		sudoku.puzzle_time = 0
		queue_update("grid")
		queue_update("buttons")
		queue_update("pencil")
		queue_update("highlights")
		queue_update("info")
	else:
		print("Failed to load puzzle")

func show_puzzle_done_popup():
	var popupDone = preload("res://puzzleDone.tscn").instantiate()
	var dimensions = get_viewport().get_visible_rect().size
	popupDone.size = Vector2(dimensions.x * 0.5, dimensions.y * 0.5)
	add_child(popupDone)
	popupDone.popup_centered()
