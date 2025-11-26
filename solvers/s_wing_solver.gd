extends RefCounted
class_name SWingSolver

func name() -> String:
	return "S-Wing Solver"

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for digit_a in range(1, 10):
		var d_a = digit_a - 1
		var strong_links_a = []
		for r in range(9):
			var cols = []
			for c in range(9):
				if sudoku.grid[r][c] == 0 and generator._get_candidates(r, c).get_bit(d_a):
					cols.append(c)
			if cols.size() == 2:
				strong_links_a.append({"cells": [Vector2i(r, cols[0]), Vector2i(r, cols[1])]})

		for c in range(9):
			var rows = []
			for r in range(9):
				if sudoku.grid[r][c] == 0 and generator._get_candidates(r, c).get_bit(d_a):
					rows.append(r)
			if rows.size() == 2:
				strong_links_a.append({"cells": [Vector2i(rows[0], c), Vector2i(rows[1], c)]})

		for b in range(9):
			var cells_in_box = []
			for i in range(9):
				var p = Cardinals.box_to_rc(b, i)
				if sudoku.grid[p.x][p.y] == 0 and generator._get_candidates(p.x, p.y).get_bit(d_a):
					cells_in_box.append(p)
			if cells_in_box.size() == 2:
				strong_links_a.append({"cells": cells_in_box})

		for link_a in strong_links_a:
			var cell_a1 = link_a.cells[0]
			var cell_a2 = link_a.cells[1]
			for endpoint_a in [cell_a1, cell_a2]:
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0:
							continue
						var cell_bivalue = Vector2i(r, c)
						if cell_bivalue == endpoint_a:
							continue
						if not generator._are_peers(cell_bivalue, endpoint_a):
							continue
						var cand = generator._get_candidates(r, c)
						if cand.cardinality() != 2:
							continue
						var d1 = cand.next_set_bit(0)
						var d2 = cand.next_set_bit(d1 + 1)
						if d1 != d_a and d2 != d_a:
							continue
						var digit_b = d1 if d2 == d_a else d2

						var strong_links_b = []
						for rr in range(9):
							var cols_b = []
							for cc in range(9):
								if sudoku.grid[rr][cc] == 0 and generator._get_candidates(rr, cc).get_bit(digit_b):
									cols_b.append(cc)
							if cols_b.size() == 2:
								strong_links_b.append({"cells": [Vector2i(rr, cols_b[0]), Vector2i(rr, cols_b[1])]})

						for cc in range(9):
							var rows_b = []
							for rr in range(9):
								if sudoku.grid[rr][cc] == 0 and generator._get_candidates(rr, cc).get_bit(digit_b):
									rows_b.append(rr)
							if rows_b.size() == 2:
								strong_links_b.append({"cells": [Vector2i(rows_b[0], cc), Vector2i(rows_b[1], cc)]})

						for bb in range(9):
							var cells_b = []
							for ii in range(9):
								var pp = Cardinals.box_to_rc(bb, ii)
								if sudoku.grid[pp.x][pp.y] == 0 and generator._get_candidates(pp.x, pp.y).get_bit(digit_b):
									cells_b.append(pp)
							if cells_b.size() == 2:
								strong_links_b.append({"cells": cells_b})

						for link_b in strong_links_b:
							var cell_b1 = link_b.cells[0]
							var cell_b2 = link_b.cells[1]
							if cell_b1 == cell_a1 or cell_b1 == cell_a2 or cell_b2 == cell_a1 or cell_b2 == cell_a2:
								continue
							if cell_b1 == cell_bivalue or cell_b2 == cell_bivalue:
								continue
							var sees_b1 = generator._are_peers(cell_bivalue, cell_b1)
							var sees_b2 = generator._are_peers(cell_bivalue, cell_b2)
							if not (sees_b1 or sees_b2):
								continue
							var endpoint_b = cell_b1 if sees_b1 else cell_b2
							var other_b = cell_b2 if sees_b1 else cell_b1
							var other_a = cell_a2 if endpoint_a == cell_a1 else cell_a1

							var elim_cells = []
							for rr in range(9):
								for cc in range(9):
									if sudoku.grid[rr][cc] != 0:
										continue
									var cell = Vector2i(rr, cc)
									if cell in [endpoint_a, endpoint_b, cell_bivalue, other_a, other_b]:
										continue
									if not generator._get_candidates(rr, cc).get_bit(digit_b):
										continue
									if generator._are_peers(cell, other_a) and generator._are_peers(cell, other_b):
										elim_cells.append(cell)

							if elim_cells.size() > 0:
								var exists = false
								for existing in hints:
									if existing.technique == Hint.HintTechnique.S_WING and existing.cells.has(endpoint_a) and existing.cells.has(cell_bivalue) and existing.cells.has(endpoint_b):
										exists = true
										break
								if exists:
									continue
								var hint = Hint.new(Hint.HintTechnique.S_WING, "")
								hint.cells.append(endpoint_a)
								hint.cells.append(cell_bivalue)
								hint.cells.append(endpoint_b)
								hint.numbers.append(digit_a)
								hint.numbers.append(digit_b + 1)
								hint.elim_cells.append_array(elim_cells)
								hint.elim_numbers.append(digit_b + 1)

								var desc = "S-Wing: (%d)(%s = %s) - (%d=%d)(%s) - (%d)(%s = %s).\n\n" % [
									digit_a, generator._format_cell_list([endpoint_a]), generator._format_cell_list([other_a]),
									digit_a, digit_b + 1, generator._format_cell_list([cell_bivalue]),
									digit_b + 1, generator._format_cell_list([endpoint_b]), generator._format_cell_list([other_b])
								]
								desc += "If %s is %d, then %s must be %d, forcing %s to be %d.\n" % [endpoint_a, digit_a, cell_bivalue, digit_b + 1, endpoint_b, digit_b + 1]
								desc += "If %s is not %d, then %s must be %d, forcing %s to be %d.\n\n" % [endpoint_a, digit_a, other_a, digit_a, cell_bivalue, digit_a]
								desc += "Either way, %s or %s must be %d, so eliminate %d from cells seeing both: %s." % [generator._format_cell_list([endpoint_b]), generator._format_cell_list([other_b]), digit_b + 1, digit_b + 1, generator._format_cell_list(elim_cells)]
								hint.description = desc

								var s1 = "S-Wing: Strong link on %d (%s), bivalue %s {%d/%d}, strong link on %d (%s)." % [
									digit_a, generator._format_cell_list([endpoint_a, other_a]),
									generator._format_cell_list([cell_bivalue]), digit_a, digit_b + 1,
									digit_b + 1, generator._format_cell_list([endpoint_b, other_b])
								]
								hint.add_step(s1, [endpoint_a, cell_bivalue, endpoint_b])
								var s2 = "Eliminate %d from cells seeing both endpoints: %s." % [digit_b + 1, generator._format_cell_list(elim_cells)]
								hint.add_step(s2, [other_a, other_b], [], [], elim_cells.duplicate(), [digit_b + 1])
								hints.append(hint)




