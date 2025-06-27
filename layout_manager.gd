extends RefCounted
class_name LayoutManager

var main_node: Control
var number_buttons: GridContainer
var grid_container: GridContainer
var aspect_container: AspectRatioContainer
var menu_layer1: HBoxContainer
var menu_layer2: HBoxContainer
var puzzle_info: Label

var vertical_aspect_ratio: float = 1/(1.638)
var button_size: int = 70

func _init(p_main_node: Control):
	self.main_node = p_main_node
	# Get node references
	self.number_buttons = main_node.get_node("Panel/AspectRatioContainer/VBoxContainer/NumberButtons")
	self.grid_container = main_node.get_node("Panel/AspectRatioContainer/VBoxContainer/HBoxContainerGrid/AspectRatioContainer/GridContainer")
	self.aspect_container = main_node.get_node("Panel/AspectRatioContainer")
	self.menu_layer1 = main_node.get_node("Panel/AspectRatioContainer/VBoxContainer/MenuLayer1")
	self.menu_layer2 = main_node.get_node("Panel/AspectRatioContainer/VBoxContainer/MenuLayer2")
	self.puzzle_info = main_node.get_node("Panel/AspectRatioContainer/VBoxContainer/PuzzleInfo")
	
func on_viewport_size_changed():
	var viewport_size = main_node.get_viewport().get_visible_rect().size
	var orientation = viewport_size.x < viewport_size.y / 1.2

	var available_width = min(viewport_size.x, viewport_size.y * 1.2)
	var available_height = min(viewport_size.y, viewport_size.x / 1.2)
	
	if orientation:
		button_size = int(min(available_height / 15, available_width / 8))
	else:
		button_size = int(min(available_width / 15, available_height / 8))
	
	button_size = max(button_size, 20)
	
	_adjust_number_buttons_layout(orientation)
	_resize_number_buttons()
	_resize_menu_buttons()
	_resize_grid_buttons()

func _adjust_number_buttons_layout(orientation: bool):
	if orientation:
		number_buttons.columns = 6
		aspect_container.ratio = vertical_aspect_ratio
	else:
		number_buttons.columns = 2
		aspect_container.ratio = 1

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
			grid_button.set_custom_minimum_size(Vector2(button_size, button_size))
			grid_button.add_theme_font_size_override("font_size", button_size * 0.5)
			_resize_pencil_cells(grid_button.get_child(0))

func _resize_pencil_cells(pencil_container):
	for pencil in range(9):
		var pencil_cell = pencil_container.get_child(pencil)
		pencil_cell.position = Vector2((pencil%3) * (button_size / 3), (pencil/3) * (button_size / 3))
		pencil_cell.size = Vector2(button_size / 3, button_size / 3)
		pencil_cell.add_theme_font_size_override("font_size", button_size * (0.7 / 3)) 