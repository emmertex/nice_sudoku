extends RefCounted
class_name XYWingSolver

func name() -> String:
	return "XY-Wing Solver"

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

	if bivalue_cells.size() < 3:
		return

	var emitted = {}
	for pivot_idx in range(bivalue_cells.size()):
		var pivot = bivalue_cells[pivot_idx]
		var pivot_pos = pivot.pos
		var pivot_pair = pivot.pair
		var X = pivot_pair[0]
		var Y = pivot_pair[1]

		for wing1_idx in range(bivalue_cells.size()):
			if wing1_idx == pivot_idx:
				continue
			var wing1 = bivalue_cells[wing1_idx]
			var wing1_pos = wing1.pos
			var wing1_pair = wing1.pair

			if not generator._are_peers(pivot_pos, wing1_pos):
				continue
			if wing1_pair.find(X) == -1:
				continue

			var Z = wing1_pair[0] if wing1_pair[1] == X else wing1_pair[1]
			if Z == Y:
				continue

			for wing2_idx in range(bivalue_cells.size()):
				if wing2_idx == pivot_idx or wing2_idx == wing1_idx:
					continue
				var wing2 = bivalue_cells[wing2_idx]
				var wing2_pos = wing2.pos
				var wing2_pair = wing2.pair

				if wing2_pair.find(Y) == -1 or wing2_pair.find(Z) == -1:
					continue
				if not generator._are_peers(pivot_pos, wing2_pos):
					continue
				if not generator._are_peers(wing1_pos, wing2_pos):
					continue

				var elim_cells = []
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0:
							continue
						var cell_pos = Vector2i(r, c)
						if cell_pos == pivot_pos or cell_pos == wing1_pos or cell_pos == wing2_pos:
							continue
						if not generator._get_candidates(r, c).get_bit(Z):
							continue
						if generator._are_peers(cell_pos, wing1_pos) and generator._are_peers(cell_pos, wing2_pos):
							elim_cells.append(cell_pos)

				if elim_cells.size() > 0:
					var key = str(pivot_pos) + ":" + str(wing1_pos) + ":" + str(wing2_pos) + ":" + str(Z)
					if emitted.has(key):
						continue
					var hint = Hint.new(Hint.HintTechnique.XY_WING, "")
					hint.cells.append(pivot_pos)
					hint.cells.append(wing1_pos)
					hint.cells.append(wing2_pos)
					hint.numbers.append(X + 1)
					hint.numbers.append(Y + 1)
					hint.numbers.append(Z + 1)
					hint.elim_cells.append_array(elim_cells)
					hint.elim_numbers.append(Z + 1)

					var desc = "XY-Wing: Pivot %s {%d/%d}, Wing1 %s {%d/%d}, Wing2 %s {%d/%d}.\n\n" % [
						generator._format_cell_list([pivot_pos]), X + 1, Y + 1,
						generator._format_cell_list([wing1_pos]), X + 1, Z + 1,
						generator._format_cell_list([wing2_pos]), Y + 1, Z + 1
					]
					desc += "If pivot is %d, wing1 must be %d, forcing wing2 to be %d.\n" % [X + 1, Z + 1, Y + 1]
					desc += "If pivot is %d, wing2 must be %d, forcing wing1 to be %d.\n\n" % [Y + 1, Z + 1, X + 1]
					desc += "Either way, one wing must be %d, so eliminate %d from cells seeing both wings: %s." % [Z + 1, Z + 1, generator._format_cell_list(elim_cells)]
					hint.description = desc

					var s1 = "XY-Wing found: Pivot %s {%d/%d}, Wing1 %s {%d/%d}, Wing2 %s {%d/%d}." % [
						generator._format_cell_list([pivot_pos]), X + 1, Y + 1,
						generator._format_cell_list([wing1_pos]), X + 1, Z + 1,
						generator._format_cell_list([wing2_pos]), Y + 1, Z + 1
					]
					hint.add_step(s1, [pivot_pos, wing1_pos, wing2_pos])
					var s2 = "One wing must be %d, so eliminate %d from cells seeing both wings." % [Z + 1, Z + 1]
					hint.add_step(s2, [wing1_pos, wing2_pos], [], [], elim_cells.duplicate(), [Z + 1])

					hints.append(hint)
					emitted[key] = true




