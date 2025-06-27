extends RefCounted
class_name StrongLink

enum LinkType {
	BIVALUE_CELL,
	BILOCAL_UNIT
}

var type: LinkType
var digit: int
var node1_cells: BitSet
var node2_cells: BitSet

func _init(p_type: LinkType, p_digit: int, p_node1_cells: BitSet, p_node2_cells: BitSet):
	type = p_type
	digit = p_digit
	node1_cells = p_node1_cells
	node2_cells = p_node2_cells

func _to_string() -> String:
	return "Link (d%d): %s <=> %s" % [digit+1, node1_cells.to_string_representation(), node2_cells.to_string_representation()] 
