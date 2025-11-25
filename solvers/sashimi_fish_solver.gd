extends RefCounted
class_name SashimiFishSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	for digit in range(1, 10):
		var d = digit - 1
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if generator._get_candidates(r, c).get_bit(d):
					positions.set_bit(c)
			if positions.cardinality() >= 2 and positions.cardinality() <= 3:
				row_candidates[r] = positions

		if row_candidates.size() >= 2:
			var rows = row_candidates.keys()
			for i in range(rows.size()):
				for j in range(i + 1, rows.size()):
					var r1 = rows[i]
					var r2 = rows[j]
					var union_cols = row_candidates[r1].union(row_candidates[r2])

					if union_cols.cardinality() == 2:
						var cols = []
						for c in range(9):
							if union_cols.get_bit(c):
								cols.append(c)

						var sashimi_cells = []
						for c in cols:
							if row_candidates[r1].get_bit(c):
								sashimi_cells.append(Vector2i(r1, c))
							if row_candidates[r2].get_bit(c):
								sashimi_cells.append(Vector2i(r2, c))

						if sashimi_cells.size() == 3:
							var elim_cells = []
							for c in cols:
								for r_check in range(9):
									if r_check != r1 and r_check != r2:
										var cell = Vector2i(r_check, c)
										if generator._get_candidates(r_check, c).get_bit(d):
											elim_cells.append(cell)

							if elim_cells.size() > 0:
								var hint = Hint.new(Hint.HintTechnique.SASHIMI_X_WING, "")
								hint.cells.append_array(sashimi_cells)
								hint.numbers.append(digit)
								hint.elim_cells.append_array(elim_cells)
								hint.elim_numbers.append(digit)
								var desc = "Sashimi X-Wing on digit %d: rows %d and %d, columns %d and %d (one cell missing).\n\n" % [digit, r1 + 1, r2 + 1, cols[0] + 1, cols[1] + 1]
								desc += "Eliminate %d from: %s." % [digit, generator._format_cell_list(elim_cells)]
								hint.description = desc
								var s1 = "Sashimi X-Wing on digit %d: rows %d, %d in columns %d, %d (incomplete pattern)." % [digit, r1 + 1, r2 + 1, cols[0] + 1, cols[1] + 1]
								hint.add_step(s1, sashimi_cells.duplicate())
								var s2 = "Eliminate %d from: %s." % [digit, generator._format_cell_list(elim_cells)]
								hint.add_step(s2, [], [], [], elim_cells.duplicate(), [digit])
								hints.append(hint)

		if row_candidates.size() >= 3:
			var rows = row_candidates.keys()
			for i in range(rows.size()):
				for j in range(i + 1, rows.size()):
					for k in range(j + 1, rows.size()):
						var r1 = rows[i]
						var r2 = rows[j]
						var r3 = rows[k]
						var union_cols = row_candidates[r1].union(row_candidates[r2]).union(row_candidates[r3])

						if union_cols.cardinality() == 3:
							var cols = []
							for c in range(9):
								if union_cols.get_bit(c):
									cols.append(c)

							var sashimi_cells = []
							for c in cols:
								for r_idx in [r1, r2, r3]:
									if row_candidates[r_idx].get_bit(c):
										sashimi_cells.append(Vector2i(r_idx, c))

							if sashimi_cells.size() >= 6 and sashimi_cells.size() < 9:
								var elim_cells = []
								for c in cols:
									for r_check in range(9):
										if not r_check in [r1, r2, r3]:
											var cell = Vector2i(r_check, c)
											if generator._get_candidates(r_check, c).get_bit(d):
												elim_cells.append(cell)

								if elim_cells.size() > 0:
									var hint = Hint.new(Hint.HintTechnique.SASHIMI_SWORDFISH, "")
									hint.cells.append_array(sashimi_cells)
									hint.numbers.append(digit)
									hint.elim_cells.append_array(elim_cells)
									hint.elim_numbers.append(digit)
									var desc = "Sashimi Swordfish on digit %d: rows %d, %d, %d in columns %d, %d, %d (incomplete pattern).\n\n" % [digit, r1 + 1, r2 + 1, r3 + 1, cols[0] + 1, cols[1] + 1, cols[2] + 1]
									desc += "Eliminate %d from: %s." % [digit, generator._format_cell_list(elim_cells)]
									hint.description = desc
									var s1 = "Sashimi Swordfish on digit %d: rows %d, %d, %d in columns %d, %d, %d." % [digit, r1 + 1, r2 + 1, r3 + 1, cols[0] + 1, cols[1] + 1, cols[2] + 1]
									hint.add_step(s1, sashimi_cells.duplicate())
									var s2 = "Eliminate %d from: %s." % [digit, generator._format_cell_list(elim_cells)]
									hint.add_step(s2, [], [], [], elim_cells.duplicate(), [digit])
									hints.append(hint)

