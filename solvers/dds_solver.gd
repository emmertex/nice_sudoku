extends RefCounted
class_name DdsSolver

func name() -> String:
	return "DDS Solver"

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for digit1 in range(1, 10):
		for digit2 in range(digit1 + 1, 10):
			var d1 = digit1 - 1
			var d2 = digit2 - 1
			var cells_with_both = []
			for r in range(9):
				for c in range(9):
					if sudoku.grid[r][c] != 0:
						continue
					var cand = generator._get_candidates(r, c)
					if cand.get_bit(d1) and cand.get_bit(d2):
						cells_with_both.append(Vector2i(r, c))

			if cells_with_both.size() < 2:
				continue

			for r in range(9):
				var row_cells = []
				for cell in cells_with_both:
					if cell.x == r:
						row_cells.append(cell)

				if row_cells.size() >= 2:
					var all_only_d1d2 = true
					for cell in row_cells:
						var cand = generator._get_candidates(cell.x, cell.y)
						var other_digits = cand.clone()
						other_digits.clear_bit(d1)
						other_digits.clear_bit(d2)
						if other_digits.cardinality() > 0:
							all_only_d1d2 = false
							break

					if all_only_d1d2:
						var elim_cells = []
						for cc in range(9):
							var cell = Vector2i(r, cc)
							if cell in row_cells:
								continue
							if sudoku.grid[r][cc] != 0:
								continue
							var cand = generator._get_candidates(r, cc)
							if cand.get_bit(d1) or cand.get_bit(d2):
								elim_cells.append(cell)

						if elim_cells.size() > 0:
							var hint = Hint.new(Hint.HintTechnique.DDS, "")
							hint.cells.append_array(row_cells)
							hint.numbers.append(digit1)
							hint.numbers.append(digit2)
							hint.elim_cells.append_array(elim_cells)
							if elim_cells.any(func(c): return generator._get_candidates(c.x, c.y).get_bit(d1)):
								hint.elim_numbers.append(digit1)
							if elim_cells.any(func(c): return generator._get_candidates(c.x, c.y).get_bit(d2)):
								hint.elim_numbers.append(digit2)

							var desc = "DDS (Double Digit Subset): Digits %d and %d appear together in row %d cells %s.\n\n" % [digit1, digit2, r + 1, generator._format_cell_list(row_cells)]
							desc += "These cells only contain %d and/or %d, so eliminate these digits from other cells in the row: %s." % [digit1, digit2, generator._format_cell_list(elim_cells)]
							hint.description = desc
							var s1 = "DDS: Digits %d and %d appear together in row %d." % [digit1, digit2, r + 1]
							hint.add_step(s1, row_cells.duplicate())
							var s2 = "Eliminate %d and/or %d from other cells in the row: %s." % [digit1, digit2, generator._format_cell_list(elim_cells)]
							hint.add_step(s2, [], [], [], elim_cells.duplicate(), hint.elim_numbers.duplicate())
							hints.append(hint)




