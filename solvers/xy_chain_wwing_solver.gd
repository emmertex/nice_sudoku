extends RefCounted
class_name XYChainWWingSolver

var sudoku: Sudoku
var generator_ref: SudokuHintGenerator

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	generator_ref = generator
	sudoku = generator.sudoku
	_find_xy_chains_and_wwings(hints)



func _find_xy_chains_and_wwings(hints: Array[Hint]):
	# Collect bivalue cells
	var nodes: Array = [] # {pos: Vector2i, pair: PackedInt32Array [a,b]}
	var pos_to_idx = {}
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cand = _get_candidates(r,c)
			if cand.cardinality() == 2:
				var d1 = cand.next_set_bit(0)
				var d2 = cand.next_set_bit(d1 + 1)
				var idx = nodes.size()
				nodes.append({"pos": Vector2i(r,c), "pair": PackedInt32Array([d1, d2])})
				pos_to_idx[Vector2i(r,c)] = idx
	if nodes.size() < 2:
		return

	# Build edges labeled by digit using bilocal condition within each unit
	var adj: Array = []
	for _i in range(nodes.size()): adj.append([])

	for d in range(9):
		# Rows: link bivalue cells on digit d if they form a conjugate pair (exactly 2 in row)
		for rr in range(9):
			var node_positions_row: Array[Vector2i] = []
			var all_positions_row: Array[Vector2i] = []
			for cc in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr,cc).get_bit(d):
					var posr = Vector2i(rr,cc)
					all_positions_row.append(posr)
					if pos_to_idx.has(posr): node_positions_row.append(posr)
			# Only create edges if exactly 2 candidates in row (conjugate pair/strong link)
			if all_positions_row.size() == 2:
				if node_positions_row.size() == 2:
					# Both are bivalue cells
					var ar = pos_to_idx[node_positions_row[0]]
					var br = pos_to_idx[node_positions_row[1]]
					adj[ar].append({"to": br, "digit": d, "strong": true})
					adj[br].append({"to": ar, "digit": d, "strong": true})
				elif node_positions_row.size() == 1:
					# One bivalue cell, one non-bivalue - still a strong link
					# But we can't link non-bivalue cells in this graph, so skip
					pass
		# Columns: conjugate pairs only
		for cc in range(9):
			var node_positions_col: Array[Vector2i] = []
			var all_positions_col: Array[Vector2i] = []
			for rr in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr,cc).get_bit(d):
					var posc = Vector2i(rr,cc)
					all_positions_col.append(posc)
					if pos_to_idx.has(posc): node_positions_col.append(posc)
			# Only create edges if exactly 2 candidates in column (conjugate pair)
			if all_positions_col.size() == 2:
				if node_positions_col.size() == 2:
					var ac = pos_to_idx[node_positions_col[0]]
					var bc = pos_to_idx[node_positions_col[1]]
					adj[ac].append({"to": bc, "digit": d, "strong": true})
					adj[bc].append({"to": ac, "digit": d, "strong": true})
		# Boxes: conjugate pairs only
		for box_idx in range(9):
			var node_positions_box: Array[Vector2i] = []
			var all_positions_box: Array[Vector2i] = []
			for i in range(9):
				var p = Cardinals.box_to_rc(box_idx, i)
				if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x,p.y).get_bit(d):
					all_positions_box.append(p)
					if pos_to_idx.has(p): node_positions_box.append(p)
			# Only create edges if exactly 2 candidates in box (conjugate pair)
			if all_positions_box.size() == 2:
				if node_positions_box.size() == 2:
					var a3 = pos_to_idx[node_positions_box[0]]
					var b3 = pos_to_idx[node_positions_box[1]]
					adj[a3].append({"to": b3, "digit": d, "strong": true})
					adj[b3].append({"to": a3, "digit": d, "strong": true})

	# DFS search
	var emitted = {}
	for start_idx in range(nodes.size()):
		var pair: PackedInt32Array = nodes[start_idx].pair
		for s_digit in [pair[0], pair[1]]:
			var visited: Dictionary = {}
			var path: Array = [start_idx]
			_xychain_dfs(nodes, adj, start_idx, s_digit, start_idx, s_digit, visited, path, hints, emitted)

func _xychain_dfs(nodes: Array, adj: Array, curr_idx: int, curr_active_digit: int, start_idx: int, start_digit: int, visited: Dictionary, path: Array, hints: Array[Hint], emitted: Dictionary):
	var visit_key = str(curr_idx) + ":" + str(curr_active_digit)
	if visited.has(visit_key):
		return
	visited[visit_key] = true

	for edge in adj[curr_idx]:
		# On the very first hop (path.size()==1), allow using either digit from the start cell.
		# Otherwise, the edge must match the current active digit.
		var edge_digit: int = edge["digit"]
		if not (edge_digit == curr_active_digit or (path.size() == 1 and (edge_digit == nodes[start_idx].pair[0] or edge_digit == nodes[start_idx].pair[1]))):
			continue
		var next_idx = edge["to"]
		var pair: PackedInt32Array = nodes[next_idx].pair
		var used_digit = edge_digit
		if pair.find(used_digit) == -1:
			continue
		var next_active = pair[0] if pair[1] == used_digit else pair[1]
		var new_path = path.duplicate()
		new_path.append(next_idx)
		# Do not revisit the same node in the chain to avoid degenerate cycles
		if new_path.count(next_idx) > 1:
			continue

		# Handle Type-2 (endpoints share a unit) when chain length >=3 and parity matches
		if next_active == start_digit and new_path.size() >= 3:
			var a = nodes[start_idx].pos
			var b = nodes[next_idx].pos
			# Type-2: endpoints share a unit
			if _are_peers(a, b) and new_path.size() >= 3:
				# Type-2 XY-Chain (endpoints share a unit). Eliminate the start digit
				# from other cells in the shared unit(s), excluding the endpoints themselves.
				var elim_digit2 = start_digit
				var elim_cells2: Array[Vector2i] = []
				# Same row
				if a.x == b.x:
					var rr = a.x
					for cc in range(9):
						var v = Vector2i(rr, cc)
						if v == a or v == b:
							continue
						if sudoku.grid[rr][cc] == 0 and _get_candidates(rr, cc).get_bit(elim_digit2):
							elim_cells2.append(v)
				# Same column
				if a.y == b.y:
					var cc2 = a.y
					for rr2 in range(9):
						var v2 = Vector2i(rr2, cc2)
						if v2 == a or v2 == b:
							continue
						if sudoku.grid[rr2][cc2] == 0 and _get_candidates(rr2, cc2).get_bit(elim_digit2):
							elim_cells2.append(v2)
				# Same box
				var box_a = Cardinals.Bxy[a.x * 9 + a.y]
				var box_b = Cardinals.Bxy[b.x * 9 + b.y]
				if box_a == box_b:
					for i2 in range(9):
						var p2 = Cardinals.box_to_rc(box_a, i2)
						if p2 == a or p2 == b:
							continue
						if sudoku.grid[p2.x][p2.y] == 0 and _get_candidates(p2.x, p2.y).get_bit(elim_digit2):
							elim_cells2.append(p2)

				# Deduplicate elim cells
				var uniq := {}
				var final_elims: Array[Vector2i] = []
				for v3 in elim_cells2:
					if not uniq.has(v3):
						uniq[v3] = true
						final_elims.append(v3)

				if final_elims.size() > 0:
					var hint2 = Hint.new(Hint.HintTechnique.XY_CHAIN, "")
					for idx2 in new_path:
						hint2.cells.append(nodes[idx2].pos)
					hint2.elim_cells.append_array(final_elims)
					hint2.elim_numbers.append(elim_digit2 + 1)
					# Build short description/steps
					var chain_text2 = []
					for i3 in range(new_path.size()):
						chain_text2.append(_format_cell_list([nodes[new_path[i3]].pos]) + " {" + str(nodes[new_path[i3]].pair[0]+1) + "/" + str(nodes[new_path[i3]].pair[1]+1) + "}")
					var s1t2 = "XY-Chain on digit %d: %s" % [elim_digit2 + 1, " -> ".join(chain_text2)]
					hint2.add_step(s1t2, hint2.cells.duplicate())
					var unit_str = "row" if a.x == b.x else ("column" if a.y == b.y else "box")
					var s2t2 = "Endpoints share a %s, both force %d. Remove %d from other cells in that %s." % [unit_str, elim_digit2 + 1, elim_digit2 + 1, unit_str]
					hint2.add_step(s2t2, [a, b], [], [], final_elims.duplicate(), [elim_digit2 + 1])
					hint2.description = s1t2 + "\n\n" + s2t2
					hints.append(hint2)
					var type2_key = str(start_idx) + ":" + str(next_idx) + ":" + str(start_digit) + ":t2"
					emitted[type2_key] = true
				# Finished processing Type-2; continue exploring other paths
				continue

		# Handle W-Wing: same pair, any path length using strong links
		if new_path.size() >= 2:
			var start_pair: PackedInt32Array = nodes[start_idx].pair
			var end_pair: PackedInt32Array = nodes[next_idx].pair
			var same_pair = (start_pair[0] == end_pair[0] and end_pair[1] == start_pair[1]) or (start_pair[0] == end_pair[1] and start_pair[1] == end_pair[0])
			# Check if path uses strong links (all edges should have "strong": true)
			var all_strong = true
			for i in range(new_path.size() - 1):
				var curr_idx_check = new_path[i]
				var next_idx_check = new_path[i + 1]
				var found_strong_edge = false
				for edge_check in adj[curr_idx_check]:
					if edge_check["to"] == next_idx_check and edge_check.has("strong") and edge_check["strong"]:
						found_strong_edge = true
						break
				if not found_strong_edge:
					all_strong = false
					break
			
			if same_pair and all_strong and new_path.size() >= 2:
				var a = nodes[start_idx].pos
				var b = nodes[next_idx].pos
				var wwing_key = str(start_idx) + ":" + str(next_idx) + ":wwing:" + str(start_digit)
				if not emitted.has(wwing_key):
					# The linking digit is start_digit (the digit used in the path)
					var linking_digit = start_digit
					# The eliminated digit is the other one from the pair
					var elim_digit = start_pair[0] if start_pair[1] == linking_digit else start_pair[1]
					var elim_cells: Array[Vector2i] = []
					for r in range(9):
						for c in range(9):
							if sudoku.grid[r][c] != 0: continue
							if not _get_candidates(r,c).get_bit(elim_digit): continue
							var v = Vector2i(r,c)
							if _are_peers(v, a) and _are_peers(v, b) and v != a and v != b:
								elim_cells.append(v)
					if elim_cells.size() > 0:
						var hint = Hint.new(Hint.HintTechnique.W_WING, "")
						for idx in new_path:
							hint.cells.append(nodes[idx].pos)
						for v in elim_cells:
							hint.elim_cells.append(v)
						hint.elim_numbers.append(elim_digit + 1)
						var pair_disp = "{" + str(start_pair[0]+1) + "/" + str(start_pair[1]+1) + "}"
						var s1w = "W-Wing: two bivalue cells %s at %s and %s, linked via conjugate pairs on digit %d." % [pair_disp, _format_cell_list([a]), _format_cell_list([b]), linking_digit + 1]
						hint.add_step(s1w, [a, b])
						var s2w = "Thus the other candidate (%d) is synchronized; any cell seeing both endpoints cannot be %d." % [elim_digit + 1, elim_digit + 1]
						hint.add_step(s2w, [a, b])
						var s3w = "Eliminate %d from: %s" % [elim_digit + 1, _format_cell_list(elim_cells)]
						hint.add_step(s3w, [], [], [], elim_cells.duplicate(), [elim_digit + 1])
						hint.description = s1w + "\n\n" + s2w + "\n\n" + s3w
						hints.append(hint)
						emitted[wwing_key] = true
					# Continue exploring - don't return here

		# Handle Type-1 (endpoints do not share a unit) when chain length >=4 and parity matches
		if next_active == start_digit and new_path.size() >= 4:
			var a = nodes[start_idx].pos
			var b = nodes[next_idx].pos
			if _are_peers(a, b):
				# Endpoints share a unit – not Type-1
				pass
			var key = str(start_idx) + ":" + str(next_idx) + ":" + str(start_digit)
			if not emitted.has(key):
				var start_pair: PackedInt32Array = nodes[start_idx].pair
				var end_pair: PackedInt32Array = nodes[next_idx].pair
				var is_two_node = new_path.size() == 2
				var same_pair = (start_pair[0] == end_pair[0] and start_pair[1] == end_pair[1]) or (start_pair[0] == end_pair[1] and start_pair[1] == end_pair[0])
				var technique = Hint.HintTechnique.XY_CHAIN  # W-Wing already handled above
				# Determine which digit is eliminated and collect correct targets
				var elim_digit = start_digit
				if technique == Hint.HintTechnique.W_WING:
					var pair0 = nodes[start_idx].pair
					var other_digit = pair0[0] if pair0[1] == used_digit else pair0[1]
					elim_digit = other_digit
				var elim_cells: Array[Vector2i] = []
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0: continue
						if not _get_candidates(r,c).get_bit(elim_digit): continue
						var v = Vector2i(r,c)
						if _are_peers(v, a) and _are_peers(v, b) and v != a and v != b:
							elim_cells.append(v)
				if elim_cells.size() > 0:
					var hint = Hint.new(technique, "")
					for idx in new_path:
						hint.cells.append(nodes[idx].pos)
					for v in elim_cells:
						hint.elim_cells.append(v)
					hint.elim_numbers.append(elim_digit + 1)
					if technique == Hint.HintTechnique.XY_CHAIN:
						var chain_text = []
						for i in range(new_path.size()):
							chain_text.append(_format_cell_list([nodes[new_path[i]].pos]) + " {" + str(nodes[new_path[i]].pair[0]+1) + "/" + str(nodes[new_path[i]].pair[1]+1) + "}")
						var s1 = "XY-Chain on digit %d: %s" % [elim_digit + 1, " -> ".join(chain_text)]
						hint.add_step(s1, hint.cells.duplicate())
						var s2 = "Endpoints both force %d. Any cell seeing both endpoints cannot be %d." % [elim_digit + 1, elim_digit + 1]
						hint.add_step(s2, [nodes[start_idx].pos, nodes[next_idx].pos])
						var s3 = "Eliminate %d from: %s" % [elim_digit + 1, _format_cell_list(hint.elim_cells)]
						hint.add_step(s3, [], [], [], hint.elim_cells.duplicate(), [elim_digit + 1])
						hint.description = s1 + "\n\n" + s2 + "\n\n" + s3
						hints.append(hint)
						emitted[key] = true
					else:
						var pair_disp = "{" + str(nodes[start_idx].pair[0]+1) + "/" + str(nodes[start_idx].pair[1]+1) + "}"
						var s1w = "W-Wing: two bivalue cells %s at %s and %s, linked on one candidate forming a conjugate pair." % [pair_disp, _format_cell_list([nodes[start_idx].pos]), _format_cell_list([nodes[next_idx].pos])]
						hint.add_step(s1w, [nodes[start_idx].pos, nodes[next_idx].pos])
						var s2w = "Thus the other candidate (%d) is synchronized; any cell seeing both endpoints cannot be %d." % [elim_digit + 1, elim_digit + 1]
						hint.add_step(s2w, [nodes[start_idx].pos, nodes[next_idx].pos])
						var s3w = "Eliminate %d from: %s" % [elim_digit + 1, _format_cell_list(hint.elim_cells)]
						hint.add_step(s3w, [], [], [], hint.elim_cells.duplicate(), [elim_digit + 1])
						hint.description = s1w + "\n\n" + s2w + "\n\n" + s3w
						hints.append(hint)
						emitted[key] = true
		# No-op for other cases; continue exploring chain

		_xychain_dfs(nodes, adj, next_idx, next_active, start_idx, start_digit, visited, new_path, hints, emitted)

func _get_candidates(r: int, c: int) -> BitSet:
	return generator_ref._get_candidates(r, c)

func _are_peers(c1: Vector2i, c2: Vector2i) -> bool:
	return generator_ref._are_peers(c1, c2)

func _format_cell_list(cells: Array[Vector2i]) -> String:
	return generator_ref._format_cell_list(cells)
