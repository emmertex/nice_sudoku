extends RefCounted
class_name BoxLineSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for num in range(1, 10):
		for r in range(9):
			var row_cells_with_cand = []
			for c in range(9):
				if sudoku.grid[r][c] == 0 and generator._get_candidates(r, c).get_bit(num - 1):
					row_cells_with_cand.append(Vector2i(r, c))

			if row_cells_with_cand.size() > 0:
				var all_in_same_box = true
				var first_box = Cardinals.Bxy[row_cells_with_cand[0].x * 9 + row_cells_with_cand[0].y]
				for i in range(1, row_cells_with_cand.size()):
					var pos = row_cells_with_cand[i]
					if Cardinals.Bxy[pos.x * 9 + pos.y] != first_box:
						all_in_same_box = false
						break

				if all_in_same_box:
					var hint = Hint.new(Hint.HintTechnique.BOX_LINE_REDUCTION, "")
					hint.numbers.append(num)
					hint.cells.append_array(row_cells_with_cand)

					for i in range(9):
						var box_cell = Cardinals.box_to_rc(first_box, i)
						if box_cell.x != r:
							hint.secondary_cells.append(box_cell)
							if sudoku.grid[box_cell.x][box_cell.y] == 0 and generator._get_candidates(box_cell.x, box_cell.y).get_bit(num - 1):
								hint.elim_cells.append(box_cell)

					if not hint.elim_cells.is_empty():
						hint.elim_numbers.append(num)
						var desc = "In row %d, the only cells that can be a %d are all in the same box.\n\n" % [r + 1, num]
						desc += "This is a Box/Line Reduction. Since %d must be in this row, and all possibilities for it are in this box, the %d for this box must be in this row.\n\n" % [num, num]
						desc += "Therefore, we can eliminate %d as a candidate from other cells in this box: %s." % [num, generator._format_cell_list(hint.elim_cells)]
						hint.description = desc
						var s1blr = "In row %d, all %d candidates are within box %d." % [r + 1, num, first_box + 1]
						hint.add_step(s1blr, row_cells_with_cand.duplicate())
						var s2blr = "Therefore, remove %d from other cells in that box outside row %d." % [num, r + 1]
						hint.add_step(s2blr, [], [], [], hint.elim_cells.duplicate(), [num])
						hints.append(hint)

		for c in range(9):
			var col_cells_with_cand = []
			for r in range(9):
				if sudoku.grid[r][c] == 0 and generator._get_candidates(r, c).get_bit(num - 1):
					col_cells_with_cand.append(Vector2i(r, c))

			if col_cells_with_cand.size() > 0:
				var all_in_same_box = true
				var first_box = Cardinals.Bxy[col_cells_with_cand[0].x * 9 + col_cells_with_cand[0].y]
				for i in range(1, col_cells_with_cand.size()):
					var pos = col_cells_with_cand[i]
					if Cardinals.Bxy[pos.x * 9 + pos.y] != first_box:
						all_in_same_box = false
						break

				if all_in_same_box:
					var hint = Hint.new(Hint.HintTechnique.BOX_LINE_REDUCTION, "")
					hint.numbers.append(num)
					hint.cells.append_array(col_cells_with_cand)

					for i in range(9):
						var box_cell = Cardinals.box_to_rc(first_box, i)
						if box_cell.y != c:
							hint.secondary_cells.append(box_cell)
							if sudoku.grid[box_cell.x][box_cell.y] == 0 and generator._get_candidates(box_cell.x, box_cell.y).get_bit(num - 1):
								hint.elim_cells.append(box_cell)

					if not hint.elim_cells.is_empty():
						hint.elim_numbers.append(num)
						var desc = "In column %d, the only cells that can be a %d are all in the same box.\n\n" % [c + 1, num]
						desc += "This is a Box/Line Reduction. Since %d must be in this column, and all possibilities for it are in this box, the %d for this box must be in this column.\n\n" % [num, num]
						desc += "Therefore, we can eliminate %d as a candidate from other cells in this box: %s." % [num, generator._format_cell_list(hint.elim_cells)]
						hint.description = desc
						var s1blc = "In column %d, all %d candidates are within box %d." % [c + 1, num, first_box + 1]
						hint.add_step(s1blc, col_cells_with_cand.duplicate())
						var s2blc = "Therefore, remove %d from other cells in that box outside column %d." % [num, c + 1]
						hint.add_step(s2blc, [], [], [], hint.elim_cells.duplicate(), [num])
						hints.append(hint)




