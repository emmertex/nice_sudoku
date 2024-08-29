extends PopupPanel

@export var base_width = 100
@export var base_font_size = 16
@export var base_height = 50

func _ready():
    get_parent().resized.connect(_on_parent_resized)
    _on_parent_resized()
    

func _on_parent_resized():
    var dimension = get_parent().size
    var min_dimension = min(dimension.x, dimension.y) * 0.8
    var scale_factor = min_dimension / base_width
    
    # Set the size of this popup
    size = Vector2(base_width * scale_factor, base_height * scale_factor)
    
    # Scale font sizes and control sizes
    _scale_controls(self, scale_factor)

func _scale_controls(node, scale_factor):
    if node is Label or node is Button or node is TextEdit:
        var new_size = base_font_size * scale_factor
        node.add_theme_font_size_override("font_size", int(new_size))
        
        # Scale the custom minimum size of the control
        if node.custom_minimum_size != Vector2.ZERO:
            node.custom_minimum_size *= scale_factor

    # Recursively scale child controls
    for child in node.get_children():
        _scale_controls(child, scale_factor)