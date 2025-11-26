extends Control

@export var base_width = 340
@export var base_font_size = 16
@export var base_height = 64  # Finger-friendly minimum height

func _ready():
	# Connect to parent resize if parent exists
	var parent = get_parent()
	if parent:
		if parent.resized.is_connected(_on_parent_resized):
			parent.resized.disconnect(_on_parent_resized)
		parent.resized.connect(_on_parent_resized)
		_on_parent_resized()

func _on_parent_resized():
	var parent = get_parent()
	if not parent:
		return
	
	var parent_width = parent.size.x
	if parent_width <= 0:
		return
	
	# Get item height from custom_minimum_size if set, otherwise use base_height
	var item_height = custom_minimum_size.y if custom_minimum_size.y > 0 else base_height
	item_height = max(item_height, 64)  # Ensure minimum touch target
	
	# Calculate consistent sizing
	var item_width = parent_width * 0.98
	if custom_minimum_size.y <= 0:
		custom_minimum_size = Vector2(item_width, item_height)
	else:
		custom_minimum_size.x = item_width
	
	# Calculate font size based on item height - use a consistent ratio
	# For 64px height, we want ~16px font (25% ratio)
	# Scale proportionally but maintain readability
	var scale_factor = item_height / 64.0
	var label_font_size = max(int(16 * scale_factor), 14)
	var button_font_size = max(int(15 * scale_factor), 13)
	
	# Scale font sizes and control sizes
	_scale_controls(self, label_font_size, button_font_size, item_height)

func _get_theme_font_color() -> Color:
	# Try to get theme color from game_screen through scene tree
	var game_screen = get_tree().get_first_node_in_group("game_screen")
	if game_screen and game_screen.has_method("get_current_theme_color"):
		return game_screen.get_current_theme_color("CLR_FONT_LABEL")
	# Fallback: use theme if available
	if has_theme_color("font_color", "Label"):
		return get_theme_color("font_color", "Label")
	# Final fallback: dark color that works on light backgrounds
	return Color(0.2, 0.2, 0.2, 1)

func _scale_controls(node, label_font_size: int, button_font_size: int, item_height: float):
	var font_color = _get_theme_font_color()
	
	if node is Label:
		node.add_theme_font_size_override("font_size", label_font_size)
		node.add_theme_color_override("font_color", font_color)
		# Ensure labels have proper minimum height
		if node.custom_minimum_size.y < item_height * 0.6:
			node.custom_minimum_size.y = item_height * 0.6
	elif node is Button:
		node.add_theme_font_size_override("font_size", button_font_size)
		node.add_theme_color_override("font_color", font_color)
		
		# Ensure buttons have adequate touch target size
		var min_btn_height = max(item_height * 0.7, 44)  # Minimum touch target
		if node.custom_minimum_size != Vector2.ZERO:
			node.custom_minimum_size.y = max(node.custom_minimum_size.y, min_btn_height)
		else:
			node.set_custom_minimum_size(Vector2(0, min_btn_height))
	
	for child in node.get_children():
		_scale_controls(child, label_font_size, button_font_size, item_height)
