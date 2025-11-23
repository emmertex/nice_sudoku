extends Control

# Color Themes (Organized by Usage)
const THEME_COLORS = {
	ThemeType.DARK: {
		# Color Palette (Organized by Usage)
		"CLR_BACKGROUND": Color(0.1, 0.1, 0.1),      # Main background
		"CLR_SURFACE": Color(0.15, 0.15, 0.15),      # Surface elements
		"CLR_SURFACE_VARIANT": Color(0.2, 0.2, 0.2), # Variant surfaces

		# Grid Colors
		"CLR_BOARD": Color(0.21, 0.21, 0.21),        # Empty cell background 1
		"CLR_BOARD2": Color(0.26, 0.26, 0.26),       # Empty cell background 2
		"CLR_GIVEN": Color(0.1, 0.3, 0.4, 0.8),      # Given number cells
		"CLR_SELECT": Color(0.13, 0.4, 0.65, 0.8),   # Selected cell
		"CLR_HOVER": Color(0.13, 0.4, 0.65, 0.4),    # Hovered cell
		"CLR_SAME": Color(0.13, 0.4, 0.55, 0.8),     # Same number highlights
		"CLR_PLUS": Color(0.25, 0.35, 0.6, 0.8),     # Row/column highlights
		"CLR_BLOCK": Color(0.2, 0.3, 0.55, 0.8),     # Block highlights
		"CLR_BLOCKED": Color(0.2, 0.3, 0.55, 0.8),   # Filled cells

		# Text Colors
		"CLR_FONT_GIVEN_NUMBER": Color(0.75, 0.75, 0.75, 1),   # Given numbers
		"CLR_FONT_REGULAR_NUMBER": Color(1, 1, 1, 1),           # User-entered numbers
		"CLR_FONT_LABEL": Color(0.8, 0.8, 0.8, 1),              # UI labels
		"CLR_FONT_HEADER": Color(1, 1, 0, 1),                   # Header text

		# Pencil and Hint Colors
		"CLR_PENCIL": Color(0.95, 0.95, 0.95),        # Pencil marks
		"CLR_PENCIL_HIGHLIGHT": Color(0.3, 1.0, 0.3), # Highlighted pencil marks
		"CLR_PENCIL_EXCLUDE": Color(1.00, 0.3, 0.3),  # Excluded pencil marks
		"CLR_MISTAKE_FLASH": Color(1.0, 0.3, 0.3, 1.0), # Mistake flash

		# Hint Colors
		"CLR_HINT_AFFECTED": Color(0, 0.5, 0, 1),     # Affected cells in hints
		"CLR_HINT_PRIMARY": Color(0, 0.5, 0, 1),      # Primary hint cells
		"CLR_HINT_SECONDARY": Color(0.58, 0, 0.83, 1), # Secondary hint cells
		"CLR_HINT_CAUSE": Color(0.55, 0, 0, 1),       # Cause cells in hints

		# Grid and Border Colors
		"CLR_GRID_BORDER": Color(0, 0, 0, 1),         # Grid borders
		"CLR_GRID_THICK": Color(0.1, 0.1, 0.1, 1),    # Thick borders
	},
	ThemeType.LIGHT: {
		# Color Palette (Organized by Usage)
		"CLR_BACKGROUND": Color(0.95, 0.95, 0.95),    # Main background
		"CLR_SURFACE": Color(0.9, 0.9, 0.9),          # Surface elements
		"CLR_SURFACE_VARIANT": Color(0.85, 0.85, 0.85), # Variant surfaces

		# Grid Colors
		"CLR_BOARD": Color(1, 1, 1),                   # Empty cell background 1
		"CLR_BOARD2": Color(0.97, 0.97, 0.97),        # Empty cell background 2
		"CLR_GIVEN": Color(0.7, 0.85, 0.9, 0.8),      # Given number cells
		"CLR_SELECT": Color(0.4, 0.7, 0.9, 0.8),      # Selected cell
		"CLR_HOVER": Color(0.4, 0.7, 0.9, 0.4),       # Hovered cell
		"CLR_SAME": Color(0.5, 0.75, 0.85, 0.8),      # Same number highlights
		"CLR_PLUS": Color(0.6, 0.75, 0.9, 0.8),       # Row/column highlights
		"CLR_BLOCK": Color(0.55, 0.7, 0.85, 0.8),     # Block highlights
		"CLR_BLOCKED": Color(0.55, 0.7, 0.85, 0.8),   # Filled cells

		# Text Colors
		"CLR_FONT_GIVEN_NUMBER": Color(0.4, 0.4, 0.4, 1),   # Given numbers
		"CLR_FONT_REGULAR_NUMBER": Color(0.1, 0.1, 0.1, 1), # User-entered numbers
		"CLR_FONT_LABEL": Color(0.3, 0.3, 0.3, 1),          # UI labels
		"CLR_FONT_HEADER": Color(0.8, 0.5, 0.1, 1),         # Header text

		# Pencil and Hint Colors
		"CLR_PENCIL": Color(0.5, 0.5, 0.5),            # Pencil marks
		"CLR_PENCIL_HIGHLIGHT": Color(0.2, 0.8, 0.2),   # Highlighted pencil marks
		"CLR_PENCIL_EXCLUDE": Color(0.9, 0.2, 0.2),     # Excluded pencil marks
		"CLR_MISTAKE_FLASH": Color(1.0, 0.3, 0.3, 1.0), # Mistake flash

		# Hint Colors
		"CLR_HINT_AFFECTED": Color(0.2, 0.6, 0.2, 1),   # Affected cells in hints
		"CLR_HINT_PRIMARY": Color(0.2, 0.6, 0.2, 1),    # Primary hint cells
		"CLR_HINT_SECONDARY": Color(0.7, 0.2, 0.9, 1),  # Secondary hint cells
		"CLR_HINT_CAUSE": Color(0.8, 0.3, 0.3, 1),      # Cause cells in hints

		# Grid and Border Colors
		"CLR_GRID_BORDER": Color(0.7, 0.7, 0.7, 1),     # Grid borders
		"CLR_GRID_THICK": Color(0.5, 0.5, 0.5, 1),      # Thick borders
	},
	ThemeType.EPAPER: {
		# Color Palette (Organized by Usage) - High contrast B&W with color support
		"CLR_BACKGROUND": Color(1, 1, 1),               # Main background (white)
		"CLR_SURFACE": Color(0.95, 0.95, 0.95),         # Surface elements
		"CLR_SURFACE_VARIANT": Color(0.9, 0.9, 0.9),    # Variant surfaces

		# Grid Colors
		"CLR_BOARD": Color(1, 1, 1),                    # Empty cell background 1 (white)
		"CLR_BOARD2": Color(0.98, 0.98, 0.98),         # Empty cell background 2 (off-white)
		"CLR_GIVEN": Color(0.85, 0.85, 0.85, 0.9),     # Given number cells (light gray)
		"CLR_SELECT": Color(0.7, 0.7, 0.7, 0.9),       # Selected cell (medium gray)
		"CLR_HOVER": Color(0.8, 0.8, 0.8, 0.6),        # Hovered cell (light gray)
		"CLR_SAME": Color(0.75, 0.75, 0.75, 0.9),      # Same number highlights
		"CLR_PLUS": Color(0.8, 0.8, 0.8, 0.9),         # Row/column highlights
		"CLR_BLOCK": Color(0.7, 0.7, 0.7, 0.9),        # Block highlights
		"CLR_BLOCKED": Color(0.7, 0.7, 0.7, 0.9),      # Filled cells

		# Text Colors - High contrast black text
		"CLR_FONT_GIVEN_NUMBER": Color(0.3, 0.3, 0.3, 1),   # Given numbers (dark gray)
		"CLR_FONT_REGULAR_NUMBER": Color(0, 0, 0, 1),        # User-entered numbers (black)
		"CLR_FONT_LABEL": Color(0.2, 0.2, 0.2, 1),           # UI labels (dark gray)
		"CLR_FONT_HEADER": Color(0.1, 0.1, 0.1, 1),          # Header text (very dark)

		# Pencil and Hint Colors - Color support for ePaper displays
		"CLR_PENCIL": Color(0.4, 0.4, 0.4),             # Pencil marks (gray)
		"CLR_PENCIL_HIGHLIGHT": Color(0.2, 0.7, 0.2),    # Highlighted pencil marks (green)
		"CLR_PENCIL_EXCLUDE": Color(0.8, 0.2, 0.2),      # Excluded pencil marks (red)
		"CLR_MISTAKE_FLASH": Color(1.0, 0.3, 0.3, 1.0),  # Mistake flash (red)

		# Hint Colors - Full color support for ePaper displays
		"CLR_HINT_AFFECTED": Color(0.1, 0.6, 0.1, 1),    # Affected cells in hints (dark green)
		"CLR_HINT_PRIMARY": Color(0.1, 0.6, 0.1, 1),     # Primary hint cells (dark green)
		"CLR_HINT_SECONDARY": Color(0.6, 0.1, 0.8, 1),   # Secondary hint cells (purple)
		"CLR_HINT_CAUSE": Color(0.7, 0.2, 0.2, 1),       # Cause cells in hints (red)

		# Grid and Border Colors - High contrast
		"CLR_GRID_BORDER": Color(0, 0, 0, 1),            # Grid borders (black)
		"CLR_GRID_THICK": Color(0.3, 0.3, 0.3, 1),       # Thick borders (dark gray)
	},
}

const SAVE_STATE_PATH = "user://save_state.cfg"

# Enums
enum HighlightMode { SAME, CROSS, REGION, FULL, PENCIL }
enum Mode { NUMBER, NUMBER_CLR, PENCIL, PENCIL_EXCLUDE }
enum ThemeType { DARK, LIGHT, EPAPER }

# Variables
var sudoku: Sudoku
var hint_generator
var selected_cell: Vector2 = Vector2(-1, -1)
var selected_num = 0
var highlight_mode: HighlightMode = HighlightMode.FULL
var mode: Mode = Mode.NUMBER
var viewport_size: Vector2
var orientation: bool = true
var vertical_aspect_ratio: float = 1.0 / 1.638
var current_aspect_ratio: float = 1
var button_size: int = 70
var font_size: int = 10
var timer_running: bool = false
var permissions_requested = false
var _pending_updates: Array = []
var _update_timer: Timer
var current_hint: Hint = null
var hint_panel: Panel = null
var current_theme: ThemeType = ThemeType.DARK

# Onready variables
@onready var number_buttons = $Panel/AspectRatioContainer/VBoxContainer/NumberButtons
@onready var grid_container = $Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid/AspectRatioContainer/GridContainer
@onready var puzzle_info = $Panel/AspectRatioContainer/VBoxContainer/PuzzleInfo
@onready var highlight_button = $Panel/AspectRatioContainer/VBoxContainer/AdditionalOptions/GameFeatures/HighlightButton
@onready var game_timer_text = $Panel/AspectRatioContainer/VBoxContainer/TopMenuBar/PlayTimeLabel
@onready var top_menu_bar = $Panel/AspectRatioContainer/VBoxContainer/TopMenuBar
@onready var additional_options = $Panel/AspectRatioContainer/VBoxContainer/AdditionalOptions
@onready var options_toggle_button = $Panel/AspectRatioContainer/VBoxContainer/TopMenuBar/OptionsToggleButton
@onready var aspect_container = $Panel/AspectRatioContainer/ColorRect2
@onready var theme_selector = $Panel/AspectRatioContainer/VBoxContainer/AdditionalOptions/GameFeatures/ThemeSelector

func _ready():
	await get_tree().process_frame
	_load_theme()
	_initialize()
	_setup_ui()
	_connect_signals()
	_setup_update_batching()
	if !load_game_state():
		_load_initial_puzzle()

	# Set initial theme selector value
	theme_selector.selected = current_theme

	# Hide additional options by default
	additional_options.visible = false

func _load_theme():
	# Load theme preference
	var config = ConfigFile.new()
	var theme_path = "user://theme.cfg"
	if config.load(theme_path) == OK:
		current_theme = config.get_value("theme", "current_theme", ThemeType.DARK) as ThemeType

	# Apply the theme colors to UI elements that use direct color overrides
	_apply_current_theme_colors()

	# Load and apply the Godot theme resource
	var theme = load("res://game_theme.tres")
	if theme:
		theme = theme as Theme
		# Apply theme to the main control and its children
		_apply_theme_recursive(self, theme)

func _apply_theme_recursive(node: Node, theme: Theme):
	if node is Control and node != self:  # Don't apply to root to avoid overriding specific styles
		node.theme = theme

	for child in node.get_children():
		_apply_theme_recursive(child, theme)

func _apply_current_theme_colors():
	# Update background color
	$ColorRect.color = get_current_theme_color("CLR_BACKGROUND")

	# Update aspect container background
	$Panel/AspectRatioContainer/ColorRect2.color = get_current_theme_color("CLR_BACKGROUND")

func get_current_theme_color(color_name: String) -> Color:
	return THEME_COLORS[current_theme][color_name]

func switch_theme(new_theme: ThemeType):
	if current_theme == new_theme:
		return

	current_theme = new_theme
	_apply_current_theme_colors()

	# Update all UI elements to use new theme colors
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")
	queue_update("info")

	_save_theme_preference()

func _save_theme_preference():
	var config = ConfigFile.new()
	var theme_path = "user://theme.cfg"
	config.set_value("theme", "current_theme", current_theme)
	config.save(theme_path)

func _initialize():
	sudoku = Sudoku.new()
	hint_generator = load("res://hint_generator.gd").new()
	hint_generator.sudoku = sudoku
	# ColorRect color is set in _apply_current_theme_colors()
	
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
				button.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_GIVEN_NUMBER"))
			else:
				button.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_REGULAR_NUMBER"))
	if sudoku.is_completed():
		timer_running = false
		save_completed_puzzle()
		show_puzzle_done_popup()

func _create_pencil_marks(container: Control):
	for i in range(3):
		for j in range(3):
			var label = Label.new()
			@warning_ignore("integer_division")
			label.position = Vector2(i * (button_size / 3), j * (button_size / 3))  # Position the label
			@warning_ignore("integer_division")
			label.size = Vector2(button_size / 3, button_size / 3)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.add_theme_color_override("font_color", get_current_theme_color("CLR_PENCIL"))  # Use add_theme_color_override
			container.add_child(label)

func _create_grid():
	grid_container.columns = 9
	grid_container.add_theme_constant_override("hseparation", 2)
	grid_container.add_theme_constant_override("vseparation", 2)

	for row in range(9):
		for col in range(9):
			var button = Button.new()

			var pencil_marks_container = Control.new()
			pencil_marks_container.set_custom_minimum_size (Vector2(button_size, button_size))
			pencil_marks_container.mouse_filter = Control.MOUSE_FILTER_PASS
			button.add_child(pencil_marks_container)
			_create_pencil_marks(pencil_marks_container)

			button.set_custom_minimum_size(Vector2(button_size, button_size))
			@warning_ignore("narrowing_conversion")
			button.add_theme_font_size_override("font_size", button_size * 0.5)

			# Enhanced button styling with better visual feedback
			var hover_style = StyleBoxFlat.new()
			hover_style.set_bg_color(get_current_theme_color("CLR_HOVER"))
			hover_style.set_border_width_all(2)
			hover_style.set_border_color(Color(0.4, 0.4, 0.4, 0.8))
			hover_style.set_corner_radius_all(4)
			button.add_theme_stylebox_override("hover", hover_style)

			var focus_style = StyleBoxFlat.new()
			focus_style.set_bg_color(get_current_theme_color("CLR_SELECT"))
			focus_style.set_border_width_all(3)
			focus_style.set_border_color(Color(0.6, 0.6, 0.6, 1))
			focus_style.set_corner_radius_all(4)
			button.add_theme_stylebox_override("focus", focus_style)

			button.pressed.connect(_on_cell_pressed.bind(row, col))

			# Improved grid styling with better visual hierarchy
			var style = StyleBoxFlat.new()
			if ((col * 9) + row) % 2 == 0:
				style.set_bg_color(get_current_theme_color("CLR_BOARD"))
			else:
				style.set_bg_color(get_current_theme_color("CLR_BOARD2"))

			# Add subtle inner borders for all cells
			style.set_border_width_all(1)
			style.set_border_color(Color(0.25, 0.25, 0.25, 0.8))

			# Add thicker borders for 3x3 subgrids
			if col % 3 == 0:
				style.set_border_width(SIDE_LEFT, 4)
				style.set_border_color(get_current_theme_color("CLR_GRID_THICK"))
			if col % 3 == 2:
				style.set_border_width(SIDE_RIGHT, 4)
				style.set_border_color(get_current_theme_color("CLR_GRID_THICK"))
			if row % 3 == 0:
				style.set_border_width(SIDE_TOP, 4)
				style.set_border_color(get_current_theme_color("CLR_GRID_THICK"))
			if row % 3 == 2:
				style.set_border_width(SIDE_BOTTOM, 4)
				style.set_border_color(get_current_theme_color("CLR_GRID_THICK"))

			button.add_theme_stylebox_override("normal", style)
			grid_container.add_child(button)

func _setup_number_buttons():
	for i in range(1, 13):
		var button = number_buttons.get_node("Button" + str(i))
		button.set_custom_minimum_size(Vector2(button_size * 1.5, button_size * 1.5))
		@warning_ignore("narrowing_conversion")
		button.add_theme_font_size_override("font_size", button_size * 0.75)

		# Enhanced button styling
		var hover_style = StyleBoxFlat.new()
		hover_style.set_bg_color(get_current_theme_color("CLR_HOVER"))
		hover_style.set_border_width_all(2)
		hover_style.set_border_color(Color(0.4, 0.4, 0.4, 0.8))
		hover_style.set_corner_radius_all(6)
		button.add_theme_stylebox_override("hover", hover_style)

		var pressed_style = StyleBoxFlat.new()
		pressed_style.set_bg_color(get_current_theme_color("CLR_SURFACE"))
		pressed_style.set_border_width_all(2)
		pressed_style.set_border_color(Color(0.6, 0.6, 0.6, 1))
		pressed_style.set_corner_radius_all(6)
		button.add_theme_stylebox_override("pressed", pressed_style)

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
				# Save pencil marks before placing number (they get cleared by set_number)
				var saved_pencil_bits = sudoku.pencil_bits[row][col]
				var saved_exclude_bits = sudoku.exclude_bits[row][col]
				
				var result = sudoku.set_number(row, col, selected_num)
				if result["success"]:
					if result["is_mistake"]:
						# Remove the incorrect number
						sudoku.clear_number(row, col)
						# Restore pencil marks (they were cleared by set_number)
						sudoku.pencil_bits[row][col] = saved_pencil_bits
						# Restore exclude marks and add the new exclude mark for the mistake
						# Use bitwise OR to add without clearing existing exclude marks
						sudoku.exclude_bits[row][col] = saved_exclude_bits | (1 << (selected_num - 1))
						# Store in history (using the saved value as the "old" value)
						sudoku.store_exclude_history(row, col, saved_exclude_bits)
						# Update sbrc_grid to reflect the exclude mark
						sudoku.sbrc_grid.update_grid(sudoku.grid)
						# Apply exclude bits to candidate masks
						for r in range(9):
							for c in range(9):
								var bits_to_exclude = sudoku.exclude_bits[r][c]
								if bits_to_exclude > 0:
									sudoku.sbrc_grid.candidates[r][c].data[0] &= ~bits_to_exclude
						_show_mistake_warning()
					selected_cell = Vector2(-1, -1)
					queue_update("info")  # Update mistake counter display
					queue_update("grid")
					queue_update("pencil")
					# Flash after UI updates to avoid being overridden
					call_deferred("_flash_cell_red", row, col)
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
	var highlight_number = selected_num
	if highlight_number == 0 and selected_cell.x >= 0 and selected_cell.y >= 0:
		highlight_number = sudoku.grid[selected_cell.x][selected_cell.y]
	
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
					pencil_button.add_theme_color_override("font_color", get_current_theme_color("CLR_PENCIL_EXCLUDE"))
				elif pencil:
					pencil_button.text = str(Cardinals.PencilN[num_idx])
					# In ALLC mode, highlight pencil marks matching the selected number
					if highlight_number != 0 and num == highlight_number:
						pencil_button.add_theme_color_override("font_color", get_current_theme_color("CLR_PENCIL_HIGHLIGHT"))
					else:
						pencil_button.add_theme_color_override("font_color", get_current_theme_color("CLR_PENCIL"))
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
			style.bg_color = get_current_theme_color("CLR_BACKGROUND")
			button.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_GIVEN_NUMBER"))
			continue
		else:
			button.disabled = false

		if selected_num == i + 1:
			style.bg_color = get_current_theme_color("CLR_SELECT")
			button.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_REGULAR_NUMBER"))
			button.add_theme_stylebox_override("normal", style)
			continue
		else:
			@warning_ignore("narrowing_conversion")
			if (sudoku.is_valid_move(selected_cell.x, selected_cell.y, i+1) || \
					selected_cell.x < 0 || selected_cell.y < 0) && \
					!sudoku.is_given_number(selected_cell.x, selected_cell.y):
				button.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_REGULAR_NUMBER"))
				style.bg_color = get_current_theme_color("CLR_BOARD2")
			else:
				button.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_REGULAR_NUMBER"))
				style.bg_color = get_current_theme_color("CLR_BACKGROUND")
			button.add_theme_stylebox_override("normal", style)
   
	for i in range(10, 13):
		var button = number_buttons.get_node("Button" + str(i))
		var style = StyleBoxFlat.new()
		button.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_REGULAR_NUMBER"))
		style.bg_color = get_current_theme_color("CLR_BACKGROUND")
		if mode == Mode.NUMBER_CLR && i == 10:
			style.bg_color = get_current_theme_color("CLR_SELECT")
		if mode == Mode.PENCIL && i == 11:
			style.bg_color = get_current_theme_color("CLR_SELECT")
		if mode == Mode.PENCIL_EXCLUDE && i == 12:
			style.bg_color = get_current_theme_color("CLR_SELECT")
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)

func _update_grid_highlights():
	# 1. Clear all highlights
	for row in range(9):
		for col in range(9):
			var button = grid_container.get_child(row * 9 + col)
			var style = button.get_theme_stylebox("normal").duplicate()
			if sudoku.is_given_number(row, col):
				style.set_bg_color(get_current_theme_color("CLR_GIVEN"))
			elif sudoku.grid[row][col] == 0:
				if ((col * 9) + row) % 2 == 0:
					style.set_bg_color(get_current_theme_color("CLR_BOARD"))
				else:
					style.set_bg_color(get_current_theme_color("CLR_BOARD2"))
			else:
				style.set_bg_color(get_current_theme_color("CLR_BLOCKED"))
			button.add_theme_stylebox_override("normal", style)

	# 2. Highlight selected cell
	if selected_cell.x >= 0 and selected_cell.y >= 0:
		@warning_ignore("narrowing_conversion")
		var button = grid_container.get_child(selected_cell.x * 9 + selected_cell.y)
		var style = button.get_theme_stylebox("normal").duplicate()
		style.set_bg_color(get_current_theme_color("CLR_SELECT"))
		button.add_theme_stylebox_override("normal", style)

	# 3. Highlight logic by mode
	var highlight_number = selected_num
	if highlight_number == 0 and selected_cell.x >= 0 and selected_cell.y >= 0:
		highlight_number = sudoku.grid[selected_cell.x][selected_cell.y]

	if highlight_mode == HighlightMode.FULL and highlight_number != 0:
		for row in range(9):
			for col in range(9):
				if sudoku.grid[row][col] == highlight_number:
					# Highlight Block
					@warning_ignore("integer_division")
					var block_row = int(row / 3) * 3
					@warning_ignore("integer_division")
					var block_col = int(col / 3) * 3
					for r in range(block_row, block_row + 3):
						for c in range(block_col, block_col + 3):
							var block_button = grid_container.get_child(r * 9 + c)
							var block_style = block_button.get_theme_stylebox("normal").duplicate()
							block_style.set_bg_color(get_current_theme_color("CLR_BLOCK"))
							block_button.add_theme_stylebox_override("normal", block_style)
		for row in range(9):
			for col in range(9):
				if sudoku.grid[row][col] == highlight_number:
					# Highlight Row
					for c in range(9):
						var row_button = grid_container.get_child(row * 9 + c)
						var row_style = row_button.get_theme_stylebox("normal").duplicate()
						row_style.set_bg_color(get_current_theme_color("CLR_PLUS"))
						row_button.add_theme_stylebox_override("normal", row_style)
					# Highlight Column
					for r in range(9):
						var col_button = grid_container.get_child(r * 9 + col)
						var col_style = col_button.get_theme_stylebox("normal").duplicate()
						col_style.set_bg_color(get_current_theme_color("CLR_PLUS"))
						col_button.add_theme_stylebox_override("normal", col_style)
				if sudoku.has_exclude_mark(row, col, highlight_number):
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					style.set_bg_color(get_current_theme_color("CLR_BLOCK"))
					button.add_theme_stylebox_override("normal", style)
				if sudoku.grid[row][col] == highlight_number:
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					style.set_bg_color(get_current_theme_color("CLR_SAME"))
					button.add_theme_stylebox_override("normal", style)
	elif highlight_mode == HighlightMode.PENCIL and highlight_number != 0:
		# Highlight all cells WITHOUT the pencil mark as unavailable
		for row in range(9):
			for col in range(9):
				if not sudoku.has_pencil_mark(row, col, highlight_number):
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					style.set_bg_color(get_current_theme_color("CLR_BLOCK"))
					button.add_theme_stylebox_override("normal", style)

	# Restore NUM, NRC, NRCB highlight logic
	elif highlight_mode == HighlightMode.SAME and highlight_number != 0:
		# Highlight all cells with the same number as selected cell
		for row in range(9):
			for col in range(9):
				if sudoku.grid[row][col] == highlight_number:
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					style.set_bg_color(get_current_theme_color("CLR_SAME"))
					button.add_theme_stylebox_override("normal", style)
	elif highlight_mode == HighlightMode.CROSS and selected_cell.x >= 0 and selected_cell.y >= 0:
		# Highlight row and column of selected cell
		for i in range(9):
			@warning_ignore("narrowing_conversion")
			var row_button = grid_container.get_child(selected_cell.x * 9 + i)
			@warning_ignore("narrowing_conversion")
			var col_button = grid_container.get_child(i * 9 + selected_cell.y)
			var row_style = row_button.get_theme_stylebox("normal").duplicate()
			var col_style = col_button.get_theme_stylebox("normal").duplicate()
			row_style.set_bg_color(get_current_theme_color("CLR_PLUS"))
			col_style.set_bg_color(get_current_theme_color("CLR_PLUS"))
			row_button.add_theme_stylebox_override("normal", row_style)
			col_button.add_theme_stylebox_override("normal", col_style)
	elif highlight_mode == HighlightMode.REGION and selected_cell.x >= 0 and selected_cell.y >= 0:
		# Highlight row, column, and block of selected cell
		for i in range(9):
			@warning_ignore("narrowing_conversion")
			var row_button = grid_container.get_child(selected_cell.x * 9 + i)
			@warning_ignore("narrowing_conversion")
			var col_button = grid_container.get_child(i * 9 + selected_cell.y)
			var row_style = row_button.get_theme_stylebox("normal").duplicate()
			var col_style = col_button.get_theme_stylebox("normal").duplicate()
			row_style.set_bg_color(get_current_theme_color("CLR_PLUS"))
			col_style.set_bg_color(get_current_theme_color("CLR_PLUS"))
			row_button.add_theme_stylebox_override("normal", row_style)
			col_button.add_theme_stylebox_override("normal", col_style)
		# Highlight block
		var block_row = int(selected_cell.x / 3) * 3
		var block_col = int(selected_cell.y / 3) * 3
		for r in range(block_row, block_row + 3):
			for c in range(block_col, block_col + 3):
				var block_button = grid_container.get_child(r * 9 + c)
				var block_style = block_button.get_theme_stylebox("normal").duplicate()
				block_style.set_bg_color(get_current_theme_color("CLR_BLOCK"))
				block_button.add_theme_stylebox_override("normal", block_style)

	if current_hint:
		highlight_hint(current_hint)

func _on_HintButton_pressed():
	if hint_panel:
		_on_hint_dismissed()
		return

	_update_timer.stop()

	# Clear previous hint and disabling number highlight for clarity during hints
	current_hint = null
	selected_num = 0
	highlight_mode = HighlightMode.REGION
	_update_grid_highlights()
	_update_pencil()

	var hints = hint_generator.get_hints()
	hint_panel = preload("res://hint_popup.tscn").instantiate()
	hint_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var container = top_menu_bar.get_parent()
	container.add_child(hint_panel)
	container.move_child(hint_panel, top_menu_bar.get_index())

	# Add fade-in animation
	hint_panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(hint_panel, "modulate", Color(1, 1, 1, 1), 0.3)

	top_menu_bar.hide()
	additional_options.hide()
	
	# Connect signals BEFORE they can be emitted
	hint_panel.connect("hint_selected", self._on_hint_selected)
	hint_panel.connect("hint_dismissed", self._on_hint_dismissed)
	hint_panel.connect("next_step_requested", self._on_hint_step_changed)
	hint_panel.connect("prev_step_requested", self._on_hint_step_changed)
	
	hint_panel.set_hints(hints)
	
	var hint_font_size = int(button_size * 0.35)
	hint_panel.setup_ui(hint_font_size)

func _on_hint_selected(hint: Hint):
	current_hint = hint
	_update_grid_highlights()
	_update_pencil()

func _on_hint_step_changed(hint: Hint):
	current_hint = hint
	_update_grid_highlights()
	_update_pencil()

func _on_hint_dismissed():
	current_hint = null
	if hint_panel:
		hint_panel.queue_free()
		hint_panel = null

	top_menu_bar.show()
	# Keep additional options hidden by default unless user toggled them

	# Restore previous highlight preference to ALLC after hinting session
	highlight_mode = HighlightMode.FULL
	_update_grid_highlights()
	_update_pencil()
	_update_timer.start() # Resume automatic updates

func highlight_hint(hint: Hint):
	# Resolve active step-aware data
	var prim_cells = hint.get_active_cells()
	var sec_cells = hint.get_active_secondary_cells()
	var cause_cells = hint.get_active_cause_cells()
	var elim_cells = hint.get_active_elim_cells()
	var elim_numbers = hint.get_active_elim_numbers()

	# Highlight primary cells
	for cell in prim_cells:
		var button = grid_container.get_child(cell.x * 9 + cell.y)
		var style = button.get_theme_stylebox("normal").duplicate()
		style.set_bg_color(get_current_theme_color("CLR_HINT_SECONDARY"))
		button.add_theme_stylebox_override("normal", style)

	# Highlight secondary cells
	for cell in sec_cells:
		var s_button = grid_container.get_child(cell.x * 9 + cell.y)
		var s_style = s_button.get_theme_stylebox("normal").duplicate()
		s_style.set_bg_color(get_current_theme_color("CLR_HINT_PRIMARY"))
		s_button.add_theme_stylebox_override("normal", s_style)

	# Highlight cause cells
	for cell in cause_cells:
		var c_button = grid_container.get_child(cell.x * 9 + cell.y)
		var c_style = c_button.get_theme_stylebox("normal").duplicate()
		c_style.set_bg_color(get_current_theme_color("CLR_HINT_CAUSE"))
		c_button.add_theme_stylebox_override("normal", c_style)

	# Highlight elimination cells and their specific pencil marks
	for cell in elim_cells:
		var button = grid_container.get_child(cell.x * 9 + cell.y)
		var style = button.get_theme_stylebox("normal").duplicate()
		style.set_bg_color(get_current_theme_color("CLR_HINT_AFFECTED"))
		button.add_theme_stylebox_override("normal", style)
		
		if button.get_child_count() > 0:
			var pencil_container = button.get_child(0)
			if pencil_container.get_child_count() >= 9:
				for num in elim_numbers:
					# Validate num is within valid range and pencil mark exists
					if num >= 1 and num <= 9 and sudoku.has_pencil_mark(cell.x, cell.y, num):
						var pencil_label = pencil_container.get_child(num - 1)
						if pencil_label:
							pencil_label.add_theme_color_override("font_color", get_current_theme_color("CLR_HINT_CAUSE"))
		else:
			push_error("Button missing pencil container child")

func _on_NewGameButton_pressed():
	show_puzzle_selection_popup()

func show_puzzle_selection_popup():
	var popup = PopupPanel.new()
	var window_size = get_viewport().get_visible_rect().size
	popup.set_size(Vector2((min(window_size.y, window_size.x)) * 0.8, window_size.y * 0.8))
	popup.name = "PuzzleSelectionPopup"
	add_child(popup)

	# Apply theme to popup
	var theme = load("res://game_theme.tres")
	if theme:
		popup.theme = theme

	# Improve popup panel styling
	var panel_style = StyleBoxFlat.new()
	panel_style.set_bg_color(Color(0.12, 0.12, 0.15, 0.98))
	panel_style.set_border_width_all(3)
	panel_style.set_border_color(Color(0.3, 0.3, 0.4, 1))
	panel_style.set_corner_radius_all(12)
	panel_style.set_shadow_color(Color(0, 0, 0, 0.4))
	panel_style.set_shadow_size(12)
	popup.add_theme_stylebox_override("panel", panel_style)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	popup.add_child(vbox)

	var difficulty_options = OptionButton.new()
	for difficulty in sudoku.puzzles.keys():
		difficulty_options.add_item(difficulty.capitalize())

	# Style the option button
	var button_style = StyleBoxFlat.new()
	button_style.set_bg_color(Color(0.2, 0.2, 0.25, 1))
	button_style.set_border_width_all(2)
	button_style.set_border_color(Color(0.4, 0.4, 0.5, 1))
	button_style.set_corner_radius_all(6)
	difficulty_options.add_theme_stylebox_override("normal", button_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.set_bg_color(Color(0.25, 0.25, 0.3, 1))
	hover_style.set_border_width_all(2)
	hover_style.set_border_color(Color(0.5, 0.5, 0.6, 1))
	hover_style.set_corner_radius_all(6)
	difficulty_options.add_theme_stylebox_override("hover", hover_style)

	@warning_ignore("narrowing_conversion")
	difficulty_options.add_theme_font_size_override("font_size", button_size * 0.7)
	difficulty_options.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_LABEL"))

	# Style the dropdown popup
	var popup_panel = difficulty_options.get_popup()
	var popup_style = StyleBoxFlat.new()
	popup_style.set_bg_color(get_current_theme_color("CLR_SURFACE_VARIANT"))
	popup_style.set_border_width_all(2)
	popup_style.set_border_color(Color(0.4, 0.4, 0.5, 1))
	popup_style.set_corner_radius_all(6)
	popup_panel.add_theme_stylebox_override("panel", popup_style)

	@warning_ignore("narrowing_conversion")
	popup_panel.add_theme_font_size_override("font_size", button_size * 0.7)
	popup_panel.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_LABEL"))

	var popup_hover_style = StyleBoxFlat.new()
	popup_hover_style.set_bg_color(Color(0.3, 0.3, 0.35, 1))
	popup_panel.add_theme_stylebox_override("hover", popup_hover_style)

	difficulty_options.selected = sudoku.difficulty_index[sudoku.puzzle_selected]
	vbox.add_child(difficulty_options)

	var scroll_container = ScrollContainer.new()
	scroll_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	scroll_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)

	# Style the scroll container
	var scroll_style = StyleBoxFlat.new()
	scroll_style.set_bg_color(Color(0.14, 0.14, 0.18, 1))
	scroll_style.set_border_width_all(1)
	scroll_style.set_border_color(Color(0.3, 0.3, 0.4, 1))
	scroll_style.set_corner_radius_all(8)
	scroll_container.add_theme_stylebox_override("panel", scroll_style)

	vbox.add_child(scroll_container)

	var puzzle_list = VBoxContainer.new()
	puzzle_list.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	puzzle_list.add_theme_constant_override("separation", 8)
	scroll_container.add_child(puzzle_list)

	difficulty_options.connect("item_selected", self._on_difficulty_selected.bind(puzzle_list))
	_on_difficulty_selected(sudoku.difficulty_index[sudoku.puzzle_selected], puzzle_list)

	# Add fade-in animation
	vbox.modulate = Color(1, 1, 1, 0)
	popup.popup_centered()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(vbox, "modulate", Color(1, 1, 1, 1), 0.3)

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

	var puzzle_count = sudoku.get_puzzle_count()
	if puzzle_count > 0:
		for i in range(puzzle_count):
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
	@warning_ignore("integer_division")
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
	
	# Always try to solve if solution not already available (run async to avoid blocking)
	if not sudoku.has_solution or sudoku.solution_grid.is_empty():
		call_deferred("_solve_puzzle_async")
	
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
		var row = int(i / 9)
		var col = i % 9
		given += str(sudoku.original_grid[row][col])
		puzzle += str(sudoku.grid[row][col])
	p891 = puzzle
	for i in range(81):
		var row = int(i / 9)
		var col = i % 9
		for j in range(9):
			if (sudoku.has_exclude_mark(row, col, j+1)):
				p891 += "2"
			elif (sudoku.has_pencil_mark(row, col, j+1)):
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
		
		# Check if solver found a solution
		if not sudoku.has_solution:
			show_solver_failure_warning()
		
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
	for layer in [top_menu_bar, additional_options]:
		for child in layer.get_children():
			if child is HBoxContainer or child is VBoxContainer:
				# Handle nested containers
				for nested_child in child.get_children():
					nested_child.set_custom_minimum_size(Vector2(aspect_container.size.x/4.2, button_size * 1.2))
					@warning_ignore("narrowing_conversion")
					nested_child.add_theme_font_size_override("font_size", button_size * 0.4)
			else:
				child.set_custom_minimum_size(Vector2(aspect_container.size.x/4.2, button_size * 1.2))
				@warning_ignore("narrowing_conversion")
				child.add_theme_font_size_override("font_size", button_size * 0.4)

			# Add better styling to menu buttons
			var normal_style = StyleBoxFlat.new()
			normal_style.set_bg_color(Color(0.18, 0.18, 0.18, 1))
			normal_style.set_border_width_all(1)
			normal_style.set_border_color(Color(0.3, 0.3, 0.3, 1))
			normal_style.set_corner_radius_all(4)
			child.add_theme_stylebox_override("normal", normal_style)

	puzzle_info.set_custom_minimum_size(Vector2(aspect_container.size.x/1.5, button_size*.75))
	@warning_ignore("narrowing_conversion")
	puzzle_info.add_theme_font_size_override("font_size", button_size * 0.4)
	puzzle_info.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_LABEL"))

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
		@warning_ignore("integer_division")
		pencil_cell.position = Vector2((pencil%3) * (button_size / 3), (pencil/3) * (button_size / 3))
		@warning_ignore("integer_division")
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
		# Ensure solver runs if no valid solution available
		if not sudoku.has_solution or sudoku.solution_grid.is_empty():
			call_deferred("_solve_puzzle_async")

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
	var mistake_text = ""
	if sudoku.has_solution:
		mistake_text = "    |    Mistakes: %d" % sudoku.mistake_count
	puzzle_info.text = "Puzzle: %s    |    Difficulty: %s%s" % [info.name, info.difficulty, mistake_text]

func load_puzzle(index: int, difficulty: String):
	sudoku.puzzle_selected = difficulty
	if sudoku.load_puzzle(sudoku.puzzles[sudoku.puzzle_selected], index):
		selected_cell = Vector2(-1, -1)
		timer_running = true
		sudoku.puzzle_time = 0
		
		# Run solver asynchronously after UI loads (with delay to ensure UI is ready)
		# Use call_deferred to run after all current processing is done
		call_deferred("_solve_puzzle_async")
		
		queue_update("grid")
		queue_update("buttons")
		queue_update("pencil")
		queue_update("highlights")
		queue_update("info")
	else:
		print("Failed to load puzzle")

func _solve_puzzle_async():
	# Run solver after UI has loaded
	# This runs in the background and won't block the UI
	print("Starting solver in background...")
	
	# Add a small delay to ensure UI is fully ready
	await get_tree().create_timer(0.1).timeout
	
	var start_time = Time.get_ticks_msec()
	
	# Try to solve
	sudoku.solve_puzzle()
	
	var elapsed = Time.get_ticks_msec() - start_time
	print("Solver completed in %d ms, has_solution: %s" % [elapsed, sudoku.has_solution])
	
	# Check if solver found a solution
	if not sudoku.has_solution:
		print("Solver failed to find solution - mistake detection disabled")
	
	# Update UI to show mistake counter if solution found
	queue_update("info")

func show_puzzle_done_popup():
	var popupDone = preload("res://puzzleDone.tscn").instantiate()
	var dimensions = get_viewport().get_visible_rect().size
	popupDone.size = Vector2(dimensions.x * 0.5, dimensions.y * 0.5)
	add_child(popupDone)
	popupDone.popup_centered()

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
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")
	update_ui()

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
		@warning_ignore("integer_division")
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
		elif key.to_upper() == "E" or key.to_upper() == "X":
			_on_button_pc_pressed()
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
	if highlight_mode == HighlightMode.FULL:
		highlight_mode = HighlightMode.PENCIL
		_update_highlight_button_text()
	queue_update("pencil")
	queue_update("highlights")

func _show_mistake_warning():
	# Show a simple notification that a mistake was made
	# Update the mistake counter display
	queue_update("info")
	# Could also show a popup here if desired
	print("Mistake detected! Total mistakes: %d" % sudoku.mistake_count)

func _flash_cell_red(row: int, col: int):
	# Flash the cell red to indicate a mistake
	_flash_cell_red_async(row, col)

func _flash_cell_red_async(row: int, col: int):
	# Flash the cell red to indicate a mistake
	var button = grid_container.get_child(row * 9 + col)
	if not button:
		return

	# Store original style
	var original_style = button.get_theme_stylebox("normal").duplicate()

	# Determine normal background color based on cell state
	var normal_bg_color: Color
	if sudoku.is_given_number(row, col):
		normal_bg_color = get_current_theme_color("CLR_GIVEN")
	elif sudoku.grid[row][col] == 0:
		if ((col * 9) + row) % 2 == 0:
			normal_bg_color = get_current_theme_color("CLR_BOARD")
		else:
			normal_bg_color = get_current_theme_color("CLR_BOARD2")
	else:
		normal_bg_color = get_current_theme_color("CLR_BLOCKED")

	# Create red flash style with same borders as original
	var flash_style = original_style.duplicate()
	flash_style.set_bg_color(get_current_theme_color("CLR_MISTAKE_FLASH"))

	# Apply red flash with scale animation
	button.add_theme_stylebox_override("normal", flash_style)

	# Add scale animation for more noticeable feedback
	var original_scale = button.scale
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "scale", original_scale * 1.1, 0.15)
	tween.tween_property(button, "modulate", Color(1, 0.8, 0.8, 1), 0.15)

	# Force update to show the flash
	await get_tree().process_frame

	# Create a tween to fade back to normal over 0.5 seconds
	var fade_tween = create_tween()
	fade_tween.set_ease(Tween.EASE_OUT)
	fade_tween.set_trans(Tween.TRANS_QUAD)

	# Create a function to update the color
	var start_color = get_current_theme_color("CLR_MISTAKE_FLASH")
	var end_color = normal_bg_color

	var update_func = func(progress: float):
		var current_color = start_color.lerp(end_color, progress)
		var style = original_style.duplicate()
		style.set_bg_color(current_color)
		# Preserve all border settings from original
		if original_style.get_border_width(SIDE_LEFT) > 0:
			style.set_border_width(SIDE_LEFT, original_style.get_border_width(SIDE_LEFT))
		if original_style.get_border_width(SIDE_RIGHT) > 0:
			style.set_border_width(SIDE_RIGHT, original_style.get_border_width(SIDE_RIGHT))
		if original_style.get_border_width(SIDE_TOP) > 0:
			style.set_border_width(SIDE_TOP, original_style.get_border_width(SIDE_TOP))
		if original_style.get_border_width(SIDE_BOTTOM) > 0:
			style.set_border_width(SIDE_BOTTOM, original_style.get_border_width(SIDE_BOTTOM))
		style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
		button.add_theme_stylebox_override("normal", style)

	# Tween from 0 to 1, calling update_func at each step
	fade_tween.tween_method(update_func, 0.0, 1.0, 0.5)

	# Reset scale after flash
	var reset_tween = create_tween()
	reset_tween.set_ease(Tween.EASE_OUT)
	reset_tween.set_trans(Tween.TRANS_BACK)
	reset_tween.tween_property(button, "scale", original_scale, 0.2)
	reset_tween.parallel().tween_property(button, "modulate", Color(1, 1, 1, 1), 0.2)

	# After tween completes, refresh highlights to ensure correct state
	await fade_tween.finished
	queue_update("highlights")  # Refresh highlights after flash

func show_solver_failure_warning():
	var popup = AcceptDialog.new()
	popup.dialog_text = "Warning: The solver was unable to find a solution for this puzzle. Mistake detection will not be available."
	popup.title = "Solver Warning"
	add_child(popup)
	popup.popup_centered()
	# Auto-remove after a delay
	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(popup):
		popup.queue_free()

func _on_highlight_button_pressed():
	highlight_mode = HighlightMode.values()[(int(highlight_mode) + 1) % HighlightMode.size()]
	_update_highlight_button_text()

func _on_theme_selected(index: int):
	switch_theme(ThemeType.values()[index])

func _on_options_toggle_pressed():
	additional_options.visible = !additional_options.visible
	if additional_options.visible:
		options_toggle_button.text = "Hide Options ▲"
	else:
		options_toggle_button.text = "More Options ▼"
	queue_update("highlights")
	queue_update("pencil")  # Update pencil marks to apply/remove ALLC highlighting

func _update_highlight_button_text():
	match highlight_mode:
		HighlightMode.SAME:
			highlight_button.text = "Same"
		HighlightMode.CROSS:
			highlight_button.text = "Cross"
		HighlightMode.REGION:
			highlight_button.text = "Region"
		HighlightMode.FULL:
			highlight_button.text = "Full"
		HighlightMode.PENCIL:
			highlight_button.text = "Pencil"
