extends RefCounted
class_name SudokuHintGenerator

var sudoku: Sudoku
var strong_links: Array

const SOLVER_SEQUENCE = [
	preload("res://solvers/single_candidate_solver.gd"),
	preload("res://solvers/hidden_single_solver.gd"),
	preload("res://solvers/naked_group_solver.gd"),
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
		var time_start = Time.get_ticks_msec()
		var solver = solver_script.new()
		solver.solve(self, hints)
		if (Time.get_ticks_msec() - time_start) > 50:
			print("Solver: %s, time: %d ms, hints: %d" % [solver.name(), Time.get_ticks_msec() - time_start, hints.size()])
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

	# Cache all candidates to avoid repeated calculations
	var candidates_cache: Array[Array] = []
	candidates_cache.resize(9)
	for r in range(9):
		candidates_cache[r] = []
		candidates_cache[r].resize(9)
		for c in range(9):
			candidates_cache[r][c] = _get_candidates(r, c)

	# Bivalue cells
	for r in range(9):
		for c in range(9):
			var candidates = candidates_cache[r][c]
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
				if candidates_cache[r][c].get_bit(d):
					positions.set_bit(c)
			if positions.cardinality() == 2:
				var c1 = positions.next_set_bit(0)
				var c2 = positions.next_set_bit(c1 + 1)
				strong_links.append(StrongLink.new_bilocal(d, r, c1, r, c2))

		# Columns
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if candidates_cache[r][c].get_bit(d):
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
				if candidates_cache[cell.x][cell.y].get_bit(d):
					positions.set_bit(i)
			if positions.cardinality() == 2:
				var i1 = positions.next_set_bit(0)
				var i2 = positions.next_set_bit(i1 + 1)
				var cell1 = Cardinals.box_to_rc(b, i1)
				var cell2 = Cardinals.box_to_rc(b, i2)
				strong_links.append(StrongLink.new_bilocal(d, cell1.x, cell1.y, cell2.x, cell2.y))

	# CELL_TO_GROUP and GROUP_TO_CELL links (rows, columns, boxes)
	for d in range(9):
		# Rows
		for r in range(9):
			var row_group = BitSet.new(81)
			var has_candidate = false
			for c in range(9):
				if candidates_cache[r][c].get_bit(d):
					row_group.set_bit(r * 9 + c)
					has_candidate = true
			if has_candidate:
				for c in range(9):
					if candidates_cache[r][c].get_bit(d):
						strong_links.append(StrongLink.new_cell_to_group(r, c, row_group, d))
						strong_links.append(StrongLink.new_group_to_cell(row_group, r, c, d))

		# Columns
		for c in range(9):
			var col_group = BitSet.new(81)
			var has_candidate = false
			for r in range(9):
				if candidates_cache[r][c].get_bit(d):
					col_group.set_bit(r * 9 + c)
					has_candidate = true
			if has_candidate:
				for r in range(9):
					if candidates_cache[r][c].get_bit(d):
						strong_links.append(StrongLink.new_cell_to_group(r, c, col_group, d))
						strong_links.append(StrongLink.new_group_to_cell(col_group, r, c, d))

		# Boxes
		for b in range(9):
			var box_group = BitSet.new(81)
			var has_candidate = false
			for i in range(9):
				var cell = Cardinals.box_to_rc(b, i)
				if candidates_cache[cell.x][cell.y].get_bit(d):
					box_group.set_bit(cell.x * 9 + cell.y)
					has_candidate = true
			if has_candidate:
				for i in range(9):
					var cell = Cardinals.box_to_rc(b, i)
					if candidates_cache[cell.x][cell.y].get_bit(d):
						strong_links.append(StrongLink.new_cell_to_group(cell.x, cell.y, box_group, d))
						strong_links.append(StrongLink.new_group_to_cell(box_group, cell.x, cell.y, d))

	# GROUP_TO_GROUP links (row ↔ column for same digit)
	for d in range(9):
		# Precompute all row groups for this digit
		var row_groups: Array[BitSet] = []
		row_groups.resize(9)
		for r in range(9):
			var row_group = BitSet.new(81)
			for c in range(9):
				if candidates_cache[r][c].get_bit(d):
					row_group.set_bit(r * 9 + c)
			row_groups[r] = row_group

		# Precompute all column groups for this digit
		var col_groups: Array[BitSet] = []
		col_groups.resize(9)
		for c in range(9):
			var col_group = BitSet.new(81)
			for r in range(9):
				if candidates_cache[r][c].get_bit(d):
					col_group.set_bit(r * 9 + c)
			col_groups[c] = col_group

		# Create links between non-empty row and column groups
		for r in range(9):
			if row_groups[r].cardinality() == 0:
				continue
			for c in range(9):
				if col_groups[c].cardinality() == 0:
					continue
				strong_links.append(StrongLink.new_group_to_group(row_groups[r], col_groups[c]))

	# ERI_MAX links (peer pairs with start/end swap flags)
	for d in range(9):
		for r in range(9):
			for c in range(9):
				if not candidates_cache[r][c].get_bit(d):
					continue
				var peers = _get_peer_cells(r, c)
				for peer in peers:
					if candidates_cache[peer.x][peer.y].get_bit(d):
						if r * 9 + c < peer.x * 9 + peer.y:
							var node1 = BitSet.new(81)
							node1.set_bit(r * 9 + c)
							var node2 = BitSet.new(81)
							node2.set_bit(peer.x * 9 + peer.y)
							strong_links.append(StrongLink.new_eri_max(node1, node2, true, false))

	# ERI_ALL links (all peer pairs for each digit)
	for d in range(9):
		for r in range(9):
			for c in range(9):
				if not candidates_cache[r][c].get_bit(d):
					continue
				var peers = _get_peer_cells(r, c)
				for peer in peers:
					if candidates_cache[peer.x][peer.y].get_bit(d):
						if r * 9 + c < peer.x * 9 + peer.y:
							var node1 = BitSet.new(81)
							node1.set_bit(r * 9 + c)
							var node2 = BitSet.new(81)
							node2.set_bit(peer.x * 9 + peer.y)
							strong_links.append(StrongLink.new_eri_all(node1, node2))

	# ALS links (simple placeholder: rows with >1 candidate cells)
	for r in range(9):
		var als_cells = BitSet.new(81)
		var als_digits_set = {}
		for c in range(9):
			var cand = candidates_cache[r][c]
			if cand.cardinality() > 1:
				als_cells.set_bit(r * 9 + c)
				for d in range(9):
					if cand.get_bit(d):
						als_digits_set[d] = true
		if als_cells.cardinality() >= 2 and als_digits_set.size() <= als_cells.cardinality():
			var als_digits = []
			for d_key in als_digits_set.keys():
				als_digits.append(d_key)
			strong_links.append(StrongLink.new_als(als_cells, als_digits))

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
