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
var cached_theme_resource: Theme = null

# Onready variables
@onready var number_buttons = $Panel/AspectRatioContainer/VBoxContainer/NumberButtons
@onready var grid_container = $Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid/AspectRatioContainer/GridContainer
@onready var puzzle_info = $Panel/AspectRatioContainer/VBoxContainer/PuzzleInfo
@onready var highlight_button = $MenuPanel/MenuContent/ToolsContent/HighlightButton
@onready var game_timer_text = $Panel/AspectRatioContainer/VBoxContainer/MenuContainer/TopMenuBar/PlayTimeLabel
@onready var top_menu_bar = $Panel/AspectRatioContainer/VBoxContainer/MenuContainer/TopMenuBar
@onready var menu_panel = $MenuPanel
@onready var menu_toggle_button = $Panel/AspectRatioContainer/VBoxContainer/MenuContainer/TopMenuBar/MenuToggleButton
@onready var aspect_container = $Panel/AspectRatioContainer/ColorRect2
@onready var theme_selector = $MenuPanel/MenuContent/SettingsContent/ThemeSelector
@onready var play_content = $MenuPanel/MenuContent/PlayContent
@onready var tools_content = $MenuPanel/MenuContent/ToolsContent
@onready var settings_content = $MenuPanel/MenuContent/SettingsContent
@onready var menu_content = $MenuPanel/MenuContent

func _ready():
	# Add to group so other nodes can find us for theme colors
	add_to_group("game_screen")
	
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

	# Initialize menu state
	_setup_menu_popup()
	
	# Ensure all font colors are applied after setup
	await get_tree().process_frame
	_apply_menu_font_colors()
	_resize_menu_buttons()

func _load_theme():
	# Load theme preference
	var config = ConfigFile.new()
	var theme_path = "user://theme.cfg"
	if config.load(theme_path) == OK:
		current_theme = config.get_value("theme", "current_theme", ThemeType.DARK) as ThemeType

	# Apply the theme colors to UI elements that use direct color overrides
	_apply_current_theme_colors()

	# Load and cache the theme resource
	_get_or_create_theme_resource()
	
	# Apply theme only to specific containers (not recursively to avoid performance issues)
	call_deferred("_apply_theme_to_containers")
	
	# After theme is applied, ensure our theme-aware colors override theme file defaults
	await get_tree().process_frame
	_apply_menu_font_colors()

func _get_or_create_theme_resource() -> Theme:
	# Cache the theme resource to avoid reloading
	if cached_theme_resource == null:
		var loaded_theme = load("res://game_theme.tres")
		if loaded_theme:
			cached_theme_resource = loaded_theme as Theme
	
	# Update theme resource colors based on current theme
	if cached_theme_resource:
		_update_theme_resource(cached_theme_resource)
	
	return cached_theme_resource

func _apply_theme_to_containers():
	# Only apply theme to specific top-level containers, not recursively
	# This is much faster than applying to every single node
	var theme_resource = _get_or_create_theme_resource()
	if not theme_resource:
		return
	
	# Apply to menu panel and its children
	if menu_panel and is_instance_valid(menu_panel):
		menu_panel.theme = theme_resource
	
	# Note: Grid buttons and other elements use direct color overrides,
	# so they don't need the theme resource applied

func _apply_current_theme_colors():
	# Update background color
	$ColorRect.color = get_current_theme_color("CLR_BACKGROUND")

	# Update aspect container background
	$Panel/AspectRatioContainer/ColorRect2.color = get_current_theme_color("CLR_BACKGROUND")

func get_current_theme_color(color_name: String) -> Color:
	return THEME_COLORS[current_theme][color_name]

func _update_theme_resource(theme_resource: Theme):
	# Get theme colors for current theme
	var surface_color = get_current_theme_color("CLR_SURFACE")
	var surface_variant_color = get_current_theme_color("CLR_SURFACE_VARIANT")
	var background_color = get_current_theme_color("CLR_BACKGROUND")
	var border_color = get_current_theme_color("CLR_GRID_BORDER")
	var font_label_color = get_current_theme_color("CLR_FONT_LABEL")
	var font_given_color = get_current_theme_color("CLR_FONT_GIVEN_NUMBER")
	
	# Update Button styles
	var button_normal_style = theme_resource.get_stylebox("normal", "Button")
	if button_normal_style and button_normal_style is StyleBoxFlat:
		button_normal_style.bg_color = surface_variant_color
		button_normal_style.border_color = border_color
	
	var button_hover_style = theme_resource.get_stylebox("hover", "Button")
	if button_hover_style and button_hover_style is StyleBoxFlat:
		# Hover should be slightly lighter/darker than normal
		if current_theme == ThemeType.DARK:
			button_hover_style.bg_color = surface_variant_color.lightened(0.1)
		else:
			button_hover_style.bg_color = surface_variant_color.darkened(0.05)
		button_hover_style.border_color = border_color
	
	var button_pressed_style = theme_resource.get_stylebox("pressed", "Button")
	if button_pressed_style and button_pressed_style is StyleBoxFlat:
		if current_theme == ThemeType.DARK:
			button_pressed_style.bg_color = surface_variant_color.darkened(0.1)
		else:
			button_pressed_style.bg_color = surface_variant_color.lightened(0.05)
		button_pressed_style.border_color = border_color
	
	var button_focus_style = theme_resource.get_stylebox("focus", "Button")
	if button_focus_style and button_focus_style is StyleBoxFlat:
		button_focus_style.bg_color = surface_variant_color
		button_focus_style.border_color = border_color.lightened(0.3)
	
	var button_disabled_style = theme_resource.get_stylebox("disabled", "Button")
	if button_disabled_style and button_disabled_style is StyleBoxFlat:
		button_disabled_style.bg_color = surface_variant_color
		button_disabled_style.border_color = border_color
	
	# Update Button font colors
	theme_resource.set_color("font_color", "Button", font_label_color)
	theme_resource.set_color("font_hover_color", "Button", font_label_color)
	theme_resource.set_color("font_pressed_color", "Button", font_label_color)
	theme_resource.set_color("font_focus_color", "Button", font_label_color)
	theme_resource.set_color("font_disabled_color", "Button", font_given_color)
	theme_resource.set_color("font_hover_pressed_color", "Button", font_label_color)
	
	# Update Panel style
	var panel_style = theme_resource.get_stylebox("panel", "Panel")
	if panel_style and panel_style is StyleBoxFlat:
		panel_style.bg_color = Color(surface_color.r, surface_color.g, surface_color.b, 0.95)
		panel_style.border_color = border_color
	
	# Update PopupPanel style
	var popup_style = theme_resource.get_stylebox("panel", "PopupPanel")
	if popup_style and popup_style is StyleBoxFlat:
		popup_style.bg_color = Color(background_color.r, background_color.g, background_color.b, 0.98)
		popup_style.border_color = border_color
	
	# Update ScrollContainer style
	var scroll_style = theme_resource.get_stylebox("bg", "ScrollContainer")
	if scroll_style and scroll_style is StyleBoxFlat:
		scroll_style.bg_color = Color(surface_color.r, surface_color.g, surface_color.b, 0.95)
		scroll_style.border_color = border_color
	
	# Update Label font color
	theme_resource.set_color("font_color", "Label", font_label_color)
	
	# Update RichTextLabel default color
	theme_resource.set_color("default_color", "RichTextLabel", font_label_color.lightened(0.1))

func switch_theme(new_theme: ThemeType):
	if current_theme == new_theme:
		return

	current_theme = new_theme
	_apply_current_theme_colors()

	# Update cached theme resource with new colors
	_get_or_create_theme_resource()
	
	# Apply theme to containers (deferred to prevent UI lockup)
	call_deferred("_apply_theme_to_containers")

	# Update all UI elements to use new theme colors
	queue_update("grid")
	queue_update("buttons")
	queue_update("pencil")
	queue_update("highlights")
	queue_update("info")
	
	# Reapply menu popup styling with new theme (deferred to prevent lockup)
	call_deferred("_setup_menu_popup")
	call_deferred("_apply_menu_font_colors")
	call_deferred("_resize_menu_buttons")

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
	# Apply font colors after UI is set up
	_apply_menu_font_colors()

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
			elif sudoku.is_wrong_number(row, col):
				# Wrong numbers should be red
				button.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
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
	var number_font_color = get_current_theme_color("CLR_FONT_REGULAR_NUMBER")
	for i in range(1, 13):
		var button = number_buttons.get_node("Button" + str(i))
		button.set_custom_minimum_size(Vector2(button_size * 1.5, button_size * 1.5))
		@warning_ignore("narrowing_conversion")
		button.add_theme_font_size_override("font_size", button_size * 0.75)
		button.add_theme_color_override("font_color", number_font_color)

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
				var result = sudoku.set_number(row, col, selected_num)
				if result["success"]:
					if result["is_mistake"]:
						# Mistake detected - number stays in place, user can undo it
						_show_mistake_warning()
						# Flash the cell red to indicate mistake
						call_deferred("_flash_cell_red", row, col)
					selected_cell = Vector2(-1, -1)
					queue_update("info")  # Update mistake counter display
					queue_update("grid")
					queue_update("pencil")
					queue_update("highlights")  # Make sure highlights are updated to show wrong numbers
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
				# Check if this is a wrong number - this should take priority
				if sudoku.is_wrong_number(row, col):
					style.set_bg_color(get_current_theme_color("CLR_MISTAKE_FLASH"))
					# # Also ensure the border is visible
					# style.set_border_width_all(2)
					# style.set_border_color(Color(1.0, 0.0, 0.0, 1.0))
				else:
					style.set_bg_color(get_current_theme_color("CLR_BLOCKED"))
			button.add_theme_stylebox_override("normal", style)

	# 2. Highlight selected cell (but preserve wrong number highlighting)
	if selected_cell.x >= 0 and selected_cell.y >= 0:
		@warning_ignore("narrowing_conversion")
		var button = grid_container.get_child(selected_cell.x * 9 + selected_cell.y)
		var style = button.get_theme_stylebox("normal").duplicate()
		# If it's a wrong number, keep the red background, otherwise use selection color
		if sudoku.is_wrong_number(selected_cell.x, selected_cell.y):
			# Wrong number - keep red but maybe make it slightly brighter
			style.set_bg_color(Color(1.0, 0.2, 0.2, 1.0))
			# style.set_border_width_all(3)
			# style.set_border_color(Color(1.0, 0.0, 0.0, 1.0))
			button.add_theme_stylebox_override("normal", style)
			# Also update hover/focus to maintain red
			var hover_style = style.duplicate()
			hover_style.set_bg_color(Color(1.0, 0.3, 0.3, 1.0))
			button.add_theme_stylebox_override("hover", hover_style)
			var focus_style = style.duplicate()
			focus_style.set_bg_color(Color(1.0, 0.3, 0.3, 1.0))
			button.add_theme_stylebox_override("focus", focus_style)
		else:
			style.set_bg_color(get_current_theme_color("CLR_SELECT"))
			button.add_theme_stylebox_override("normal", style)

	# 3. Highlight logic by mode (but preserve wrong number highlighting)
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
							# Preserve wrong number highlighting
							if not sudoku.is_wrong_number(r, c):
								block_style.set_bg_color(get_current_theme_color("CLR_BLOCK"))
							block_button.add_theme_stylebox_override("normal", block_style)
		for row in range(9):
			for col in range(9):
				if sudoku.grid[row][col] == highlight_number:
					# Highlight Row
					for c in range(9):
						var row_button = grid_container.get_child(row * 9 + c)
						var row_style = row_button.get_theme_stylebox("normal").duplicate()
						# Preserve wrong number highlighting
						if not sudoku.is_wrong_number(row, c):
							row_style.set_bg_color(get_current_theme_color("CLR_PLUS"))
						row_button.add_theme_stylebox_override("normal", row_style)
					# Highlight Column
					for r in range(9):
						var col_button = grid_container.get_child(r * 9 + col)
						var col_style = col_button.get_theme_stylebox("normal").duplicate()
						# Preserve wrong number highlighting
						if not sudoku.is_wrong_number(r, col):
							col_style.set_bg_color(get_current_theme_color("CLR_PLUS"))
						col_button.add_theme_stylebox_override("normal", col_style)
				if sudoku.has_exclude_mark(row, col, highlight_number):
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					# Preserve wrong number highlighting
					if not sudoku.is_wrong_number(row, col):
						style.set_bg_color(get_current_theme_color("CLR_BLOCK"))
					button.add_theme_stylebox_override("normal", style)
				if sudoku.grid[row][col] == highlight_number:
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					# Preserve wrong number highlighting
					if not sudoku.is_wrong_number(row, col):
						style.set_bg_color(get_current_theme_color("CLR_SAME"))
					button.add_theme_stylebox_override("normal", style)
	elif highlight_mode == HighlightMode.PENCIL and highlight_number != 0:
		# Highlight all cells WITHOUT the pencil mark as unavailable
		for row in range(9):
			for col in range(9):
				if not sudoku.has_pencil_mark(row, col, highlight_number):
					var button = grid_container.get_child(row * 9 + col)
					var style = button.get_theme_stylebox("normal").duplicate()
					# Preserve wrong number highlighting
					if not sudoku.is_wrong_number(row, col):
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
					# Preserve wrong number highlighting
					if not sudoku.is_wrong_number(row, col):
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
			# Preserve wrong number highlighting
			if not sudoku.is_wrong_number(selected_cell.x, i):
				row_style.set_bg_color(get_current_theme_color("CLR_PLUS"))
			if not sudoku.is_wrong_number(i, selected_cell.y):
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
			# Preserve wrong number highlighting
			if not sudoku.is_wrong_number(selected_cell.x, i):
				row_style.set_bg_color(get_current_theme_color("CLR_PLUS"))
			if not sudoku.is_wrong_number(i, selected_cell.y):
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
				# Preserve wrong number highlighting
				if not sudoku.is_wrong_number(r, c):
					block_style.set_bg_color(get_current_theme_color("CLR_BLOCK"))
				block_button.add_theme_stylebox_override("normal", block_style)
	
	# Final pass: Ensure wrong numbers are always highlighted (highest priority)
	# This runs after all other highlights to ensure wrong numbers are always visible
	# Also update hover and focus styles for wrong numbers
	for row in range(9):
		for col in range(9):
			if sudoku.is_wrong_number(row, col):
				var button = grid_container.get_child(row * 9 + col)
				# Update normal style
				var style = button.get_theme_stylebox("normal").duplicate()
				style.set_bg_color(get_current_theme_color("CLR_MISTAKE_FLASH"))
				# style.set_border_width_all(2)
				# style.set_border_color(Color(1.0, 0.0, 0.0, 1.0))
				button.add_theme_stylebox_override("normal", style)
				
				# Update hover style to also show red for wrong numbers
				var hover_style = style.duplicate()
				hover_style.set_bg_color(Color(1.0, 0.2, 0.2, 1.0))  # Slightly brighter red on hover
				# hover_style.set_border_width_all(3)
				# hover_style.set_border_color(Color(1.0, 0.0, 0.0, 1.0))
				button.add_theme_stylebox_override("hover", hover_style)
				
				# Update focus style to also show red for wrong numbers
				var focus_style = style.duplicate()
				focus_style.set_bg_color(Color(1.0, 0.2, 0.2, 1.0))  # Slightly brighter red when focused
				# focus_style.set_border_width_all(3)
				# focus_style.set_border_color(Color(1.0, 0.0, 0.0, 1.0))
				button.add_theme_stylebox_override("focus", focus_style)

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
	menu_panel.hide()
	
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
	# Menu panel stays hidden (user can toggle it if needed)

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
	var popup_width = min(window_size.x * 0.9, 600)
	var popup_height = min(window_size.y * 0.85, 800)
	popup.set_size(Vector2(popup_width, popup_height))
	popup.name = "PuzzleSelectionPopup"
	add_child(popup)

	# Apply theme to popup - use cached and updated theme resource
	var theme_resource = _get_or_create_theme_resource()
	if theme_resource:
		popup.theme = theme_resource

	# Improve popup panel styling
	var panel_style = StyleBoxFlat.new()
	panel_style.set_bg_color(get_current_theme_color("CLR_SURFACE"))
	panel_style.set_border_width_all(3)
	panel_style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
	panel_style.set_corner_radius_all(16)
	panel_style.set_shadow_color(Color(0, 0, 0, 0.5))
	panel_style.set_shadow_size(16)
	popup.add_theme_stylebox_override("panel", panel_style)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	popup.add_child(vbox)

	# Calculate consistent font sizes based on viewport
	var fonts = _calculate_font_sizes()
	var title_height = max(int(window_size.y * 0.06), 45)
	var label_height = max(int(window_size.y * 0.04), 32)
	
	# Title label
	var title_label = Label.new()
	title_label.text = "Select Puzzle"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.set_custom_minimum_size(Vector2(0, title_height))
	title_label.add_theme_font_size_override("font_size", fonts.large)
	title_label.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_HEADER"))
	vbox.add_child(title_label)

	# Difficulty selector with label
	var difficulty_label = Label.new()
	difficulty_label.text = "Difficulty Level:"
	difficulty_label.set_custom_minimum_size(Vector2(0, label_height))
	difficulty_label.add_theme_font_size_override("font_size", fonts.medium)
	difficulty_label.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_LABEL"))
	vbox.add_child(difficulty_label)

	var difficulty_options = OptionButton.new()
	for difficulty in sudoku.puzzles.keys():
		difficulty_options.add_item(difficulty.capitalize())

	# Style the option button
	var button_style = StyleBoxFlat.new()
	button_style.set_bg_color(get_current_theme_color("CLR_SURFACE_VARIANT"))
	button_style.set_border_width_all(2)
	button_style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
	button_style.set_corner_radius_all(8)
	difficulty_options.add_theme_stylebox_override("normal", button_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.set_bg_color(get_current_theme_color("CLR_SELECT"))
	hover_style.set_border_width_all(2)
	hover_style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
	hover_style.set_corner_radius_all(8)
	difficulty_options.add_theme_stylebox_override("hover", hover_style)

	var selector_height = max(int(window_size.y * 0.07), 50)
	var dropdown_font_color = get_current_theme_color("CLR_FONT_LABEL")
	difficulty_options.set_custom_minimum_size(Vector2(popup_width * 0.92, selector_height))
	difficulty_options.add_theme_font_size_override("font_size", fonts.medium)
	difficulty_options.add_theme_color_override("font_color", dropdown_font_color)
	difficulty_options.add_theme_color_override("font_hover_color", dropdown_font_color)
	difficulty_options.add_theme_color_override("font_pressed_color", dropdown_font_color)
	difficulty_options.add_theme_color_override("font_disabled_color", dropdown_font_color)

	# Style the dropdown popup (PopupMenu)
	var popup_panel = difficulty_options.get_popup()
	var popup_style = StyleBoxFlat.new()
	popup_style.set_bg_color(get_current_theme_color("CLR_SURFACE"))
	popup_style.set_border_width_all(2)
	popup_style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
	popup_style.set_corner_radius_all(8)
	popup_panel.add_theme_stylebox_override("panel", popup_style)

	popup_panel.add_theme_font_size_override("font_size", fonts.medium)
	popup_panel.add_theme_color_override("font_color", dropdown_font_color)
	popup_panel.add_theme_color_override("font_hover_color", dropdown_font_color)
	popup_panel.add_theme_color_override("font_accelerator_color", dropdown_font_color)
	popup_panel.add_theme_color_override("font_separator_color", dropdown_font_color)
	popup_panel.add_theme_color_override("font_disabled_color", get_current_theme_color("CLR_FONT_GIVEN_NUMBER"))

	var popup_hover_style = StyleBoxFlat.new()
	popup_hover_style.set_bg_color(get_current_theme_color("CLR_SELECT"))
	popup_hover_style.set_border_width_all(1)
	popup_hover_style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
	popup_panel.add_theme_stylebox_override("hover", popup_hover_style)
	
	var popup_selected_style = StyleBoxFlat.new()
	popup_selected_style.set_bg_color(get_current_theme_color("CLR_SURFACE_VARIANT"))
	popup_selected_style.set_border_width_all(1)
	popup_selected_style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
	popup_panel.add_theme_stylebox_override("selected", popup_selected_style)
	
	# Also set the normal style for menu items
	var popup_normal_style = StyleBoxFlat.new()
	popup_normal_style.set_bg_color(get_current_theme_color("CLR_SURFACE"))
	popup_panel.add_theme_stylebox_override("normal", popup_normal_style)

	difficulty_options.selected = sudoku.difficulty_index[sudoku.puzzle_selected]
	vbox.add_child(difficulty_options)

	var scroll_container = ScrollContainer.new()
	scroll_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	scroll_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)

	# Style the scroll container
	var scroll_style = StyleBoxFlat.new()
	scroll_style.set_bg_color(get_current_theme_color("CLR_BACKGROUND"))
	scroll_style.set_border_width_all(2)
	scroll_style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
	scroll_style.set_corner_radius_all(8)
	scroll_container.add_theme_stylebox_override("panel", scroll_style)

	vbox.add_child(scroll_container)

	var puzzle_list = VBoxContainer.new()
	puzzle_list.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	puzzle_list.add_theme_constant_override("separation", 12)
	scroll_container.add_child(puzzle_list)

	difficulty_options.connect("item_selected", self._on_difficulty_selected.bind(puzzle_list, scroll_container))
	
	# Add fade-in animation
	vbox.modulate = Color(1, 1, 1, 0)
	popup.popup_centered()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(vbox, "modulate", Color(1, 1, 1, 1), 0.3)
	
	# Defer initial puzzle list loading to prevent UI lockup
	# Wait a frame for popup to be properly sized before loading
	call_deferred("_on_difficulty_selected", sudoku.difficulty_index[sudoku.puzzle_selected], puzzle_list, scroll_container)

# Store lazy loading state
var puzzle_list_loaded_indices: Dictionary = {}  # puzzle_list -> Set of loaded indices
var puzzle_list_metadata: Dictionary = {}  # puzzle_list -> {difficulty, completed_puzzles, popup_width, item_height, fonts, puzzle_count}

func _on_difficulty_selected(index: int, puzzle_list: VBoxContainer, scroll_container: ScrollContainer):
	if not is_instance_valid(puzzle_list) or not is_instance_valid(scroll_container):
		return
		
	var difficulty = sudoku.puzzles.keys()[index]
	var window_size = get_viewport().get_visible_rect().size
	print("Selected difficulty:", difficulty)
	print("Window size:", window_size)

	# Clear existing children (but not the timer which is a child of scroll_container)
	for child in puzzle_list.get_children():
		child.queue_free()
	
	# Clean up metadata
	puzzle_list_loaded_indices.erase(puzzle_list)
	puzzle_list_metadata.erase(puzzle_list)
	last_scroll_position.erase(puzzle_list)

	var completed_puzzles = _load_completed_puzzles(difficulty)

	print("Number of puzzles:", sudoku.get_puzzle_count())
	sudoku.load_puzzle_data(difficulty)
	
	# Store metadata for lazy loading
	var popup = get_node_or_null("PuzzleSelectionPopup")
	var popup_width = popup.size.x if popup else min(window_size.y, window_size.x) * 0.8
	var item_height = max(int(window_size.y * 0.1), 64)
	var fonts = _calculate_font_sizes()
	var puzzle_count = sudoku.get_puzzle_count()
	
	puzzle_list_metadata[puzzle_list] = {
		"difficulty": difficulty,
		"completed_puzzles": completed_puzzles,
		"popup_width": popup_width,
		"item_height": item_height,
		"fonts": fonts,
		"puzzle_count": puzzle_count
	}
	puzzle_list_loaded_indices[puzzle_list] = []
	
	# Set up lazy loading timer after metadata is set
	_setup_lazy_loading_timer(scroll_container, puzzle_list)
	
	# Defer save state loading and initial visible items
	call_deferred("_load_save_states_and_setup_lazy_loading", difficulty, puzzle_list, scroll_container, completed_puzzles, window_size)

func _setup_lazy_loading_timer(scroll_container: ScrollContainer, puzzle_list: VBoxContainer):
	# Remove old timer if it exists
	var old_timer = scroll_container.get_node_or_null("ScrollTimer")
	if old_timer:
		old_timer.queue_free()
	
	# Set up lazy loading timer to check scroll position periodically
	var scroll_timer = Timer.new()
	scroll_timer.wait_time = 0.1  # Check every 100ms
	scroll_timer.timeout.connect(_check_puzzle_list_scroll.bind(scroll_container, puzzle_list))
	scroll_timer.autostart = true
	scroll_container.add_child(scroll_timer)
	scroll_timer.name = "ScrollTimer"
	
	# Also trigger on scroll container resize
	if scroll_container.resized.is_connected(_on_scroll_container_resized):
		scroll_container.resized.disconnect(_on_scroll_container_resized)
	scroll_container.resized.connect(_on_scroll_container_resized.bind(scroll_container, puzzle_list))

func _on_scroll_container_resized(scroll_container: ScrollContainer, puzzle_list: VBoxContainer):
	# Trigger loading when container is resized (e.g., popup opens)
	call_deferred("_load_visible_puzzle_items", puzzle_list, scroll_container)

func _load_save_states_and_setup_lazy_loading(difficulty: String, puzzle_list: VBoxContainer, scroll_container: ScrollContainer, completed_puzzles: Dictionary, window_size: Vector2):
	if not is_instance_valid(puzzle_list) or not is_instance_valid(scroll_container):
		return
		
	sudoku.fast_load_save_states(SAVE_STATE_PATH)
	
	# Create spacers for all puzzles to maintain proper scrollbar size
	var metadata = puzzle_list_metadata.get(puzzle_list, {})
	if metadata.is_empty():
		return
		
	var puzzle_count = metadata.puzzle_count
	var item_height = metadata.item_height
	
	# Create spacer nodes for all puzzles (lightweight placeholders)
	for i in range(puzzle_count):
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, item_height)
		spacer.name = "spacer_%d" % i
		puzzle_list.add_child(spacer)
	
	# Load initial visible items after a short delay to ensure container is sized
	await get_tree().create_timer(0.1).timeout
	_load_visible_puzzle_items(puzzle_list, scroll_container)

var last_scroll_position: Dictionary = {}  # puzzle_list -> last scroll position

func _check_puzzle_list_scroll(scroll_container: ScrollContainer, puzzle_list: VBoxContainer):
	if not is_instance_valid(puzzle_list) or not is_instance_valid(scroll_container):
		return
		
	var current_scroll = scroll_container.scroll_vertical
	var last_scroll = last_scroll_position.get(puzzle_list, -1.0)
	
	# Only check if scroll position changed significantly (more than 10 pixels)
	if abs(current_scroll - last_scroll) > 10.0:
		last_scroll_position[puzzle_list] = current_scroll
		_load_visible_puzzle_items(puzzle_list, scroll_container)

func _load_visible_puzzle_items(puzzle_list: VBoxContainer, scroll_container: ScrollContainer):
	if not is_instance_valid(puzzle_list) or not is_instance_valid(scroll_container):
		return
		
	if not puzzle_list_metadata.has(puzzle_list):
		return
		
	var metadata = puzzle_list_metadata[puzzle_list]
	var difficulty = metadata.difficulty
	var completed_puzzles = metadata.completed_puzzles
	var popup_width = metadata.popup_width
	var item_height = metadata.item_height
	var fonts = metadata.fonts
	var puzzle_count = metadata.puzzle_count
	
	# Calculate visible range
	var scroll_offset = scroll_container.scroll_vertical
	var visible_height = scroll_container.size.y
	
	# If container doesn't have a size yet, load first few items anyway
	if visible_height <= 0:
		visible_height = item_height * 10  # Assume ~10 items visible
	
	var buffer = visible_height * 0.5  # Load items slightly outside visible area
	
	var start_index = max(0, int((scroll_offset - buffer) / item_height))
	var end_index = min(puzzle_count, int((scroll_offset + visible_height + buffer) / item_height) + 1)
	
	# Ensure we load at least the first few items
	if end_index <= start_index:
		end_index = min(puzzle_count, start_index + 20)
	
	# Load items in visible range
	var loaded_set = puzzle_list_loaded_indices.get(puzzle_list, [])
	var loaded_count = 0
	for i in range(start_index, end_index):
		if i in loaded_set:
			continue  # Already loaded
			
		# Replace spacer with actual puzzle row
		var spacer = puzzle_list.get_node_or_null("spacer_%d" % i)
		if spacer:
			_create_puzzle_row(puzzle_list, i, difficulty, completed_puzzles, popup_width, item_height, fonts)
			spacer.queue_free()
			loaded_set.append(i)
			loaded_count += 1
	
	puzzle_list_loaded_indices[puzzle_list] = loaded_set
	
	if loaded_count > 0:
		print("Loaded %d puzzle items (range %d-%d)" % [loaded_count, start_index, end_index])

func _create_puzzle_row(puzzle_list: VBoxContainer, index: int, difficulty: String, completed_puzzles: Dictionary, popup_width: float, item_height: int, fonts: Dictionary):
	var puzzle_data = sudoku.get_puzzle_data(index)
	if not puzzle_data:
		return
		
	# Pre-calculate theme colors once
	var surface_variant_color = get_current_theme_color("CLR_SURFACE_VARIANT")
	var label_color = get_current_theme_color("CLR_FONT_LABEL")
	var border_color = get_current_theme_color("CLR_GRID_BORDER")
	var select_color = get_current_theme_color("CLR_SELECT")
	var pressed_color = surface_variant_color.darkened(0.1) if current_theme == ThemeType.DARK else surface_variant_color.lightened(0.05)
	
	# Pre-create reusable style boxes
	var btn_normal_template = StyleBoxFlat.new()
	btn_normal_template.set_bg_color(surface_variant_color)
	btn_normal_template.set_border_width_all(2)
	btn_normal_template.set_border_color(border_color)
	btn_normal_template.set_corner_radius_all(6)
	
	var btn_hover_template = btn_normal_template.duplicate()
	btn_hover_template.set_bg_color(select_color)
	
	var btn_pressed_template = btn_normal_template.duplicate()
	btn_pressed_template.set_bg_color(pressed_color)
	
	var puzzle_row = preload("res://loadListItem.tscn").instantiate()
	puzzle_row.custom_minimum_size = Vector2(popup_width * 0.90, item_height)
	puzzle_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Insert at correct position, replacing spacer
	var spacer = puzzle_list.get_node_or_null("spacer_%d" % index)
	if spacer and is_instance_valid(spacer):
		var spacer_index = spacer.get_index()
		puzzle_list.remove_child(spacer)
		spacer.queue_free()
		puzzle_list.add_child(puzzle_row)
		puzzle_list.move_child(puzzle_row, spacer_index)
	else:
		# Spacer not found, just add at end (shouldn't happen but handle gracefully)
		puzzle_list.add_child(puzzle_row)
	
	# Update ColorRect background to use theme colors
	var color_rect = puzzle_row.find_child("ColorRect")
	if color_rect:
		color_rect.color = surface_variant_color
	
	# Update labels with better formatting
	var puzzle_num = index + 1
	_set_label_text(puzzle_row, "Index", "#%d" % puzzle_num)
	_set_label_text(puzzle_row, "Difficulty", difficulty.capitalize())
	
	var completed_time = ""
	var has_completion = completed_puzzles.has(index)
	if has_completion:
		completed_time = "✓ " + _format_time(completed_puzzles[index])
	else:
		completed_time = "Not completed"
	_set_label_text(puzzle_row, "Time", completed_time)
	
	# Ensure all labels have proper colors
	_apply_label_colors(puzzle_row, label_color)
	
	# Connect buttons with descriptive text
	_connect_button(puzzle_row, "Res", self._on_resume_button_pressed.bind(difficulty, index), index, difficulty)
	_connect_button(puzzle_row, "New", self._on_load_puzzle_pressed.bind(difficulty, index), index, difficulty)
	
	# Style buttons for better visibility (reuse pre-created style boxes)
	var resume_btn = puzzle_row.find_child("Res")
	var new_btn = puzzle_row.find_child("New")
	var btn_height = max(int(item_height * 0.75), 48)
	
	if resume_btn:
		resume_btn.text = "▶ Resume"
		resume_btn.set_custom_minimum_size(Vector2(popup_width * 0.16, btn_height))
		resume_btn.add_theme_font_size_override("font_size", fonts.medium)
		resume_btn.add_theme_color_override("font_color", label_color)
		resume_btn.add_theme_stylebox_override("normal", btn_normal_template.duplicate())
		resume_btn.add_theme_stylebox_override("hover", btn_hover_template.duplicate())
		resume_btn.add_theme_stylebox_override("pressed", btn_pressed_template.duplicate())
		
	if new_btn:
		new_btn.text = "🆕 New"
		new_btn.set_custom_minimum_size(Vector2(popup_width * 0.16, btn_height))
		new_btn.add_theme_font_size_override("font_size", fonts.medium)
		new_btn.add_theme_color_override("font_color", label_color)
		new_btn.add_theme_stylebox_override("normal", btn_normal_template.duplicate())
		new_btn.add_theme_stylebox_override("hover", btn_hover_template.duplicate())
		new_btn.add_theme_stylebox_override("pressed", btn_pressed_template.duplicate())

func _populate_puzzle_list_batched(puzzle_list: VBoxContainer, difficulty: String, completed_puzzles: Dictionary, popup_width: float, item_height: int, fonts: Dictionary, puzzle_count: int):
	# Pre-calculate theme colors once to avoid repeated calls
	var surface_variant_color = get_current_theme_color("CLR_SURFACE_VARIANT")
	var label_color = get_current_theme_color("CLR_FONT_LABEL")
	var border_color = get_current_theme_color("CLR_GRID_BORDER")
	var select_color = get_current_theme_color("CLR_SELECT")
	var pressed_color = surface_variant_color.darkened(0.1) if current_theme == ThemeType.DARK else surface_variant_color.lightened(0.05)
	
	# Pre-create reusable style boxes
	var btn_normal_template = StyleBoxFlat.new()
	btn_normal_template.set_bg_color(surface_variant_color)
	btn_normal_template.set_border_width_all(2)
	btn_normal_template.set_border_color(border_color)
	btn_normal_template.set_corner_radius_all(6)
	
	var btn_hover_template = btn_normal_template.duplicate()
	btn_hover_template.set_bg_color(select_color)
	
	var btn_pressed_template = btn_normal_template.duplicate()
	btn_pressed_template.set_bg_color(pressed_color)
	
	# Process puzzles in batches of 10 to keep UI responsive
	const BATCH_SIZE = 10
	var current_index = 0
	
	while current_index < puzzle_count:
		# Process one batch
		var end_index = min(current_index + BATCH_SIZE, puzzle_count)
		for i in range(current_index, end_index):
			var puzzle_data = sudoku.get_puzzle_data(i)
			if puzzle_data:
				var puzzle_row = preload("res://loadListItem.tscn").instantiate()
				puzzle_row.custom_minimum_size = Vector2(popup_width * 0.90, item_height)
				puzzle_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

				# Add to tree first so it can access theme colors
				puzzle_list.add_child(puzzle_row)
				
				# Update ColorRect background to use theme colors
				var color_rect = puzzle_row.find_child("ColorRect")
				if color_rect:
					color_rect.color = surface_variant_color
				
				# Update labels with better formatting
				var puzzle_num = i + 1
				_set_label_text(puzzle_row, "Index", "#%d" % puzzle_num)
				_set_label_text(puzzle_row, "Difficulty", difficulty.capitalize())
				
				var completed_time = ""
				var has_completion = completed_puzzles.has(i)
				if has_completion:
					completed_time = "✓ " + _format_time(completed_puzzles[i])
				else:
					completed_time = "Not completed"
				_set_label_text(puzzle_row, "Time", completed_time)
				
				# Ensure all labels have proper colors (in case load_list_item didn't apply them)
				_apply_label_colors(puzzle_row, label_color)
				
				# Connect buttons with descriptive text
				_connect_button(puzzle_row, "Res", self._on_resume_button_pressed.bind(difficulty, i), i, difficulty)
				_connect_button(puzzle_row, "New", self._on_load_puzzle_pressed.bind(difficulty, i), i, difficulty)
				
				# Style buttons for better visibility (reuse pre-created style boxes)
				var resume_btn = puzzle_row.find_child("Res")
				var new_btn = puzzle_row.find_child("New")
				var btn_height = max(int(item_height * 0.75), 48)
				
				if resume_btn:
					resume_btn.text = "▶ Resume"
					resume_btn.set_custom_minimum_size(Vector2(popup_width * 0.16, btn_height))
					resume_btn.add_theme_font_size_override("font_size", fonts.medium)
					resume_btn.add_theme_color_override("font_color", label_color)
					resume_btn.add_theme_stylebox_override("normal", btn_normal_template.duplicate())
					resume_btn.add_theme_stylebox_override("hover", btn_hover_template.duplicate())
					resume_btn.add_theme_stylebox_override("pressed", btn_pressed_template.duplicate())
					
				if new_btn:
					new_btn.text = "🆕 New"
					new_btn.set_custom_minimum_size(Vector2(popup_width * 0.16, btn_height))
					new_btn.add_theme_font_size_override("font_size", fonts.medium)
					new_btn.add_theme_color_override("font_color", label_color)
					new_btn.add_theme_stylebox_override("normal", btn_normal_template.duplicate())
					new_btn.add_theme_stylebox_override("hover", btn_hover_template.duplicate())
					new_btn.add_theme_stylebox_override("pressed", btn_pressed_template.duplicate())
		
		current_index = end_index
		
		# Yield every batch to keep UI responsive
		if current_index < puzzle_count:
			await get_tree().process_frame
	
	# Force layout update
	puzzle_list.queue_sort()

	# Ensure the ScrollContainer updates its scroll size
	var scroll_container = puzzle_list.get_parent()
	if scroll_container is ScrollContainer:
		scroll_container.queue_sort()

# Helper function to set label text and color
func _set_label_text(parent: Node, label_name: String, text: String):
	var label = parent.find_child(label_name)
	if label and (label is Label or label is TextEdit):
		label.text = text
		if label is Label:
			label.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_LABEL"))
	else:
		print("Warning: Label '%s' not found or not a Label node" % label_name)

# Helper function to apply colors to all labels recursively
func _apply_label_colors(node: Node, color: Color):
	if node is Label:
		node.add_theme_color_override("font_color", color)
	for child in node.get_children():
		_apply_label_colors(child, color)

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
	var number_font_color = get_current_theme_color("CLR_FONT_REGULAR_NUMBER")
	for button in number_buttons.get_children():
		button.set_custom_minimum_size(Vector2(button_size*(1.5), button_size*(1.5)))
		button.add_theme_font_size_override("font_size", button_size*0.75)
		button.add_theme_color_override("font_color", number_font_color)

func _calculate_font_sizes() -> Dictionary:
	# Calculate font sizes based on viewport dimensions, not button_size
	# This ensures consistent sizing across all screen sizes
	var size = viewport_size
	if size.x <= 0 or size.y <= 0:
		# Fallback if viewport_size not initialized yet
		size = get_viewport().get_visible_rect().size
	
	var min_dimension = min(size.x, size.y)
	var scale_factor = min_dimension / 600.0  # Base scale for 600px screens
	scale_factor = clamp(scale_factor, 0.7, 2.0)  # Limit scaling range
	
	return {
		"small": max(int(12 * scale_factor), 10),      # Small labels, timers
		"medium": max(int(16 * scale_factor), 13),     # Buttons, menu items
		"large": max(int(20 * scale_factor), 16),      # Headers, titles
		"xlarge": max(int(24 * scale_factor), 18),     # Main titles
	}

func _resize_menu_buttons():
	# Calculate consistent font sizes based on viewport
	var fonts = _calculate_font_sizes()
	
	# Resize top menu bar buttons
	var menu_height = max(int(viewport_size.y * 0.05), 40)  # 5% of viewport height, min 40px
	var button_font_color = get_current_theme_color("CLR_FONT_LABEL")
	for child in top_menu_bar.get_children():
		if child is Button:
			var min_width = min(aspect_container.size.x / 5.0, viewport_size.x * 0.15)
			child.set_custom_minimum_size(Vector2(min_width, menu_height))
			child.add_theme_font_size_override("font_size", fonts.medium)
			child.add_theme_color_override("font_color", button_font_color)
			child.add_theme_color_override("font_hover_color", button_font_color)
			child.add_theme_color_override("font_pressed_color", button_font_color)
			child.add_theme_color_override("font_disabled_color", button_font_color)
			child.add_theme_color_override("font_focus_color", button_font_color)
			
			# Add better styling to menu buttons
			var normal_style = StyleBoxFlat.new()
			normal_style.set_bg_color(get_current_theme_color("CLR_SURFACE"))
			normal_style.set_border_width_all(1)
			normal_style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
			normal_style.set_corner_radius_all(6)
			child.add_theme_stylebox_override("normal", normal_style)
			
			var hover_style = normal_style.duplicate()
			hover_style.set_bg_color(get_current_theme_color("CLR_SURFACE_VARIANT"))
			child.add_theme_stylebox_override("hover", hover_style)
		elif child is Label:
			# Timer label
			child.set_custom_minimum_size(Vector2(0, menu_height))
			child.add_theme_font_size_override("font_size", fonts.medium)
			child.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_LABEL"))
	
	# Resize menu popup if visible
	if menu_panel.visible:
		_resize_menu_popup()
	
	# Resize menu panel buttons - show all content sections in a single list
	if menu_panel.visible:
		var popup_width = menu_panel.size.x
		var button_height = max(int(viewport_size.y * 0.08), 50)  # 8% of viewport height, min 50px
		
		# Ensure all content sections are visible
		play_content.visible = true
		tools_content.visible = true
		settings_content.visible = true
		
		var popup_button_font_color = get_current_theme_color("CLR_FONT_LABEL")
		for content in [play_content, tools_content, settings_content]:
			for child in content.get_children():
				if child is Button:
					child.set_custom_minimum_size(Vector2(popup_width * 0.92, button_height))
					child.add_theme_font_size_override("font_size", fonts.medium)
					child.add_theme_color_override("font_color", popup_button_font_color)
					child.add_theme_color_override("font_hover_color", popup_button_font_color)
					child.add_theme_color_override("font_pressed_color", popup_button_font_color)
					child.add_theme_color_override("font_disabled_color", popup_button_font_color)
					child.add_theme_color_override("font_focus_color", popup_button_font_color)
					
					var normal_style = StyleBoxFlat.new()
					normal_style.set_bg_color(get_current_theme_color("CLR_SURFACE"))
					normal_style.set_border_width_all(2)
					normal_style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
					normal_style.set_corner_radius_all(8)
					child.add_theme_stylebox_override("normal", normal_style)
					
					var hover_style = normal_style.duplicate()
					hover_style.set_bg_color(get_current_theme_color("CLR_SURFACE_VARIANT"))
					child.add_theme_stylebox_override("hover", hover_style)
				elif child is Label:
					child.add_theme_font_size_override("font_size", fonts.medium)
					child.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_LABEL"))
		
		# Resize theme selector and label
		var selector_height = max(int(viewport_size.y * 0.07), 48)
		if theme_selector:
			theme_selector.set_custom_minimum_size(Vector2(popup_width * 0.92, selector_height))
			theme_selector.add_theme_font_size_override("font_size", fonts.medium)
			theme_selector.add_theme_color_override("font_color", popup_button_font_color)
		
		# Style theme label if it exists
		var theme_label = settings_content.find_child("ThemeLabel")
		if theme_label:
			theme_label.add_theme_font_size_override("font_size", fonts.medium)
			theme_label.add_theme_color_override("font_color", get_current_theme_color("CLR_FONT_LABEL"))

	# Resize puzzle info label
	var info_height = max(int(viewport_size.y * 0.04), 30)
	puzzle_info.set_custom_minimum_size(Vector2(aspect_container.size.x/1.5, info_height))
	puzzle_info.add_theme_font_size_override("font_size", fonts.small)
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

func _apply_menu_font_colors():
	# Apply font colors to all menu buttons immediately
	var button_font_color = get_current_theme_color("CLR_FONT_LABEL")
	
	# Top menu bar buttons - always apply colors
	for child in top_menu_bar.get_children():
		if child is Button:
			child.add_theme_color_override("font_color", button_font_color)
			child.add_theme_color_override("font_hover_color", button_font_color)
			child.add_theme_color_override("font_pressed_color", button_font_color)
			child.add_theme_color_override("font_disabled_color", button_font_color)
			child.add_theme_color_override("font_focus_color", button_font_color)
		elif child is Label:
			child.add_theme_color_override("font_color", button_font_color)
	
	# Menu popup buttons - apply colors even when hidden so they're ready
	if menu_panel:
		for content in [play_content, tools_content, settings_content]:
			if content:
				for child in content.get_children():
					if child is Button:
						child.add_theme_color_override("font_color", button_font_color)
						child.add_theme_color_override("font_hover_color", button_font_color)
						child.add_theme_color_override("font_pressed_color", button_font_color)
						child.add_theme_color_override("font_disabled_color", button_font_color)
						child.add_theme_color_override("font_focus_color", button_font_color)
					elif child is Label:
						child.add_theme_color_override("font_color", button_font_color)
		
		# Theme selector
		if theme_selector:
			theme_selector.add_theme_color_override("font_color", button_font_color)
			theme_selector.add_theme_color_override("font_hover_color", button_font_color)
			theme_selector.add_theme_color_override("font_pressed_color", button_font_color)
			theme_selector.add_theme_color_override("font_disabled_color", button_font_color)
		
		# Theme label
		var theme_label = settings_content.find_child("ThemeLabel") if settings_content else null
		if theme_label:
			theme_label.add_theme_color_override("font_color", button_font_color)

func _on_menu_toggle_pressed():
	if menu_panel.visible:
		menu_panel.hide()
		menu_toggle_button.text = "☰ Menu"
	else:
		_resize_menu_popup()
		menu_panel.popup_centered()
		menu_toggle_button.text = "☰ Close"
		# Ensure all font colors are applied when menu opens
		await get_tree().process_frame
		_apply_menu_font_colors()
		_resize_menu_buttons()

func _on_menu_popup_hide():
	menu_toggle_button.text = "☰ Menu"

func _setup_menu_popup():
	# Style the menu popup panel
	var panel_style = StyleBoxFlat.new()
	panel_style.set_bg_color(get_current_theme_color("CLR_SURFACE"))
	panel_style.set_border_width_all(3)
	panel_style.set_border_color(get_current_theme_color("CLR_GRID_BORDER"))
	panel_style.set_corner_radius_all(16)
	panel_style.set_shadow_color(Color(0, 0, 0, 0.5))
	panel_style.set_shadow_size(16)
	menu_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Set initial size
	_resize_menu_popup()

func _resize_menu_popup():
	var window_size = get_viewport().get_visible_rect().size
	var popup_width = min(window_size.x * 0.9, 500)
	var popup_height = min(window_size.y * 0.8, 600)
	menu_panel.set_size(Vector2(popup_width, popup_height))

func _update_highlight_button_text():
	match highlight_mode:
		HighlightMode.SAME:
			highlight_button.text = "Highlight Same Number"
		HighlightMode.CROSS:
			highlight_button.text = "Cross Highlight"
		HighlightMode.REGION:
			highlight_button.text = "Cross and Region Highlight"
		HighlightMode.FULL:
			highlight_button.text = "Cross and Region for All"
		HighlightMode.PENCIL:
			highlight_button.text = "Highlight Pencil Marks"
