extends RefCounted
class_name Hint

enum HintTechnique {
	SINGLE_CANDIDATE,
	HIDDEN_SINGLE,
	NAKED_PAIR_ROW,
	NAKED_PAIR_COL,
	NAKED_PAIR_BOX,
	NAKED_TRIPLE_ROW,
	NAKED_TRIPLE_COL,
	NAKED_TRIPLE_BOX,
	NAKED_QUAD_ROW,
	NAKED_QUAD_COL,
	NAKED_QUAD_BOX,
	POINTING_PAIR,
	BOX_LINE_REDUCTION,
	X_WING_ROW,
	X_WING_COL,
	SWORDFISH_ROW,
	SWORDFISH_COL,
	JELLYFISH_ROW,
	JELLYFISH_COL
}

var technique: HintTechnique
var description: String
var cells: Array[Vector2i] = [] # The primary cells of the hint
var numbers: Array[int] = [] # The numbers involved
var elim_cells: Array[Vector2i] = [] # Cells from which candidates can be eliminated
var elim_numbers: Array[int] = [] # The candidates to eliminate

func _init(p_technique: HintTechnique, p_description: String):
	technique = p_technique
	description = p_description 