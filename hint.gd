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
	JELLYFISH_COL,
	SIMPLE_COLORING
}

var technique: HintTechnique
var title: String
var description: String
var cells: Array[Vector2i] = [] # The primary cells of the hint
var secondary_cells: Array[Vector2i] = [] # Secondary cells for highlighting (e.g., the rest of a house)
var cause_cells: Array[Vector2i] = [] # Cells that cause the hint (e.g. blocking numbers)
var numbers: Array[int] = [] # The numbers involved
var elim_cells: Array[Vector2i] = [] # Cells from which candidates can be eliminated
var elim_numbers: Array[int] = [] # The candidates to eliminate

func _init(p_technique: HintTechnique, p_description: String):
	technique = p_technique
	description = p_description
	title = _get_technique_title_from_enum(p_technique)

func _get_technique_title_from_enum(p_technique: HintTechnique) -> String:
	var tech_key = Hint.HintTechnique.keys()[p_technique]
	
	var parts = tech_key.split("_")
	
	# For names like NAKED_PAIR_ROW, we don't want the unit type in the title.
	if parts.size() > 1 and (parts[parts.size() - 1] == "ROW" or parts[parts.size() - 1] == "COL" or parts[parts.size() - 1] == "BOX"):
		parts.resize(parts.size() - 1)
	
	var title_words = []
	for part in parts:
		title_words.append(part.capitalize())
	
	var title_str = " ".join(title_words)
	
	# Handle special cases like X-Wing
	if title_str == "X Wing":
		return "X-Wing"
		
	return title_str 
