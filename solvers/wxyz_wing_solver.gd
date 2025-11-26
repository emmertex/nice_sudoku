extends RefCounted
class_name WXYZWingSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var pivot_cand = generator._get_candidates(r, c)
			if pivot_cand.cardinality() != 4:
				continue

			var pivot_digits = []
			for d in range(9):
				if pivot_cand.get_bit(d):
					pivot_digits.append(d)

			var W = pivot_digits[0]
			var X = pivot_digits[1]
			var Y = pivot_digits[2]
			var Z = pivot_digits[3]
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
					var wing1_size = wing1_cand.cardinality()
					if wing1_size < 2 or wing1_size > 3:
						continue
					if not wing1_cand.get_bit(X) or not wing1_cand.get_bit(Z):
						continue
					if not pivot_cand.intersection(wing1_cand).equals(wing1_cand):
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
							var wing2_size = wing2_cand.cardinality()
							if wing2_size < 2 or wing2_size > 3:
								continue
							if not wing2_cand.get_bit(Y) or not wing2_cand.get_bit(Z):
								continue
							if not pivot_cand.intersection(wing2_cand).equals(wing2_cand):
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
								var key = str(pivot_pos) + ":" + str(wing1_pos) + ":" + str(wing2_pos) + ":wxyz"
								var already = hints.any(func(h): return h.technique == Hint.HintTechnique.WXYZ_WING and h.cells.has(pivot_pos))
								if already:
									continue
								var hint = Hint.new(Hint.HintTechnique.WXYZ_WING, "")
								hint.cells.append(pivot_pos)
								hint.cells.append(wing1_pos)
								hint.cells.append(wing2_pos)
								hint.numbers.append(W + 1)
								hint.numbers.append(X + 1)
								hint.numbers.append(Y + 1)
								hint.numbers.append(Z + 1)
								hint.elim_cells.append_array(elim_cells)
								hint.elim_numbers.append(Z + 1)

								var wing1_digits = []
								for dd in range(9):
									if wing1_cand.get_bit(dd):
										wing1_digits.append(str(dd + 1))
								var wing1_str = "{%s}" % ", ".join(wing1_digits)
								var wing2_digits = []
								for dd in range(9):
									if wing2_cand.get_bit(dd):
										wing2_digits.append(str(dd + 1))
								var wing2_str = "{%s}" % ", ".join(wing2_digits)

								var desc = "WXYZ-Wing: Pivot %s {%d/%d/%d/%d}, Wing1 %s %s, Wing2 %s %s.\n\n" % [
									generator._format_cell_list([pivot_pos]), W + 1, X + 1, Y + 1, Z + 1,
									generator._format_cell_list([wing1_pos]), wing1_str,
									generator._format_cell_list([wing2_pos]), wing2_str
								]
								desc += "Eliminate %d from cells seeing both wings: %s." % [Z + 1, generator._format_cell_list(elim_cells)]
								hint.description = desc

								var s1 = "WXYZ-Wing: Pivot %s {%d/%d/%d/%d}, Wing1 %s %s, Wing2 %s %s." % [
									generator._format_cell_list([pivot_pos]), W + 1, X + 1, Y + 1, Z + 1,
									generator._format_cell_list([wing1_pos]), wing1_str,
									generator._format_cell_list([wing2_pos]), wing2_str
								]
								hint.add_step(s1, [pivot_pos, wing1_pos, wing2_pos])
								var s2 = "Eliminate %d from cells seeing both wings: %s." % [Z + 1, generator._format_cell_list(elim_cells)]
								hint.add_step(s2, [wing1_pos, wing2_pos], [], [], elim_cells.duplicate(), [Z + 1])

								hints.append(hint)




