extends RefCounted
class_name UIManager

var number_buttons: GridContainer
var puzzle_info: Label
var game_timer_text: Label
var highlight_button: Button
var main_node: Node # To add popups

var sudoku: Sudoku

# Color Constants
const CLR_SELECT = Color(0.13, 0.4, 0.65, 0.8)
const CLR_BACKGROUND = Color(0.1, 0.1, 0.1)
const CLR_BOARD2 = Color(0.26, 0.26, 0.26)
const CLR_HOVER = Color(0.13, 0.4, 0.65, 0.4)

func _init(p_main_node: Node, p_sudoku: Sudoku):
	self.main_node = p_main_node
	self.sudoku = p_sudoku
	
	self.number_buttons = main_node.get_node("Panel/AspectRatioContainer/VBoxContainer/NumberButtons")
	self.puzzle_info = main_node.get_node("Panel/AspectRatioContainer/VBoxContainer/PuzzleInfo")
	self.game_timer_text = main_node.get_node("Panel/AspectRatioContainer/VBoxContainer/MenuLayer1/Timer")
	self.highlight_button = main_node.get_node("Panel/AspectRatioContainer/VBoxContainer/MenuLayer2/HighlightButton")

func setup_number_buttons(button_size: int, callback: Callable):
	for i in range(1, 13):
		var button = number_buttons.get_node("Button" + str(i))
		button.set_custom_minimum_size(Vector2(button_size,button_size))
		button.add_theme_font_size_override("font_size", button_size * 0.5)
		var hover_style = StyleBoxFlat.new()
		hover_style.set_bg_color(CLR_HOVER)
		button.add_theme_stylebox_override("hover", hover_style)
		if i < 10:
			button.set_text(str(i))
			button.pressed.connect(callback.bind(i))

func update_buttons(selected_num: int, mode: int, selected_cell: Vector2i):
	var needed = sudoku.get_needed_numbers()
	for i in range(0, 9):
		var button = number_buttons.get_node("Button" + str(i+1))
		var style = StyleBoxFlat.new()
		if !needed[i]:
			button.disabled = true
			style.bg_color = CLR_BACKGROUND
			button.add_theme_color_override("font_color", Color.GRAY)
			button.add_theme_stylebox_override("normal", style)
			continue
		else:
			button.disabled = false

		if selected_num == i + 1:
			style.bg_color = CLR_SELECT
			button.add_theme_color_override("font_color", Color.WHITE)
			button.add_theme_stylebox_override("normal", style)
			continue
		else:
			button.add_theme_color_override("font_color", Color.WHITE)
			style.bg_color = CLR_BOARD2
			button.add_theme_stylebox_override("normal", style)
   
	for i in range(10, 13):
		var button = number_buttons.get_node("Button" + str(i))
		var style = StyleBoxFlat.new()
		button.add_theme_color_override("font_color", Color.WHITE)
		style.bg_color = CLR_BACKGROUND
		if mode == 1 and i == 10: # NUMBER_CLR
			style.bg_color = CLR_SELECT
		if mode == 2 and i == 11: # PENCIL
			style.bg_color = CLR_SELECT
		if mode == 3 and i == 12: # PENCIL_EXCLUDE
			style.bg_color = CLR_SELECT
		button.add_theme_stylebox_override("normal", style)

func update_timer(time_in_seconds: int):
	var minutes = int(time_in_seconds / 60)
	var seconds = time_in_seconds % 60
	game_timer_text.text = "%d:%02d" % [minutes, seconds]

func show_hint_popup(hint: Hint):
	var popup = PopupPanel.new()
	var label = Label.new()
	label.text = hint.description
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	popup.add_child(label)
	main_node.add_child(popup)
	popup.popup_centered()

func show_no_hints_popup():
	var popup = PopupPanel.new()
	var label = Label.new()
	label.text = "No hints available."
	popup.add_child(label)
	main_node.add_child(popup)
	popup.popup_centered()

func show_puzzle_done_popup():
	var popupDone = preload("res://puzzleDone.tscn").instantiate()
	var dimensions = main_node.get_viewport().get_visible_rect().size
	popupDone.size = Vector2(dimensions.x * 0.5, dimensions.y * 0.5)
	main_node.add_child(popupDone)
	popupDone.popup_centered()

func update_puzzle_info():
	var info = sudoku.get_puzzle_info()
	puzzle_info.text = "Puzzle: %s\nDifficulty: %s" % [info.name, info.difficulty] 