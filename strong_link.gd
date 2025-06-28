extends RefCounted
class_name StrongLink

enum LinkType {
	BIVALUE_CELL,
	BILOCAL_UNIT
}

var type: LinkType
var digit1: int
var digit2: int # For BIVALUE_CELL. -1 for BILOCAL_UNIT.
var node1_cells: BitSet
var node2_cells: BitSet

func _init(p_type: LinkType, p_digit1: int, p_digit2: int, p_node1_cells: BitSet, p_node2_cells: BitSet):
	type = p_type
	digit1 = p_digit1
	digit2 = p_digit2
	node1_cells = p_node1_cells
	node2_cells = p_node2_cells

static func new_bivalue(r: int, c: int, d1: int, d2: int):
	var cell_bitset = BitSet.new(81)
	cell_bitset.set_bit(r * 9 + c)
	return StrongLink.new(LinkType.BIVALUE_CELL, d1, d2, cell_bitset, cell_bitset)

static func new_bilocal(d: int, r1: int, c1: int, r2: int, c2: int):
	var n1 = BitSet.new(81)
	n1.set_bit(r1 * 9 + c1)
	var n2 = BitSet.new(81)
	n2.set_bit(r2 * 9 + c2)
	return StrongLink.new(LinkType.BILOCAL_UNIT, d, -1, n1, n2)

func _to_string() -> String:
	if type == LinkType.BIVALUE_CELL:
		var cell_idx = node1_cells.next_set_bit()
		if cell_idx == -1: return "Invalid BIVALUE_CELL link (no cell)"
		var r = int(cell_idx / 9)
		var c = cell_idx % 9
		return "Link (BIVALUE_CELL at (%d, %d)): %d <=> %d" % [r+1, c+1, digit1+1, digit2+1]
	elif type == LinkType.BILOCAL_UNIT:
		var c1_idx = node1_cells.next_set_bit()
		var c2_idx = node2_cells.next_set_bit()
		if c1_idx == -1 or c2_idx == -1: return "Invalid BILOCAL_UNIT link (missing cells)"
		var r1 = int(c1_idx / 9)
		var c1 = c1_idx % 9
		var r2 = int(c2_idx / 9)
		var c2 = c2_idx % 9
		return "Link (BILOCAL_UNIT for %d): (%d, %d) <=> (%d, %d)" % [digit1+1, r1+1, c1+1, r2+1, c2+1]
	return "Invalid StrongLink" 
