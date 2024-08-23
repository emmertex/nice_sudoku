extends Control

var sudoku: Sudoku
var hint_generator: SudokuHintGenerator
var selected_cell: Vector2 = Vector2(-1, -1)
var selected_num = 0
var puzzle_time: int = 0

@onready var number_buttons = $Panel/AspectRatioContainer/VBoxContainer/NumberButtons
@onready var grid_container = $Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid/AspectRatioContainer/GridContainer
@onready var blur_overlay = $Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid/AspectRatioContainer/BlurOverlay

var CLR_BOARD = Color(0.21, 0.21, 0.21)
var CLR_BOARD2 = Color(0.26, 0.26, 0.26)
var CLR_SELECT = Color(0.13, 0.4, 0.65, 0.5)
var CLR_SAME = Color(0.13, 0.4, 0.55, 0.5)
var CLR_PLUS = Color(0.25, 0.35, 0.6, 0.5)
var CLR_BLOCK = Color(0.2, 0.3, 0.55, 0.5)
var CLR_ROW = Color(0.2, 0.3, 0.55, 0.5)
var CLR_BLOCKED = Color(0.2, 0.3, 0.55, 0.5)
var CLR_BACKGROUND = Color(0.1, 0.1, 0.1)

var CLR_PENCIL = Color(0.95, 0.95, 0.95)
var CLR_PENCIL_EXCLUDE = Color(1.00, 0.3, 0.3)

enum HighlightMode {
	NUM,
	NRC,
	NRCB,
	ALL,
	ALLC
}
var highlight_mode: HighlightMode = HighlightMode.ALLC

enum Mode {
	NUMBER,
	NUMBER_CLR,
	PENCIL,
	PENCIL_EXCLUDE
}
var mode: Mode
var viewport_size: Vector2
var button_size: int = 70
var font_size: int = 10
var timer_running: bool = false

var permissions_requested = false

func _ready():
	$ColorRect.color = CLR_BACKGROUND
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	sudoku = Sudoku.new()
	mode = Mode.NUMBER
	_create_grid()
	load_puzzle(0) 
	_setup_number_buttons()
	update_puzzle_info()
	_on_viewport_size_changed()
	blur_overlay.material = ShaderMaterial.new()
	blur_overlay.material.shader = load("res://blur_shader.gdshader")
	blur_overlay.visible = false
	get_window().focus_entered.connect(_on_window_focus_in)
	get_window().focus_exited.connect(_on_window_focus_out)

	if OS.get_name() == "Android":
		_request_permissions()

func _on_viewport_size_changed():
	viewport_size = get_viewport().get_visible_rect().size
	$Panel.position = Vector2(0,0)
	$Panel.size = viewport_size
	#if viewport_size.y / viewport_size.x > 1 && viewport_size.y / viewport_size.x < 1.55:
	#	scale = viewport_size.y / viewport_size.x
	#button_size = (min(viewport_size.x, viewport_size.y / 1.3) / 10) / scale
	var game_container = $Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid/AspectRatioContainer
	#game_container.size = $Panel/AspectRatioContainer.size / 1.3
	button_size = min($Panel.size.x, $Panel.size.y/1.6) / 9.5
	print("Viewport size changed to: ", viewport_size, "Button Size: ", button_size, "game_container: ", game_container.size)
	
	number_buttons = $Panel/AspectRatioContainer/VBoxContainer/NumberButtons
	if !number_buttons:
		number_buttons = $Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid/NumberButtons

	if viewport_size.x < viewport_size.y / 1.2:
		if number_buttons.get_parent() != $Panel/AspectRatioContainer/VBoxContainer:
			number_buttons.get_parent().remove_child(number_buttons)
			number_buttons.columns = 6
			$Panel/AspectRatioContainer/VBoxContainer.add_child(number_buttons)
			$Panel/AspectRatioContainer.ratio = 1.638
	else:
		if number_buttons.get_parent() != $Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid:
			number_buttons.get_parent().remove_child(number_buttons)
			number_buttons.columns = 2
			$Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid.add_child(number_buttons)
			$Panel/AspectRatioContainer.ratio = 1
			
	for i in range($Panel/AspectRatioContainer/VBoxContainer/MenuLayer1.get_child_count()):
		var child = $Panel/AspectRatioContainer/VBoxContainer/MenuLayer1.get_child(i)
		child.set_custom_minimum_size(Vector2(button_size*(9/4),button_size*.75))
		child.add_theme_font_size_override("font_size", button_size*.375)
	for i in range($Panel/AspectRatioContainer/VBoxContainer/MenuLayer2.get_child_count()):
		var child = $Panel/AspectRatioContainer/VBoxContainer/MenuLayer2.get_child(i)
		child.set_custom_minimum_size(Vector2(button_size*(9/4),button_size*.75))
		child.add_theme_font_size_override("font_size", button_size*.375)
	
	$Panel/AspectRatioContainer/VBoxContainer/PuzzleInfo.set_custom_minimum_size(Vector2(button_size*.75,button_size*.75))
	$Panel/AspectRatioContainer/VBoxContainer/PuzzleInfo.add_theme_font_size_override("font_size", button_size*.375)
	
	for col in range(9):
		for row in range(9):
			var grid_button = grid_container.get_child(row * 9 + col)
			var pencil_container = grid_button.get_child(0)
			grid_button.set_custom_minimum_size(Vector2(button_size, button_size))
			pencil_container.set_custom_minimum_size(Vector2(button_size, button_size))
			grid_button.add_theme_font_size_override("font_size", button_size * 0.5)
			for pencil in range(9):
				var pencil_cell = pencil_container.get_child(pencil)
				pencil_cell.position = Vector2((pencil%3) * (button_size / 3), (pencil/3) * (button_size / 3))
				pencil_cell.size = Vector2(button_size / 3, button_size / 3)
				pencil_cell.add_theme_font_size_override("font_size", button_size * (0.8 / 3))
			
			
			
	for but in range(12):
		var sel_button = number_buttons.get_node("Button" + str(but+1))
		sel_button.set_custom_minimum_size(Vector2(button_size*1.5,button_size*1.5))
		sel_button.add_theme_font_size_override("font_size", button_size*.75)

func load_puzzle(index: int):
	sudoku.puzzle_selected = "hard"
	if sudoku.load_puzzle(sudoku.puzzles[sudoku.puzzle_selected], index):
		_update_grid()
		selected_cell = Vector2(-1, -1)
		_update_grid_highlights()
		timer_running = true
		puzzle_time = 0
	else:
		print("Failed to load puzzle")

func update_puzzle_info():
	var info = sudoku.get_puzzle_info()
	$Panel/AspectRatioContainer/VBoxContainer/PuzzleInfo.text = "Puzzle: %s\nDifficulty: %s" % [info.name, info.difficulty]

func _create_pencil_marks(container: Control, row: int, col: int):
	for i in range(3):
		for j in range(3):
			var label = Label.new()
			label.position = Vector2(i * (button_size / 3), i * (button_size / 3))  # Position the label
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
			_create_pencil_marks(pencil_marks_container, row, col)
			
			button.set_custom_minimum_size(Vector2(button_size, button_size))
			button.add_theme_font_size_override("font_size", button_size * 0.5)
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
		if i < 10:
			button.set_text(str(i))
			button.pressed.connect(_on_number_button_pressed.bind(i))
		

func _on_cell_pressed(row: int, col: int):
	if selected_cell == Vector2(row, col):
		selected_cell = Vector2(-1, -1)
		_update_buttons()
		_update_grid_highlights()
		return
	selected_cell = Vector2(row, col)
	if mode == Mode.NUMBER_CLR:
		if !sudoku.is_original_number(row, col):
			sudoku.clear_number(row, col)
			selected_cell = Vector2(-1, -1)
			_update_grid()
			_update_pencil()

	if mode == Mode.NUMBER:
		if sudoku.grid[row][col] == 0:
			if selected_num != 0:
				sudoku.set_number(row, col, selected_num)
				selected_cell = Vector2(-1, -1)
		else:
			selected_num = sudoku.grid[row][col]
		sudoku._update_RnCnBn()
		_update_grid()
		_update_pencil()

	if mode == Mode.PENCIL:
		sudoku.swap_pencil(row, col, selected_num)
		selected_cell = Vector2(-1, -1)
		_update_pencil()
	if mode == Mode.PENCIL_EXCLUDE:
		sudoku.swap_exclude(row, col, selected_num)
		selected_cell = Vector2(-1, -1)
		_update_pencil()

	_update_grid_highlights()

func _update_pencil():
	for row in range(9):
		for col in range(9):
			for num in range(9):
				var pencil_button = grid_container.get_child(row * 9 + col).get_child(0).get_child(num)
				if (sudoku.pencil[row][col][num]):
					pencil_button.text = str(sudoku.PENCIL_NUM[num])
					pencil_button.add_theme_color_override("font_color", CLR_PENCIL)
				elif (sudoku.exclude[row][col][num]):
					if highlight_mode == HighlightMode.ALLC && mode != Mode.PENCIL_EXCLUDE:
						pencil_button.text = ""
					else:
						pencil_button.text = str(sudoku.PENCIL_NUM[num])
						pencil_button.add_theme_color_override("font_color", CLR_PENCIL_EXCLUDE)
				else:
					pencil_button.text = ""


func _on_number_button_pressed(number: int):
	if selected_num == number:
		selected_num = 0
		_update_buttons()
		_update_grid_highlights()
		return
	selected_num = number
	if selected_cell.x >= 0 and selected_cell.y >= 0:
		if mode == Mode.NUMBER:
			if sudoku.set_number(selected_cell.x, selected_cell.y, number):
				sudoku._update_RnCnBn()
				_update_grid()
				_update_pencil()
			selected_cell = Vector2(-1,-1)
			_update_grid_highlights()
		selected_num = 0
	_update_grid_highlights()
	_update_buttons()

func _update_grid():
	for row in range(9):
		for col in range(9):
			var button = grid_container.get_child(row * 9 + col)
			var number = sudoku.grid[row][col]
			button.text = str(number) if number != 0 else ""
			if sudoku.is_original_number(row, col):
				button.add_theme_color_override("font_color", Color.GRAY)
			else:
				button.add_theme_color_override("font_color", Color.WHITE)
	if sudoku.is_completed():
		timer_running = false


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
			if sudoku.is_valid_move(selected_cell.x, selected_cell.y, i+1) || selected_cell.x < 0 || selected_cell.y < 0:
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
	_update_buttons()
	
	match highlight_mode:
		HighlightMode.NUM:
			$Panel/AspectRatioContainer/VBoxContainer/MenuLayer2/HighlightButton.text = "Num"
		HighlightMode.NRC:
			$Panel/AspectRatioContainer/VBoxContainer/MenuLayer2/HighlightButton.text = "RC"
		HighlightMode.NRCB:
			$Panel/AspectRatioContainer/VBoxContainer/MenuLayer2/HighlightButton.text = "RCB"
		HighlightMode.ALL:
			$Panel/AspectRatioContainer/VBoxContainer/MenuLayer2/HighlightButton.text = "ALL"
		HighlightMode.ALLC:
			$Panel/AspectRatioContainer/VBoxContainer/MenuLayer2/HighlightButton.text = "ALLC"
	
	for row in range(9):
		for col in range(9):
			var button = grid_container.get_child(row * 9 + col)
			var style = button.get_theme_stylebox("normal").duplicate()
			if sudoku.grid[row][col] == 0:
				# Unfilled Cell
				if ((col * 9) + row) % 2 == 0:
					style.set_bg_color(CLR_BOARD)
				else:
					style.set_bg_color(CLR_BOARD2)
			else:
				# Filled Cell
				style.set_bg_color(CLR_BLOCKED) 
			button.add_theme_stylebox_override("normal", style)
	
	if selected_num != 0 && highlight_mode >= HighlightMode.ALL:
		for row in range(9):
			for col in range(9):
				if selected_num == sudoku.grid[row][col]:
					for i in range(9):
						var row_button = grid_container.get_child(row * 9 + i)
						var col_button = grid_container.get_child(i * 9 + col)
						var row_style = row_button.get_theme_stylebox("normal").duplicate()
						var col_style = col_button.get_theme_stylebox("normal").duplicate()
						# All blocked Rows and Columns
						row_style.set_bg_color(CLR_ROW) 
						col_style.set_bg_color(CLR_ROW) 
						row_button.add_theme_stylebox_override("normal", row_style)
						col_button.add_theme_stylebox_override("normal", col_style)
					for i in range(3):
						for j in range(3):
							var col_button = grid_container.get_child((((row/3)*3)+i) * 9 + j + ((col/3)*3))
							var style = col_button.get_theme_stylebox("normal").duplicate()
							# Blocked 3x3 Cell
							style.set_bg_color(Color(CLR_ROW))
							col_button.add_theme_stylebox_override("normal", style)
				if sudoku.exclude[row][col][selected_num-1]:
					var col_button = grid_container.get_child(row * 9 + col)
					var col_style = col_button.get_theme_stylebox("normal").duplicate()
					col_style.set_bg_color(CLR_ROW)
					col_button.add_theme_stylebox_override("normal", col_style)
		
	for row in range(9):
		for col in range(9):
			var button = grid_container.get_child(row * 9 + col)
			var cell_value = sudoku.grid[row][col]
			
			var style = button.get_theme_stylebox("normal").duplicate()
			

			# Highlight selected cell
			if row == selected_cell.x and col == selected_cell.y:
				style.set_bg_color(CLR_SELECT) 
				button.add_theme_stylebox_override("normal", style)
				continue

			# Highlight cells with the same number as selected cell
			if highlight_mode >= HighlightMode.NUM:
				if int(cell_value) == selected_num and selected_num != 0:
					style.set_bg_color(CLR_SAME) 
					button.add_theme_stylebox_override("normal", style)
					continue

			# Highlight row/column of selected cell
			if highlight_mode >= HighlightMode.NRC:
				if  (row == selected_cell.x or col == selected_cell.y):
					style.set_bg_color(CLR_PLUS) 
					button.add_theme_stylebox_override("normal", style)
					continue

			# Highlight 3x3 subgrid of selected cell
			if highlight_mode >= HighlightMode.NRCB:
				if selected_cell.x >= 0 && selected_cell.y >= 0:
					if int(row / 3) == int(selected_cell.x / 3) && int(col / 3) == int(selected_cell.y / 3):
						style.set_bg_color(CLR_BLOCK) 
					button.add_theme_stylebox_override("normal", style)
					continue

func _on_HintButton_pressed():
	var hints = hint_generator.get_hints()
	if hints.size() > 0:
		var hint = hints[0]
		print("%s: %s" % [hint.technique, hint.description])
	else:
		print("No hints available")

	for i in hints.size():
		var hint = hints[i]
		print("%s: %s" % [hint.technique, hint.description])
	
func _on_NewGameButton_pressed():
	# Instead of creating a new empty Sudoku, load the next puzzle
	var current_index = sudoku.get_puzzle_index()
	load_puzzle((current_index + 1) % sudoku.get_puzzle_count())
	_update_grid()
	selected_cell = Vector2(-1, -1)
	selected_num = 0
	_update_grid_highlights()
	_update_buttons()
	_update_pencil()
	update_puzzle_info()
	timer_running = true
	puzzle_time = 0
	
	
func _on_LoadPuzzleButton_pressed():
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.filters = ["*.txt ; TXT Files", "*.sdm ; Sudoku Files"]
	dialog.connect("file_selected", self._on_puzzle_file_selected)
	add_child(dialog)
	dialog.popup_centered(Vector2(800, 600))

func _on_puzzle_file_selected(path):
	if sudoku.puzzle_file(path):
		_update_grid()
		selected_cell = Vector2(-1, -1)
		selected_num = 0
		_update_grid_highlights()
		_update_buttons()
		_update_pencil()
		update_puzzle_info()
		timer_running = true
		puzzle_time = 0
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
	_update_buttons()


func _on_button_p_pressed():
	if mode == Mode.PENCIL:
		mode = Mode.NUMBER
	else:
		mode = Mode.PENCIL
	_update_buttons()
	


func _on_button_pc_pressed():
	if mode == Mode.PENCIL_EXCLUDE:
		mode = Mode.NUMBER
	else:
		mode = Mode.PENCIL_EXCLUDE
	_update_buttons()
	_update_pencil()
	_update_grid_highlights()


func _on_UndoButton_pressed():
	selected_cell = Vector2(-1,-1)
	selected_num = 0
	sudoku.undo_history()
	_update_grid()
	_update_pencil()
	_update_grid_highlights()
	_update_buttons()


func _on_timer_timeout():
	if timer_running:
		puzzle_time += 1
		var minimum = int(puzzle_time / 60)
		var sec = puzzle_time % 60
		var str_sec = "00"
		if sec < 10:
			str_sec = "0" + str(sec)
		else:
			str_sec = str(sec)
		$Panel/AspectRatioContainer/VBoxContainer/MenuLayer1/Timer.text = str(minimum) + ":" + str_sec + "s"
	
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


func _on_auto_pencil_pressed():
	sudoku.auto_fill_pencil_marks()
	_update_pencil()

func _on_highlight_button_pressed():
	highlight_mode = HighlightMode.values()[(int(highlight_mode) + 1) % HighlightMode.size()]
	_update_grid_highlights()
	_update_pencil()

func _on_window_focus_in():
	blur_overlay.visible = false
	print("Window focus in")

func _on_window_focus_out():
	blur_overlay.visible = true
	print("Window focus out")

func _on_paste_puzzle_button_pressed():
	var popup = Popup.new()
	popup.set_size(Vector2(300, 200))
	add_child(popup)

	var vbox = VBoxContainer.new()
	popup.add_child(vbox)

	var text_input = LineEdit.new()
	text_input.placeholder_text = "Enter 81 characters (0-9)"
	vbox.add_child(text_input)

	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)

	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(popup.hide)
	hbox.add_child(cancel_button)

	var load_button = Button.new()
	load_button.text = "Load"
	load_button.connect("pressed", func(): _on_load_button_pressed(text_input, popup))
	hbox.add_child(load_button)

	popup.popup_centered()

func _on_load_button_pressed(text_input, popup):
	var input_text = text_input.text.strip_edges()
	if input_text.length() == 81:
		var puzzle_data = {"grid": string_to_grid(input_text), "difficulty": "Custom", "name": "Custom Puzzle"}
		sudoku.load_puzzle_from_string(puzzle_data)
		_update_grid()
		selected_cell = Vector2(-1, -1)
		_update_grid_highlights()
		timer_running = true
		puzzle_time = 0
		popup.hide()
	else:
		print("Invalid input. Please enter exactly 81 characters (0-9).")

func string_to_grid(puzzle_string: String) -> Array:
	var _grid = []
	for i in range(9):
		var row = []
		for j in range(9):
			var index = i * 9 + j
			var value = int(puzzle_string[index])
			row.append(value)
		_grid.append(row)
	return _grid
