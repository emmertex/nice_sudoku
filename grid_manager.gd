extends RefCounted
class_name GridManager

var grid_container: GridContainer
var sudoku: Sudoku

# Cell state variables
var selected_cell: Vector2i
var selected_num: int
var highlight_mode: int

# Color Constants
const CLR_HINT_CELL = Color.PALE_VIOLET_RED
const CLR_HINT_ELIM_CAND = Color.PALE_GREEN

func _init(p_grid_container: GridContainer, p_sudoku: Sudoku):
	self.grid_container = p_grid_container
	self.sudoku = p_sudoku

func highlight_hint(hint: Hint):
	for cell in hint.cells:
		var button = grid_container.get_child(cell.x * 9 + cell.y)
		var style = button.get_theme_stylebox("normal").duplicate()
		style.set_bg_color(CLR_HINT_CELL)
		button.add_theme_stylebox_override("normal", style)

	# This is a simplified example for Naked Pairs.
	# You will need to expand this for other hint types.
	if hint.technique == Hint.HintTechnique.NAKED_PAIR_ROW:
		# Find and highlight the candidates to be eliminated
		pass