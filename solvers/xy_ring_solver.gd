extends RefCounted
class_name XYRingSolver

var sudoku: Sudoku
var generator_ref: SudokuHintGenerator

func name() -> String:
	return "XY-Ring Solver"

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	generator_ref = generator
	sudoku = generator.sudoku
	_find_xy_rings(hints)
func _find_xy_rings(hints: Array[Hint]):
	# XY-Ring: Closed loop of XY-Chains forming a ring
	# Modify XY-Chain detection to find cycles
	# This is already partially handled by Type-2 XY-Chain, but we need to detect rings specifically
	
	# Collect bivalue cells
	var nodes: Array = [] # {pos: Vector2i, pair: PackedInt32Array}
	var pos_to_idx = {}
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cand = _get_candidates(r, c)
			if cand.cardinality() == 2:
				var d1 = cand.next_set_bit(0)
				var d2 = cand.next_set_bit(d1 + 1)
				var idx = nodes.size()
				nodes.append({"pos": Vector2i(r, c), "pair": PackedInt32Array([d1, d2])})
				pos_to_idx[Vector2i(r, c)] = idx
	
	if nodes.size() < 4:
		return
	
	# Build edges (same as XY-Chain)
	var adj: Array = []
	for _i in range(nodes.size()): adj.append([])
	
	for d in range(9):
		# Rows
		for rr in range(9):
			var node_positions_row: Array[Vector2i] = []
			for cc in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr,cc).get_bit(d):
					var posr = Vector2i(rr,cc)
					if pos_to_idx.has(posr): node_positions_row.append(posr)
			if node_positions_row.size() >= 2:
				for i in range(node_positions_row.size()):
					for j in range(i + 1, node_positions_row.size()):
						var ar = pos_to_idx[node_positions_row[i]]
						var br = pos_to_idx[node_positions_row[j]]
						adj[ar].append({"to": br, "digit": d})
						adj[br].append({"to": ar, "digit": d})
		# Columns
		for cc in range(9):
			var node_positions_col: Array[Vector2i] = []
			for rr in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr,cc).get_bit(d):
					var posc = Vector2i(rr,cc)
					if pos_to_idx.has(posc): node_positions_col.append(posc)
			if node_positions_col.size() >= 2:
				for i in range(node_positions_col.size()):
					for j in range(i + 1, node_positions_col.size()):
						var ac = pos_to_idx[node_positions_col[i]]
						var bc = pos_to_idx[node_positions_col[j]]
						adj[ac].append({"to": bc, "digit": d})
						adj[bc].append({"to": ac, "digit": d})
		# Boxes
		for box_idx in range(9):
			var node_positions_box: Array[Vector2i] = []
			for i in range(9):
				var p = Cardinals.box_to_rc(box_idx, i)
				if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x,p.y).get_bit(d):
					if pos_to_idx.has(p): node_positions_box.append(p)
			if node_positions_box.size() >= 2:
				for i in range(node_positions_box.size()):
					for j in range(i + 1, node_positions_box.size()):
						var a3 = pos_to_idx[node_positions_box[i]]
						var b3 = pos_to_idx[node_positions_box[j]]
						adj[a3].append({"to": b3, "digit": d})
						adj[b3].append({"to": a3, "digit": d})
	
	# Find rings: cycles where we return to start with same digit
	var emitted = {}
	for start_idx in range(nodes.size()):
		var pair: PackedInt32Array = nodes[start_idx].pair
		for s_digit in [pair[0], pair[1]]:
			var visited: Dictionary = {}
			var path: Array = [start_idx]
			_xyring_dfs(nodes, adj, start_idx, s_digit, start_idx, s_digit, visited, path, hints, emitted)

func _xyring_dfs(nodes: Array, adj: Array, curr_idx: int, curr_active_digit: int, start_idx: int, start_digit: int, visited: Dictionary, path: Array, hints: Array[Hint], emitted: Dictionary):
	if path.size() > 1 and curr_idx == start_idx and curr_active_digit == start_digit and path.size() >= 4:
		# Found a ring!
		var key = str(start_idx) + ":ring:" + str(start_digit)
		if not emitted.has(key):
			# Determine eliminations based on the ring pattern
			# For XY-Ring, we eliminate digits that appear in cells seeing multiple ring cells
			var ring_cells: Array[Vector2i] = []
			for idx in path:
				ring_cells.append(nodes[idx].pos)
			
			# Collect all digits in the ring
			var ring_digits: Array[int] = []
			for idx in path:
				var pair = nodes[idx].pair
				if not ring_digits.has(pair[0]): ring_digits.append(pair[0])
				if not ring_digits.has(pair[1]): ring_digits.append(pair[1])
			
			# Find eliminations: cells seeing multiple ring cells that contain ring digits
			var elim_cells: Array[Vector2i] = []
			var elim_digits: Array[int] = []
			
			for d in ring_digits:
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0:
							continue
						var cell = Vector2i(r, c)
						if cell in ring_cells:
							continue
						if not _get_candidates(r, c).get_bit(d):
							continue
						
						# Count how many ring cells this cell sees
						var see_count = 0
						for ring_cell in ring_cells:
							if _are_peers(cell, ring_cell):
								see_count += 1
						
						# If sees 2+ ring cells, can potentially eliminate
						if see_count >= 2:
							elim_cells.append(cell)
							if not elim_digits.has(d):
								elim_digits.append(d)
			
			if elim_cells.size() > 0:
				var hint = Hint.new(Hint.HintTechnique.XY_RING, "")
				hint.cells.append_array(ring_cells)
				for d in ring_digits:
					hint.numbers.append(d + 1)
				hint.elim_cells.append_array(elim_cells)
				for d in elim_digits:
					hint.elim_numbers.append(d + 1)
				
				var chain_text = []
				for idx in path:
					var pair = nodes[idx].pair
					chain_text.append(_format_cell_list([nodes[idx].pos]) + " {%d/%d}" % [pair[0]+1, pair[1]+1])
				
				var desc = "XY-Ring: Closed loop %s.\n\n" % " -> ".join(chain_text)
				desc += "Forms a ring where digits alternate. Eliminate ring digits from cells seeing multiple ring cells: %s." % _format_cell_list(elim_cells)
				hint.description = desc
				
				var s1 = "XY-Ring: %s" % " -> ".join(chain_text)
				hint.add_step(s1, ring_cells.duplicate())
				var s2 = "Eliminate ring digits from cells seeing multiple ring cells: %s." % _format_cell_list(elim_cells)
				var elim_nums: Array[int] = []
				for d in elim_digits:
					elim_nums.append(d + 1)
				hint.add_step(s2, [], [], [], elim_cells.duplicate(), elim_nums)
				
				hints.append(hint)
				emitted[key] = true
			return
	
	var visit_key = str(curr_idx) + ":" + str(curr_active_digit)
	if visited.has(visit_key):
		return
	visited[visit_key] = true
	
	for edge in adj[curr_idx]:
		var edge_digit: int = edge["digit"]
		if not (edge_digit == curr_active_digit or (path.size() == 1 and (edge_digit == nodes[start_idx].pair[0] or edge_digit == nodes[start_idx].pair[1]))):
			continue
		var next_idx = edge["to"]
		var pair: PackedInt32Array = nodes[next_idx].pair
		if pair.find(edge_digit) == -1:
			continue
		var next_active = pair[0] if pair[1] == edge_digit else pair[1]
		var new_path = path.duplicate()
		new_path.append(next_idx)
		
		if new_path.count(next_idx) > 1:
			continue
		
		_xyring_dfs(nodes, adj, next_idx, next_active, start_idx, start_digit, visited, new_path, hints, emitted)
	
	visited.erase(visit_key)

func _find_als_xy_rule(hints: Array[Hint]):
	# ALS-XY Rule: Two ALS that share a restricted common candidate
	# ALS1 has {X, Y, ...}, ALS2 has {X, Z, ...}
	# X is restricted common candidate (appears in exactly one cell of each ALS)
	# Eliminate Y from cells seeing ALS1, or Z from cells seeing ALS2
	
	# Find all ALS (Almost Locked Sets)
	# ALS: N cells with N+1 candidates, all in same unit (row/col/box)
	var all_als: Array = [] # {cells: Array[Vector2i], candidates: BitSet, unit_type: String, unit_idx: int}

func _get_candidates(r: int, c: int) -> BitSet:
	return generator_ref._get_candidates(r, c)

func _are_peers(c1: Vector2i, c2: Vector2i) -> bool:
	return generator_ref._are_peers(c1, c2)

func _format_cell_list(cells: Array[Vector2i]) -> String:
	return generator_ref._format_cell_list(cells)
