extends RefCounted
class_name XWingSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for digit in range(1, 10):
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if sudoku.grid[r][c] == 0 and generator._get_candidates(r, c).get_bit(digit - 1):
					positions.set_bit(c)
			if positions.cardinality() == 2:
				row_candidates[r] = positions

		if row_candidates.size() >= 2:
			var rows = row_candidates.keys()
			for i in range(rows.size()):
				for j in range(i + 1, rows.size()):
					var r1 = rows[i]
					var r2 = rows[j]
					var positions1 = row_candidates[r1]
					var positions2 = row_candidates[r2]
					var union_cols = positions1.union(positions2)
					if union_cols.cardinality() == 2:
						var cols = []
						for c in range(9):
							if union_cols.get_bit(c):
								cols.append(c)

						var hint = Hint.new(Hint.HintTechnique.X_WING_ROW, "X-Wing: on digit %d in rows %d and %d, covering columns %d and %d." % [digit, r1 + 1, r2 + 1, cols[0] + 1, cols[1] + 1])
						hint.cells.append_array([Vector2i(r1, cols[0]), Vector2i(r1, cols[1]), Vector2i(r2, cols[0]), Vector2i(r2, cols[1])])
						hint.numbers.append(digit)

						for c in cols:
							for r_check in range(9):
								if r_check != r1 and r_check != r2:
									var cell = Vector2i(r_check, c)
									hint.secondary_cells.append(cell)
									if generator._get_candidates(r_check, c).get_bit(digit - 1):
										hint.elim_cells.append(cell)

						if not hint.elim_cells.is_empty():
							hint.elim_numbers.append(digit)
							var desc = "Look at the rows %s and %s. The only places for a %d are in columns %d and %d.\n\n" % [r1 + 1, r2 + 1, digit, cols[0] + 1, cols[1] + 1]
							desc += "This forms an X-Wing. Since the %d in these rows must be in one of those two columns, we can eliminate %d as a candidate from all other cells in columns %d and %d.\n\n" % [digit, digit, cols[0] + 1, cols[1] + 1]
							desc += "Therefore, we can eliminate %d from: %s." % [digit, generator._format_cell_list(hint.elim_cells)]
							hint.description = desc
							var s1 = "Scan digit %d: rows %d and %d each have exactly two candidates in the same columns." % [digit, r1 + 1, r2 + 1]
							hint.add_step(s1, [Vector2i(r1, cols[0]), Vector2i(r1, cols[1]), Vector2i(r2, cols[0]), Vector2i(r2, cols[1])])
							var s2 = "These form the corners of an X-Wing. Thus, in columns %d and %d, %d cannot occur in any other row." % [cols[0] + 1, cols[1] + 1, digit]
							hint.add_step(s2, [], [], [], hint.elim_cells, [digit])
							var s3 = "Eliminate %d from: %s." % [digit, generator._format_cell_list(hint.elim_cells)]
							hint.add_step(s3, [], [], [], hint.elim_cells, [digit])
							hints.append(hint)

		var col_candidates = {}
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if sudoku.grid[r][c] == 0 and generator._get_candidates(r, c).get_bit(digit - 1):
					positions.set_bit(r)
			if positions.cardinality() == 2:
				col_candidates[c] = positions

		if col_candidates.size() >= 2:
			var cols = col_candidates.keys()
			for i in range(cols.size()):
				for j in range(i + 1, cols.size()):
					var c1 = cols[i]
					var c2 = cols[j]
					var positions1 = col_candidates[c1]
					var positions2 = col_candidates[c2]
					var union_rows = positions1.union(positions2)
					if union_rows.cardinality() == 2:
						var rows = []
						for r in range(9):
							if union_rows.get_bit(r):
								rows.append(r)

						var hint = Hint.new(Hint.HintTechnique.X_WING_COL, "X-Wing: on digit %d in columns %d and %d, covering rows %d and %d." % [digit, c1 + 1, c2 + 1, rows[0] + 1, rows[1] + 1])
						hint.cells.append_array([Vector2i(rows[0], c1), Vector2i(rows[1], c1), Vector2i(rows[0], c2), Vector2i(rows[1], c2)])
						hint.numbers.append(digit)

						for r in rows:
							for c_check in range(9):
								if c_check != c1 and c_check != c2:
									var cell = Vector2i(r, c_check)
									hint.secondary_cells.append(cell)
									if generator._get_candidates(r, c_check).get_bit(digit - 1):
										hint.elim_cells.append(cell)

						if not hint.elim_cells.is_empty():
							hint.elim_numbers.append(digit)
							var desc = "Look at the columns %s and %s. The only places for a %d are in rows %d and %d.\n\n" % [c1 + 1, c2 + 1, digit, rows[0] + 1, rows[1] + 1]
							desc += "This forms an X-Wing. Since the %d in these columns must be in one of those two rows, we can eliminate %d as a candidate from all other cells in rows %d and %d.\n\n" % [digit, digit, rows[0] + 1, rows[1] + 1]
							desc += "Therefore, we can eliminate %d from: %s." % [digit, generator._format_cell_list(hint.elim_cells)]
							hint.description = desc
							var s1c = "Scan digit %d: columns %d and %d each have exactly two candidates in the same rows." % [digit, c1 + 1, c2 + 1]
							hint.add_step(s1c, [Vector2i(rows[0], c1), Vector2i(rows[1], c1), Vector2i(rows[0], c2), Vector2i(rows[1], c2)])
							var s2c = "These form the corners of an X-Wing. Thus, in rows %d and %d, %d cannot occur in any other column." % [rows[0] + 1, rows[1] + 1, digit]
							hint.add_step(s2c, [], [], [], hint.elim_cells, [digit])
							var s3c = "Eliminate %d from: %s." % [digit, generator._format_cell_list(hint.elim_cells)]
							hint.add_step(s3c, [], [], [], hint.elim_cells, [digit])
							hints.append(hint)




