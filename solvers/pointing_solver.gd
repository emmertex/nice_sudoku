extends RefCounted
class_name PointingSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for num in range(1, 10):
		for b in range(9):
			var box_cells_with_cand = []
			for i in range(9):
				var pos = Cardinals.box_to_rc(b, i)
				if sudoku.grid[pos.x][pos.y] == 0 and generator._get_candidates(pos.x, pos.y).get_bit(num - 1):
					box_cells_with_cand.append(pos)

			if box_cells_with_cand.size() == 0:
				continue

			var all_in_same_row = true
			var first_row = box_cells_with_cand[0].x
			for i in range(1, box_cells_with_cand.size()):
				if box_cells_with_cand[i].x != first_row:
					all_in_same_row = false
					break

			if all_in_same_row:
				var hint = Hint.new(Hint.HintTechnique.POINTING_PAIR, "")
				hint.numbers.append(num)
				hint.cells.append_array(box_cells_with_cand)
				for c in range(9):
					var current_cell = Vector2i(first_row, c)
					if Cardinals.Bxy[first_row * 9 + c] != b:
						hint.secondary_cells.append(current_cell)
						if generator._get_candidates(first_row, c).get_bit(num - 1):
							hint.elim_cells.append(current_cell)

				if not hint.elim_cells.is_empty():
					hint.elim_numbers.append(num)
					var desc = "In this box, the only place for a {num} is somewhere in row {row}.\n\n".format({"num": num, "row": first_row + 1})
					desc += "This forms a Pointing group. Because one of these cells must be {num}, we can be sure that no other cell in row {row} can be {num}.\n\n".format({"num": num, "row": first_row + 1})
					desc += "Therefore, we can eliminate {num} as a candidate from cells: {cells}.".format({"num": num, "cells": generator._format_cell_list(hint.elim_cells)})
					hint.description = desc
					var s1p = "In box %d, all %d candidates lie in row %d." % [b + 1, num, first_row + 1]
					hint.add_step(s1p, box_cells_with_cand.duplicate())
					var s2p = "Therefore, in row %d outside this box, %d cannot appear." % [first_row + 1, num]
					hint.add_step(s2p, [], [], [], hint.elim_cells.duplicate(), [num])
					hints.append(hint)

			var all_in_same_col = true
			var first_col = box_cells_with_cand[0].y
			for i in range(1, box_cells_with_cand.size()):
				if box_cells_with_cand[i].y != first_col:
					all_in_same_col = false
					break

			if all_in_same_col:
				var hint = Hint.new(Hint.HintTechnique.POINTING_PAIR, "")
				hint.numbers.append(num)
				hint.cells.append_array(box_cells_with_cand)
				for r in range(9):
					var current_cell = Vector2i(r, first_col)
					if Cardinals.Bxy[r * 9 + first_col] != b:
						hint.secondary_cells.append(current_cell)
						if generator._get_candidates(r, first_col).get_bit(num - 1):
							hint.elim_cells.append(current_cell)

				if not hint.elim_cells.is_empty():
					hint.elim_numbers.append(num)
					var desc = "In this box, the only place for a {num} is somewhere in column {col}.\n\n".format({"num": num, "col": first_col + 1})
					desc += "This forms a Pointing group. Because one of these cells must be {num}, we can be sure that no other cell in column {col} can be {num}.\n\n".format({"num": num, "col": first_col + 1})
					desc += "Therefore, we can eliminate {num} as a candidate from cells: {cells}.".format({"num": num, "cells": generator._format_cell_list(hint.elim_cells)})
					hint.description = desc
					var s1pc = "In box %d, all %d candidates lie in column %d." % [b + 1, num, first_col + 1]
					hint.add_step(s1pc, box_cells_with_cand.duplicate())
					var s2pc = "Therefore, in column %d outside this box, %d cannot appear." % [first_col + 1, num]
					hint.add_step(s2pc, [], [], [], hint.elim_cells.duplicate(), [num])
					hints.append(hint)

