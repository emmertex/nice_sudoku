extends RefCounted
class_name JellyfishSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	for digit in range(1, 10):
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if generator._get_candidates(r, c).get_bit(digit - 1):
					positions.set_bit(c)
			if positions.cardinality() > 1 and positions.cardinality() < 5:
				row_candidates[r] = positions

		if row_candidates.size() >= 4:
			var rows = row_candidates.keys()
			for i in range(rows.size()):
				for j in range(i + 1, rows.size()):
					for k in range(j + 1, rows.size()):
						for l in range(k + 1, rows.size()):
							var r1 = rows[i]
							var r2 = rows[j]
							var r3 = rows[k]
							var r4 = rows[l]
							var union_cols = row_candidates[r1].union(row_candidates[r2]).union(row_candidates[r3]).union(row_candidates[r4])
							if union_cols.cardinality() == 4:
								var cols = []
								for c in range(9):
									if union_cols.get_bit(c):
										cols.append(c)
								var hint = Hint.new(Hint.HintTechnique.JELLYFISH_ROW, "Jellyfish: on digit %d" % digit)
								for r_idx in [r1, r2, r3, r4]:
									for c in cols:
										if generator._get_candidates(r_idx, c).get_bit(digit - 1):
											hint.cells.append(Vector2i(r_idx, c))
								hint.numbers.append(digit)

								for c in cols:
									for r_check in range(9):
										if not r_check in [r1, r2, r3, r4]:
											var cell = Vector2i(r_check, c)
											hint.secondary_cells.append(cell)
											if generator._get_candidates(r_check, c).get_bit(digit - 1):
												hint.elim_cells.append(cell)

								if not hint.elim_cells.is_empty():
									hint.elim_numbers.append(digit)
									var r_str = ", ".join([str(r1 + 1), str(r2 + 1), str(r3 + 1), str(r4 + 1)])
									var c_str = ", ".join([str(cols[0] + 1), str(cols[1] + 1), str(cols[2] + 1), str(cols[3] + 1)])
									var desc = "A Jellyfish pattern exists for the number %d.\n\n" % digit
									desc += "In rows %s, the only places for a %d are in columns %s. " % [r_str, digit, c_str]
									desc += "This means that in these four columns, the %d must be in one of the four rows.\n\n" % digit
									desc += "Therefore, we can eliminate %d from other cells in these columns: %s" % [digit, generator._format_cell_list(hint.elim_cells)]
									hint.description = desc
									var jfs1 = "Jellyfish on digit %d across rows %s and columns %s." % [digit, r_str, c_str]
									hint.add_step(jfs1, hint.cells.duplicate())
									var jfs2 = "Thus only these rows can hold %d in those columns; eliminate elsewhere in those columns." % [digit]
									hint.add_step(jfs2, [], [], [], hint.elim_cells.duplicate(), [digit])
									hints.append(hint)

		var col_candidates = {}
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if generator._get_candidates(r, c).get_bit(digit - 1):
					positions.set_bit(r)
			if positions.cardinality() > 1 and positions.cardinality() < 5:
				col_candidates[c] = positions

		if col_candidates.size() >= 4:
			var cols = col_candidates.keys()
			for i in range(cols.size()):
				for j in range(i + 1, cols.size()):
					for k in range(j + 1, cols.size()):
						for l in range(k + 1, cols.size()):
							var c1 = cols[i]
							var c2 = cols[j]
							var c3 = cols[k]
							var c4 = cols[l]
							var union_rows = col_candidates[c1].union(col_candidates[c2]).union(col_candidates[c3]).union(col_candidates[c4])
							if union_rows.cardinality() == 4:
								var rows = []
								for r in range(9):
									if union_rows.get_bit(r):
										rows.append(r)
								var hint = Hint.new(Hint.HintTechnique.JELLYFISH_COL, "Jellyfish: on digit %d" % digit)
								for c_idx in [c1, c2, c3, c4]:
									for r_idx in rows:
										if generator._get_candidates(r_idx, c_idx).get_bit(digit - 1):
											hint.cells.append(Vector2i(r_idx, c_idx))
								hint.numbers.append(digit)

								for r_idx in rows:
									for c_check in range(9):
										if not c_check in [c1, c2, c3, c4]:
											var cell = Vector2i(r_idx, c_check)
											hint.secondary_cells.append(cell)
											if generator._get_candidates(r_idx, c_check).get_bit(digit - 1):
												hint.elim_cells.append(cell)

								if not hint.elim_cells.is_empty():
									hint.elim_numbers.append(digit)
									var c_str = ", ".join([str(c1 + 1), str(c2 + 1), str(c3 + 1), str(c4 + 1)])
									var r_str = ", ".join([str(rows[0] + 1), str(rows[1] + 1), str(rows[2] + 1), str(rows[3] + 1)])
									var desc = "A Jellyfish pattern exists for the number %d.\n\n" % digit
									desc += "In columns %s, the only places for a %d are in rows %s. " % [c_str, digit, r_str]
									desc += "This means that in these four rows, the %d must be in one of the four columns.\n\n" % digit
									desc += "Therefore, we can eliminate %d from other cells in these rows: %s" % [digit, generator._format_cell_list(hint.elim_cells)]
									hint.description = desc
									var jfs1c = "Jellyfish on digit %d across columns %s and rows %s." % [digit, c_str, r_str]
									hint.add_step(jfs1c, hint.cells.duplicate())
									var jfs2c = "Thus only these columns can hold %d in those rows; eliminate elsewhere in those rows." % [digit]
									hint.add_step(jfs2c, [], [], [], hint.elim_cells.duplicate(), [digit])
									hints.append(hint)




