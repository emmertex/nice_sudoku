extends RefCounted
class_name RemotePairSolver

func name() -> String:
	return "Remote Pair Solver"

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	var bivalue_cells = []
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cand = generator._get_candidates(r, c)
			if cand.cardinality() == 2:
				var d1 = cand.next_set_bit(0)
				var d2 = cand.next_set_bit(d1 + 1)
				bivalue_cells.append({"pos": Vector2i(r, c), "pair": PackedInt32Array([d1, d2])})

	if bivalue_cells.size() < 2:
		return

	var pairs_map = {}
	for cell_data in bivalue_cells:
		var pair_key = str(cell_data.pair[0]) + "," + str(cell_data.pair[1])
		if not pairs_map.has(pair_key):
			pairs_map[pair_key] = []
		pairs_map[pair_key].append(cell_data)

	for pair_key in pairs_map.keys():
		var cells_with_pair = pairs_map[pair_key]
		if cells_with_pair.size() < 2:
			continue
		var pair = cells_with_pair[0].pair
		var A = pair[0]
		var B = pair[1]

		var adj = []
		for _i in range(cells_with_pair.size()):
			adj.append([])

		for i in range(cells_with_pair.size()):
			for j in range(i + 1, cells_with_pair.size()):
				var cell1 = cells_with_pair[i].pos
				var cell2 = cells_with_pair[j].pos
				if generator._are_peers(cell1, cell2):
					adj[i].append(j)
					adj[j].append(i)

		var emitted = {}
		for start_idx in range(cells_with_pair.size()):
			var visited = {}
			var path = [start_idx]
			_remote_pair_dfs(generator, cells_with_pair, adj, start_idx, visited, path, hints, emitted, A, B)

func _remote_pair_dfs(generator: SudokuHintGenerator, cells: Array, adj: Array, curr_idx: int, visited: Dictionary, path: Array, hints: Array[Hint], emitted: Dictionary, A: int, B: int) -> void:
	if visited.has(curr_idx):
		return
	visited[curr_idx] = true

	if path.size() >= 2:
		var start_cell = cells[path[0]].pos
		var end_cell = cells[curr_idx].pos
		if not generator._are_peers(start_cell, end_cell):
			var key = str(start_cell) + ":" + str(end_cell) + ":remotepair"
			if not emitted.has(key):
				for elim_digit in [A, B]:
					var elim_cells = []
					for r in range(9):
						for c in range(9):
							if generator.sudoku.grid[r][c] != 0:
								continue
							var cell = Vector2i(r, c)
							if cell == start_cell or cell == end_cell:
								continue
							var in_chain = false
							for idx in path:
								if cells[idx].pos == cell:
									in_chain = true
									break
							if in_chain:
								continue
							if not generator._get_candidates(r, c).get_bit(elim_digit):
								continue
							if generator._are_peers(cell, start_cell) and generator._are_peers(cell, end_cell):
								elim_cells.append(cell)

					if elim_cells.size() > 0:
						var hint = Hint.new(Hint.HintTechnique.REMOTE_PAIR, "")
						for idx in path:
							hint.cells.append(cells[idx].pos)
						hint.cells.append(cells[curr_idx].pos)
						hint.numbers.append(A + 1)
						hint.numbers.append(B + 1)
						hint.elim_cells.append_array(elim_cells)
						hint.elim_numbers.append(elim_digit + 1)

						var chain_text = []
						for idx in path:
							chain_text.append(generator._format_cell_list([cells[idx].pos]))
						chain_text.append(generator._format_cell_list([cells[curr_idx].pos]))

						var desc = "Remote Pair chain on {%d/%d}: %s.\n\n" % [A + 1, B + 1, " -> ".join(chain_text)]
						desc += "All cells in the chain have the same pair {%d/%d}.\n" % [A + 1, B + 1]
						desc += "If start is %d, end must be %d (or vice versa), synchronizing the pair.\n\n" % [A + 1, B + 1]
						desc += "Eliminate %d from cells seeing both endpoints: %s." % [elim_digit + 1, generator._format_cell_list(elim_cells)]
						hint.description = desc

						var s1 = "Remote Pair chain: %s (all have {%d/%d})." % [" -> ".join(chain_text), A + 1, B + 1]
						hint.add_step(s1, hint.cells.duplicate())
						var s2 = "Eliminate %d from cells seeing both endpoints: %s." % [elim_digit + 1, generator._format_cell_list(elim_cells)]
						hint.add_step(s2, [start_cell, end_cell], [], [], elim_cells.duplicate(), [elim_digit + 1])

						hints.append(hint)
						emitted[key] = true
						break

	for next_idx in adj[curr_idx]:
		if visited.has(next_idx):
			continue
		var new_path = path.duplicate()
		new_path.append(next_idx)
		_remote_pair_dfs(generator, cells, adj, next_idx, visited, new_path, hints, emitted, A, B)

	visited.erase(curr_idx)




