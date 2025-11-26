extends RefCounted
class_name SudokuHintGenerator

var sudoku: Sudoku
var strong_links: Array

const SOLVER_SEQUENCE = [
	preload("res://solvers/single_candidate_solver.gd"),
	preload("res://solvers/hidden_single_solver.gd"),
	preload("res://solvers/naked_group_solver.gd"),
	preload("res://solvers/shared_cell_solver.gd"),
	preload("res://solvers/pointing_solver.gd"),
	preload("res://solvers/x_wing_solver.gd"),
	preload("res://solvers/swordfish_solver.gd"),
	preload("res://solvers/jellyfish_solver.gd"),
	preload("res://solvers/sashimi_fish_solver.gd"),
	preload("res://solvers/dds_solver.gd"),
	preload("res://solvers/box_line_solver.gd"),
	preload("res://solvers/skyscraper_string_kite_solver.gd"),
	preload("res://solvers/s_wing_solver.gd"),
	preload("res://solvers/remote_pair_solver.gd"),
	preload("res://solvers/xy_wing_solver.gd"),
	preload("res://solvers/xyz_wing_solver.gd"),
	preload("res://solvers/wxyz_wing_solver.gd"),
	preload("res://solvers/xy_chain_wwing_solver.gd"),
	preload("res://solvers/xy_ring_solver.gd"),
	preload("res://solvers/mlh_wing_solver.gd"),
	preload("res://solvers/empty_rectangle_solver.gd"),
	preload("res://solvers/nishio_solver.gd")
]

func get_hints() -> Array[Hint]:
	var hints: Array[Hint] = []
	_build_strong_links()
	for solver_script in SOLVER_SEQUENCE:
		var solver = solver_script.new()
		solver.solve(self, hints)
		if hints.size() > 0:
			return hints
	return hints

func _get_candidates(r: int, c: int) -> BitSet:
	var cands = sudoku.sbrc_grid.get_candidates_for_cell(r, c).clone()
	var bits_to_exclude = sudoku.exclude_bits[r][c]
	if bits_to_exclude > 0:
		cands.data[0] &= ~bits_to_exclude
	return cands

func _build_strong_links():
	strong_links = []
	
	# Bivalue cells
	for r in range(9):
		for c in range(9):
			var candidates = _get_candidates(r, c)
			if candidates.cardinality() == 2:
				var d1 = candidates.next_set_bit(0)
				var d2 = candidates.next_set_bit(d1 + 1)
				strong_links.append(StrongLink.new_bivalue(r, c, d1, d2))

	# Bilocal units
	for d in range(9):
		# Rows
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if _get_candidates(r, c).get_bit(d):
					positions.set_bit(c)
			if positions.cardinality() == 2:
				var c1 = positions.next_set_bit(0)
				var c2 = positions.next_set_bit(c1 + 1)
				strong_links.append(StrongLink.new_bilocal(d, r, c1, r, c2))

		# Columns
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if _get_candidates(r, c).get_bit(d):
					positions.set_bit(r)
			if positions.cardinality() == 2:
				var r1 = positions.next_set_bit(0)
				var r2 = positions.next_set_bit(r1 + 1)
				strong_links.append(StrongLink.new_bilocal(d, r1, c, r2, c))

		# Boxes
		for b in range(9):
			var positions = BitSet.new(9)
			for i in range(9):
				var cell = Cardinals.box_to_rc(b, i)
				if _get_candidates(cell.x, cell.y).get_bit(d):
					positions.set_bit(i)
			if positions.cardinality() == 2:
				var i1 = positions.next_set_bit(0)
				var i2 = positions.next_set_bit(i1 + 1)
				var cell1 = Cardinals.box_to_rc(b, i1)
				var cell2 = Cardinals.box_to_rc(b, i2)
				strong_links.append(StrongLink.new_bilocal(d, cell1.x, cell1.y, cell2.x, cell2.y))

func _get_peer_cells(row: int, col: int) -> Array[Vector2i]:
	var peers: Array[Vector2i] = []
	var seen_coords = {}

	# Add row peers
	for c in range(9):
		if c != col:
			peers.append(Vector2i(row, c))
			seen_coords[Vector2i(row, c)] = true
			
	# Add col peers
	for r in range(9):
		if r != row:
			var coord = Vector2i(r, col)
			if not seen_coords.has(coord):
				peers.append(coord)
				seen_coords[coord] = true

	# Add box peers
	var box_idx = Cardinals.Bxy[row * 9 + col]
	for i in range(9):
		var pos = Cardinals.box_to_rc(box_idx, i)
		if pos.x != row or pos.y != col:
			if not seen_coords.has(pos):
				peers.append(pos)
				seen_coords[pos] = true
				
	return peers

func _format_cell_list(cells) -> String:
	return ", ".join(cells.map(func(c): return "(%d, %d)" % [c.x + 1, c.y + 1]))

func _are_peers(c1: Vector2i, c2: Vector2i) -> bool:
	if c1.x == c2.x: return true
	if c1.y == c2.y: return true
	if Cardinals.Bxy[c1.x * 9 + c1.y] == Cardinals.Bxy[c2.x * 9 + c2.y]: return true
	return false

func combinations(arr, k):
	var result = []
	_combinations_recursive(arr, k, 0, [], result)
	return result

func _combinations_recursive(arr, k, start, current, result):
	if current.size() == k:
		result.append(current.duplicate())
		return

	if start >= arr.size():
		return

	# Include current element
	current.append(arr[start])
	_combinations_recursive(arr, k, start + 1, current, result)
	current.pop_back()

	# Exclude current element
	if arr.size() - (start + 1) >= k - current.size():
		_combinations_recursive(arr, k, start + 1, current, result)
