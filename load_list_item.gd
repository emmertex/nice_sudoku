extends Control

@export var base_width = 340
@export var base_font_size = 16
@export var base_height = 36

func _ready():
	get_parent().resized.connect(_on_parent_resized)
	_on_parent_resized()

func _on_parent_resized():
	var parent_width = get_parent().size.x
	var scale_factor = parent_width / base_width
	
	# Set the size of this control
	custom_minimum_size = Vector2(parent_width, base_height * scale_factor)
	set_deferred("size", custom_minimum_size)
	
	# Scale font sizes and control sizes
	_scale_controls(self, scale_factor)

func _scale_controls(node, scale_factor):
	if node is Label or node is Button:
		var new_size = base_font_size * scale_factor
		node.add_theme_font_size_override("font_size", int(new_size))
		
		# Scale the custom minimum size of the control
		if node.custom_minimum_size != Vector2.ZERO:
			node.custom_minimum_size.y = 25 * scale_factor  # Reduced from 30 to 25
	
	for child in node.get_children():
		_scale_controls(child, scale_factor)
