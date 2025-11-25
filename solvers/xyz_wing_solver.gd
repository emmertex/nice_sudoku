extends RefCounted
class_name XYZWingSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var pivot_cand = generator._get_candidates(r, c)
			if pivot_cand.cardinality() != 3:
				continue

			var pivot_digits = []
			for d in range(9):
				if pivot_cand.get_bit(d):
					pivot_digits.append(d)

			var X = pivot_digits[0]
			var Y = pivot_digits[1]
			var Z = pivot_digits[2]
			var pivot_pos = Vector2i(r, c)

			for r1 in range(9):
				for c1 in range(9):
					if sudoku.grid[r1][c1] != 0:
						continue
					var wing1_pos = Vector2i(r1, c1)
					if wing1_pos == pivot_pos:
						continue
					if not generator._are_peers(pivot_pos, wing1_pos):
						continue
					var wing1_cand = generator._get_candidates(r1, c1)
					if wing1_cand.cardinality() != 2:
						continue
					var w1d1 = wing1_cand.next_set_bit(0)
					var w1d2 = wing1_cand.next_set_bit(w1d1 + 1)
					if not ((w1d1 == X and w1d2 == Z) or (w1d1 == Z and w1d2 == X)):
						continue

					for r2 in range(9):
						for c2 in range(9):
							if sudoku.grid[r2][c2] != 0:
								continue
							var wing2_pos = Vector2i(r2, c2)
							if wing2_pos == pivot_pos or wing2_pos == wing1_pos:
								continue
							if not generator._are_peers(pivot_pos, wing2_pos):
								continue
							if not generator._are_peers(wing1_pos, wing2_pos):
								continue
							var wing2_cand = generator._get_candidates(r2, c2)
							if wing2_cand.cardinality() != 2:
								continue
							var w2d1 = wing2_cand.next_set_bit(0)
							var w2d2 = wing2_cand.next_set_bit(w2d1 + 1)
							if not ((w2d1 == Y and w2d2 == Z) or (w2d1 == Z and w2d2 == Y)):
								continue

							var elim_cells = []
							for rr in range(9):
								for cc in range(9):
									if sudoku.grid[rr][cc] != 0:
										continue
									var cell_pos = Vector2i(rr, cc)
									if cell_pos == pivot_pos or cell_pos == wing1_pos or cell_pos == wing2_pos:
										continue
									if not generator._get_candidates(rr, cc).get_bit(Z):
										continue
									if generator._are_peers(cell_pos, wing1_pos) and generator._are_peers(cell_pos, wing2_pos):
										elim_cells.append(cell_pos)

							if elim_cells.size() > 0:
								var key = str(pivot_pos) + ":" + str(wing1_pos) + ":" + str(wing2_pos) + ":xyz"
								var already = hints.any(func(h): return h.technique == Hint.HintTechnique.XYZ_WING and h.cells.has(pivot_pos))
								if already:
									continue
								var hint = Hint.new(Hint.HintTechnique.XYZ_WING, "")
								hint.cells.append(pivot_pos)
								hint.cells.append(wing1_pos)
								hint.cells.append(wing2_pos)
								hint.numbers.append(X + 1)
								hint.numbers.append(Y + 1)
								hint.numbers.append(Z + 1)
								hint.elim_cells.append_array(elim_cells)
								hint.elim_numbers.append(Z + 1)

								var desc = "XYZ-Wing: Pivot %s {%d/%d/%d}, Wing1 %s {%d/%d}, Wing2 %s {%d/%d}.\n\n" % [
									generator._format_cell_list([pivot_pos]), X + 1, Y + 1, Z + 1,
									generator._format_cell_list([wing1_pos]), X + 1, Z + 1,
									generator._format_cell_list([wing2_pos]), Y + 1, Z + 1
								]
								desc += "If pivot is %d, wing1 must be %d, forcing wing2 to be %d.\n" % [X + 1, Z + 1, Y + 1]
								desc += "If pivot is %d, wing2 must be %d, forcing wing1 to be %d.\n" % [Y + 1, Z + 1, X + 1]
								desc += "If pivot is %d, both wings must be %d or %d.\n\n" % [Z + 1, X + 1, Y + 1]
								desc += "Either way, one wing must be %d, so eliminate %d from cells seeing both wings: %s." % [Z + 1, Z + 1, generator._format_cell_list(elim_cells)]
								hint.description = desc

								var s1 = "XYZ-Wing: Pivot %s {%d/%d/%d}, Wing1 %s {%d/%d}, Wing2 %s {%d/%d}." % [
									generator._format_cell_list([pivot_pos]), X + 1, Y + 1, Z + 1,
									generator._format_cell_list([wing1_pos]), X + 1, Z + 1,
									generator._format_cell_list([wing2_pos]), Y + 1, Z + 1
								]
								hint.add_step(s1, [pivot_pos, wing1_pos, wing2_pos])
								var s2 = "One wing must be %d, eliminate %d from cells seeing both wings." % [Z + 1, Z + 1]
								hint.add_step(s2, [wing1_pos, wing2_pos], [], [], elim_cells.duplicate(), [Z + 1])

								hints.append(hint)

