extends RefCounted
class_name SwordfishSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for digit in range(1, 10):
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if generator._get_candidates(r, c).get_bit(digit - 1):
					positions.set_bit(c)
			if positions.cardinality() > 1 and positions.cardinality() < 4:
				row_candidates[r] = positions

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

							var hint = Hint.new(Hint.HintTechnique.SWORDFISH_ROW, "Swordfish: on digit %d" % digit)
							for r_idx in [r1, r2, r3]:
								for c in cols:
									if generator._get_candidates(r_idx, c).get_bit(digit - 1):
										hint.cells.append(Vector2i(r_idx, c))
							hint.numbers.append(digit)

							for c in cols:
								for r_check in range(9):
									if not r_check in [r1, r2, r3]:
										var cell = Vector2i(r_check, c)
										hint.secondary_cells.append(cell)
										if generator._get_candidates(r_check, c).get_bit(digit - 1):
											hint.elim_cells.append(cell)

							if not hint.elim_cells.is_empty():
								hint.elim_numbers.append(digit)
								var desc = "A Swordfish pattern exists for the number %d.\n\n" % digit
								desc += "In rows %s, %s, and %s, the only places for a %d are in columns %s, %s, and %s. " % [r1 + 1, r2 + 1, r3 + 1, digit, cols[0] + 1, cols[1] + 1, cols[2] + 1]
								desc += "This means that in these three columns, the %d must be in one of the three rows.\n\n" % digit
								desc += "Therefore, we can eliminate %d from other cells in these columns: %s" % [digit, generator._format_cell_list(hint.elim_cells)]
								hint.description = desc
								var sfs1 = "Swordfish on digit %d across rows %d, %d, %d in columns %d, %d, %d." % [digit, r1 + 1, r2 + 1, r3 + 1, cols[0] + 1, cols[1] + 1, cols[2] + 1]
								hint.add_step(sfs1, hint.cells.duplicate())
								var sfs2 = "Thus in columns %d, %d, %d, only those rows can hold %d; eliminate elsewhere in those columns." % [cols[0] + 1, cols[1] + 1, cols[2] + 1, digit]
								hint.add_step(sfs2, [], [], [], hint.elim_cells.duplicate(), [digit])
								hints.append(hint)

		var col_candidates = {}
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if generator._get_candidates(r, c).get_bit(digit - 1):
					positions.set_bit(r)
			if positions.cardinality() > 1 and positions.cardinality() < 4:
				col_candidates[c] = positions

		if col_candidates.size() >= 3:
			var cols = col_candidates.keys()
			for i in range(cols.size()):
				for j in range(i + 1, cols.size()):
					for k in range(j + 1, cols.size()):
						var c1 = cols[i]
						var c2 = cols[j]
						var c3 = cols[k]
						var union_rows = col_candidates[c1].union(col_candidates[c2]).union(col_candidates[c3])
						if union_rows.cardinality() == 3:
							var rows = []
							for r in range(9):
								if union_rows.get_bit(r):
									rows.append(r)

							var hint = Hint.new(Hint.HintTechnique.SWORDFISH_COL, "Swordfish: on digit %d" % digit)
							for c_idx in [c1, c2, c3]:
								for r_idx in rows:
									if generator._get_candidates(r_idx, c_idx).get_bit(digit - 1):
										hint.cells.append(Vector2i(r_idx, c_idx))
							hint.numbers.append(digit)

							for r_idx in rows:
								for c_check in range(9):
									if not c_check in [c1, c2, c3]:
										var cell = Vector2i(r_idx, c_check)
										hint.secondary_cells.append(cell)
										if generator._get_candidates(r_idx, c_check).get_bit(digit - 1):
											hint.elim_cells.append(cell)

							if not hint.elim_cells.is_empty():
								hint.elim_numbers.append(digit)
								var desc = "A Swordfish pattern exists for the number %d.\n\n" % digit
								desc += "In columns %s, %s, and %s, the only places for a %d are in rows %s, %s, and %s. " % [c1 + 1, c2 + 1, c3 + 1, digit, rows[0] + 1, rows[1] + 1, rows[2] + 1]
								desc += "This means that in these three rows, the %d must be in one of the three columns.\n\n" % digit
								desc += "Therefore, we can eliminate %d from other cells in these rows: %s" % [digit, generator._format_cell_list(hint.elim_cells)]
								hint.description = desc
								var sfs1c = "Swordfish on digit %d across columns %d, %d, %d in rows %d, %d, %d." % [digit, c1 + 1, c2 + 1, c3 + 1, rows[0] + 1, rows[1] + 1, rows[2] + 1]
								hint.add_step(sfs1c, hint.cells.duplicate())
								var sfs2c = "Thus in rows %d, %d, %d, only those columns can hold %d; eliminate elsewhere in those rows." % [rows[0] + 1, rows[1] + 1, rows[2] + 1, digit]
								hint.add_step(sfs2c, [], [], [], hint.elim_cells.duplicate(), [digit])
								hints.append(hint)




