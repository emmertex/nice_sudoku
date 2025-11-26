extends RefCounted
class_name SkyscraperStringKiteSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for digit in range(1, 10):
		var d = digit - 1
		var strong_links = []

		for r in range(9):
			var cols = []
			for c in range(9):
				if sudoku.grid[r][c] == 0 and generator._get_candidates(r, c).get_bit(d):
					cols.append(c)
			if cols.size() == 2:
				strong_links.append({"unit_type": "row", "unit_idx": r, "cells": [Vector2i(r, cols[0]), Vector2i(r, cols[1])]})

		for c in range(9):
			var rows = []
			for r in range(9):
				if sudoku.grid[r][c] == 0 and generator._get_candidates(r, c).get_bit(d):
					rows.append(r)
			if rows.size() == 2:
				strong_links.append({"unit_type": "col", "unit_idx": c, "cells": [Vector2i(rows[0], c), Vector2i(rows[1], c)]})

		for b in range(9):
			var cells_in_box = []
			for i in range(9):
				var p = Cardinals.box_to_rc(b, i)
				if sudoku.grid[p.x][p.y] == 0 and generator._get_candidates(p.x, p.y).get_bit(d):
					cells_in_box.append(p)
			if cells_in_box.size() == 2:
				strong_links.append({"unit_type": "box", "unit_idx": b, "cells": cells_in_box})

		for i in range(strong_links.size()):
			for j in range(i + 1, strong_links.size()):
				var link1 = strong_links[i]
				var link2 = strong_links[j]
				var cell1a = link1.cells[0]
				var cell1b = link1.cells[1]
				var cell2a = link2.cells[0]
				var cell2b = link2.cells[1]

				var shared_base = false
				var peak1: Vector2i
				var peak2: Vector2i
				var base1: Vector2i
				var base2: Vector2i

				if generator._are_peers(cell1a, cell2a):
					shared_base = true
					peak1 = cell1b
					peak2 = cell2b
					base1 = cell1a
					base2 = cell2a
				elif generator._are_peers(cell1a, cell2b):
					shared_base = true
					peak1 = cell1b
					peak2 = cell2a
					base1 = cell1a
					base2 = cell2b
				elif generator._are_peers(cell1b, cell2a):
					shared_base = true
					peak1 = cell1a
					peak2 = cell2b
					base1 = cell1b
					base2 = cell2a
				elif generator._are_peers(cell1b, cell2b):
					shared_base = true
					peak1 = cell1a
					peak2 = cell2a
					base1 = cell1b
					base2 = cell2b

				if not shared_base:
					continue

				if base1 == base2:
					continue

				var technique = Hint.HintTechnique.SKYSCRAPER if link1.unit_type == link2.unit_type else Hint.HintTechnique.STRING_KITE
				var elim_cells = []
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0:
							continue
						var cell = Vector2i(r, c)
						if cell in [peak1, peak2, base1, base2]:
							continue
						if not generator._get_candidates(r, c).get_bit(d):
							continue
						if generator._are_peers(cell, peak1) and generator._are_peers(cell, peak2):
							elim_cells.append(cell)

				if elim_cells.size() > 0:
					var found = false
					for existing in hints:
						if existing.technique == technique and existing.numbers.has(digit) and existing.cells.has(peak1) and existing.cells.has(peak2):
							found = true
							break
					if found:
						continue

					var hint = Hint.new(technique, "")
					hint.cells.append(peak1)
					hint.cells.append(peak2)
					hint.cells.append(base1)
					hint.cells.append(base2)
					hint.numbers.append(digit)
					hint.elim_cells.append_array(elim_cells)
					hint.elim_numbers.append(digit)

					var tech_name = "Skyscraper" if technique == Hint.HintTechnique.SKYSCRAPER else "String Kite"
					var desc = "%s on digit %d: Strong links (%s = %s) and (%s = %s) share base %s.\n\n" % [
						tech_name, digit,
						generator._format_cell_list([peak1]), generator._format_cell_list([base1]),
						generator._format_cell_list([base2]), generator._format_cell_list([peak2]),
						generator._format_cell_list([base1, base2])
					]
					desc += "If %s is %d, then %s cannot be %d, forcing %s to be %d.\n" % [generator._format_cell_list([base1]), digit, generator._format_cell_list([base2]), digit, generator._format_cell_list([peak2]), digit]
					desc += "If %s is %d, then %s cannot be %d, forcing %s to be %d.\n\n" % [generator._format_cell_list([base2]), digit, generator._format_cell_list([base1]), digit, generator._format_cell_list([peak1]), digit]
					desc += "Either way, one peak must be %d, so eliminate %d from cells seeing both peaks: %s." % [digit, digit, generator._format_cell_list(elim_cells)]
					hint.description = desc

					var s1 = "%s on digit %d: (%s) and (%s)." % [tech_name, digit, generator._format_cell_list([peak1, base1]), generator._format_cell_list([base2, peak2])]
					hint.add_step(s1, [peak1, base1, base2, peak2])
					var s2 = "One peak must be %d, eliminate %d from cells seeing both peaks." % [digit, digit]
					hint.add_step(s2, [peak1, peak2], [], [], elim_cells.duplicate(), [digit])

					hints.append(hint)




