extends RefCounted
class_name StrongLink

# Constants matching Java StrongLink implementation
const BIVALVE = 0
const BILOCAL = 1
const CELL_TO_GROUP = 2
const GROUP_TO_CELL = 3
const GROUP_TO_GROUP = 4
const ERI_MAX = 5
const ERI_ALL = 6
const ALS = 7

enum LinkType {
	BIVALUE_CELL,
	BILOCAL_UNIT,
	CELL_TO_GROUP,
	GROUP_TO_CELL,
	GROUP_TO_GROUP,
	ERI_MAX,
	ERI_ALL,
	ALS
}

var type: LinkType
var digit1: int
var digit2: int # For BIVALUE_CELL. -1 for BILOCAL_UNIT.
var node1_cells: BitSet
var node2_cells: BitSet
# Additional properties used by newer link types
var startDigitSwapAvailable: BitSet = null
var endDigitSwapAvailable: BitSet = null
var alsCells: BitSet = null
var alsDigits: Array = []

# Properties matching Java StrongLink implementation
var activeCells: BitSet
var linkedCells: BitSet
var startCellsSector: BitSet
var linkCellsSector: BitSet

func _init(p_type: LinkType, p_digit1: int, p_digit2: int, p_node1_cells: BitSet, p_node2_cells: BitSet):
	type = p_type
	digit1 = p_digit1
	digit2 = p_digit2
	node1_cells = p_node1_cells
	node2_cells = p_node2_cells
	activeCells = p_node1_cells
	linkedCells = p_node2_cells

static func new_cell_to_group(cell_row: int, cell_col: int, group_cells: BitSet, digit: int) -> StrongLink:
	# Placeholder implementation – creates a link from a single cell to a group
	var cell_bitset = BitSet.new(81)
	cell_bitset.set_bit(cell_row * 9 + cell_col)
	var link = StrongLink.new(LinkType.CELL_TO_GROUP, digit, -1, cell_bitset, group_cells)
	link.startCellsSector = cell_bitset.clone()
	link.linkCellsSector = group_cells.clone()
	return link

static func new_group_to_cell(group_cells: BitSet, cell_row: int, cell_col: int, digit: int) -> StrongLink:
	# Placeholder implementation – creates a link from a group to a single cell
	var cell_bitset = BitSet.new(81)
	cell_bitset.set_bit(cell_row * 9 + cell_col)
	var link = StrongLink.new(LinkType.GROUP_TO_CELL, digit, -1, group_cells, cell_bitset)
	link.startCellsSector = group_cells.clone()
	link.linkCellsSector = cell_bitset.clone()
	return link

static func new_group_to_group(group1: BitSet, group2: BitSet) -> StrongLink:
	# Placeholder implementation – creates a link between two groups
	var link = StrongLink.new(LinkType.GROUP_TO_GROUP, -1, -1, group1, group2)
	link.startCellsSector = group1.clone()
	link.linkCellsSector = group2.clone()
	return link

static func new_eri_max(node1: BitSet, node2: BitSet, start_swap: bool, end_swap: bool) -> StrongLink:
	# Placeholder implementation – creates an ERI_MAX link
	var link = StrongLink.new(LinkType.ERI_MAX, -1, -1, node1, node2)
	link.startDigitSwapAvailable = BitSet.new(9) if start_swap else null
	link.endDigitSwapAvailable = BitSet.new(9) if end_swap else null
	link.startCellsSector = node1.clone()
	link.linkCellsSector = node2.clone()
	return link

static func new_eri_all(node1: BitSet, node2: BitSet) -> StrongLink:
	# Placeholder implementation – creates an ERI_ALL link
	var link = StrongLink.new(LinkType.ERI_ALL, -1, -1, node1, node2)
	link.startCellsSector = node1.clone()
	link.linkCellsSector = node2.clone()
	return link

static func new_als(als_cells: BitSet, als_digits: Array) -> StrongLink:
	# Placeholder implementation – creates an ALS link
	var link = StrongLink.new(LinkType.ALS, -1, -1, als_cells, null)
	link.alsCells = als_cells
	link.alsDigits = als_digits
	link.startCellsSector = als_cells.clone()
	link.linkCellsSector = BitSet.new(81) # Empty for ALS
	return link

static func new_bivalue(r: int, c: int, d1: int, d2: int):
	var cell_bitset = BitSet.new(81)
	cell_bitset.set_bit(r * 9 + c)
	var link = StrongLink.new(LinkType.BIVALUE_CELL, d1, d2, cell_bitset, cell_bitset)
	link.startCellsSector = cell_bitset.clone()
	link.linkCellsSector = cell_bitset.clone()
	return link

# (Existing bilocal constructor remains unchanged)
static func new_bilocal(d: int, r1: int, c1: int, r2: int, c2: int):
	var n1 = BitSet.new(81)
	n1.set_bit(r1 * 9 + c1)
	var n2 = BitSet.new(81)
	n2.set_bit(r2 * 9 + c2)
	var link = StrongLink.new(LinkType.BILOCAL_UNIT, d, -1, n1, n2)
	link.startCellsSector = n1.clone()
	link.linkCellsSector = n2.clone()
	return link

func _to_string() -> String:
	if type == LinkType.BIVALUE_CELL:
		var cell_idx = node1_cells.next_set_bit()
		if cell_idx == -1: return "Invalid BIVALUE_CELL link (no cell)"
		@warning_ignore("integer_division")
		var r = int(cell_idx / 9)
		var c = cell_idx % 9
		return "Link (BIVALUE_CELL at (%d, %d)): %d <=> %d" % [r+1, c+1, digit1+1, digit2+1]
	elif type == LinkType.BILOCAL_UNIT:
		var c1_idx = node1_cells.next_set_bit()
		var c2_idx = node2_cells.next_set_bit()
		if c1_idx == -1 or c2_idx == -1: return "Invalid BILOCAL_UNIT link (missing cells)"
		@warning_ignore("integer_division")
		var r1 = int(c1_idx / 9)
		var c1 = c1_idx % 9
		@warning_ignore("integer_division")
		var r2 = int(c2_idx / 9)
		var c2 = c2_idx % 9
		return "Link (BILOCAL_UNIT for %d): (%d, %d) <=> (%d, %d)" % [digit1+1, r1+1, c1+1, r2+1, c2+1]
	return "Invalid StrongLink" 
