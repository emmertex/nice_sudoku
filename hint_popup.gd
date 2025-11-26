extends Panel

signal hint_dismissed
signal next_hint_requested
signal next_step_requested(hint)
signal prev_step_requested(hint)
signal hint_selected(hint)

var hints: Array[Hint] = []
var current_hint_index: int = 0

@onready var title_label = $VBoxContainer/TitleLabel
@onready var description_label = $VBoxContainer/Scroll/PanelContainer/DescriptionLabel
@onready var next_button = $VBoxContainer/Scroll/PanelContainer/HBoxContainer/NextButton
@onready var prev_button = $VBoxContainer/Scroll/PanelContainer/HBoxContainer/PrevButton
@onready var next_hint_button = $VBoxContainer/Scroll/PanelContainer/HBoxContainer/NextHintButton
@onready var dismiss_button = $VBoxContainer/Scroll/PanelContainer/HBoxContainer/DismissButton

func _ready():
	next_button.pressed.connect(_on_next_step_pressed)
	prev_button.pressed.connect(_on_prev_step_pressed)
	next_hint_button.pressed.connect(_on_next_hint_pressed)
	dismiss_button.pressed.connect(_on_dismiss_pressed)

func _get_theme_color(color_name: String) -> Color:
	# Try to get theme color from game_screen through scene tree
	var game_screen = get_tree().get_first_node_in_group("game_screen")
	if game_screen and game_screen.has_method("get_current_theme_color"):
		return game_screen.get_current_theme_color(color_name)
	# Fallback: use theme if available
	match color_name:
		"CLR_SURFACE":
			if has_theme_color("font_color", "Label"):
				return get_theme_color("font_color", "Label")
			return Color(0.2, 0.2, 0.2, 1)
		"CLR_GRID_BORDER":
			return Color(0.3, 0.3, 0.3, 1)
		"CLR_FONT_LABEL":
			if has_theme_color("font_color", "Label"):
				return get_theme_color("font_color", "Label")
			return Color(0.2, 0.2, 0.2, 1)
		"CLR_FONT_HEADER":
			if has_theme_color("font_color", "Label"):
				return get_theme_color("font_color", "Label")
			return Color(0.2, 0.2, 0.2, 1)
		_:
			return Color(0.2, 0.2, 0.2, 1)

func setup_ui(font_size: int):
	description_label.add_theme_font_size_override("font_size", font_size)
	description_label.scroll_active = true
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_button.add_theme_font_size_override("font_size", font_size)
	prev_button.add_theme_font_size_override("font_size", font_size)
	next_hint_button.add_theme_font_size_override("font_size", font_size)
	dismiss_button.add_theme_font_size_override("font_size", font_size)
	
	# Set font colors using theme
	var label_color = _get_theme_color("CLR_FONT_LABEL")
	var header_color = _get_theme_color("CLR_FONT_HEADER")
	title_label.add_theme_color_override("font_color", header_color)
	description_label.add_theme_color_override("default_color", label_color)
	next_button.add_theme_color_override("font_color", label_color)
	prev_button.add_theme_color_override("font_color", label_color)
	next_hint_button.add_theme_color_override("font_color", label_color)
	dismiss_button.add_theme_color_override("font_color", label_color)
	
	# Style buttons with theme colors
	var surface_color = _get_theme_color("CLR_SURFACE")
	var border_color = _get_theme_color("CLR_GRID_BORDER")
	
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = surface_color
	button_style.set_border_width_all(1)
	button_style.border_color = border_color
	button_style.set_corner_radius_all(3)

	next_button.add_theme_stylebox_override("normal", button_style)
	prev_button.add_theme_stylebox_override("normal", button_style)
	next_hint_button.add_theme_stylebox_override("normal", button_style)
	dismiss_button.add_theme_stylebox_override("normal", button_style)
	
	# Add hover style
	var hover_style = button_style.duplicate()
	var surface_variant = surface_color.lerp(Color(1, 1, 1, 1) if surface_color.r < 0.5 else Color(0, 0, 0, 1), 0.1)
	hover_style.bg_color = surface_variant
	next_button.add_theme_stylebox_override("hover", hover_style)
	prev_button.add_theme_stylebox_override("hover", hover_style)
	next_hint_button.add_theme_stylebox_override("hover", hover_style)
	dismiss_button.add_theme_stylebox_override("hover", hover_style)

func set_hints(p_hints: Array[Hint]):
	self.hints = p_hints
	current_hint_index = 0
	if hints.is_empty():
		description_label.text = "No hints available."
		next_button.disabled = true
		prev_button.disabled = true
		next_hint_button.disabled = true
	else:
		_show_hint(current_hint_index)

func _show_hint(index: int):
	var hint = hints[index]
	title_label.text = hint.title
	description_label.text = hint.get_active_description()
	# Ensure scroll resets to top for each step/hint
	description_label.scroll_to_line(0)
	next_hint_button.disabled = (hints.size() <= 1)
	prev_button.disabled = not hint.has_steps() or hint.get_active_step_index() <= 0
	next_button.disabled = not hint.has_steps() or hint.get_active_step_index() >= (hint.steps.size() - 1)
	emit_signal("hint_selected", hint)

func _on_next_hint_pressed():
	current_hint_index = (current_hint_index + 1) % hints.size()
	_show_hint(current_hint_index)
	emit_signal("next_hint_requested", hints[current_hint_index])

func _on_next_step_pressed():
	var hint = hints[current_hint_index]
	if hint.has_steps():
		hint.set_active_step(hint.get_active_step_index() + 1)
		_show_hint(current_hint_index)
		emit_signal("next_step_requested", hint)

func _on_prev_step_pressed():
	var hint = hints[current_hint_index]
	if hint.has_steps():
		hint.set_active_step(hint.get_active_step_index() - 1)
		_show_hint(current_hint_index)
		emit_signal("prev_step_requested", hint)

func _on_dismiss_pressed():
	emit_signal("hint_dismissed")
	queue_free() 
