extends RefCounted
class_name EmptyRectangleSolver

var sudoku: Sudoku
var generator_ref: SudokuHintGenerator

func name() -> String:
	return "Empty Rectangle Solver"

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	generator_ref = generator
	sudoku = generator.sudoku
	_find_empty_rectangles(hints)

func _find_empty_rectangles(hints: Array[Hint]) -> void:
	# Simple Empty Rectangle detector (limited):
	for digit in range(1, 10):
		for b in range(9):
			var in_box: Array[Vector2i] = []
			for i in range(9):
				var p = Cardinals.box_to_rc(b, i)
				if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x, p.y).get_bit(digit - 1):
					in_box.append(p)
			if in_box.size() < 2:
				continue
			var row_set := {}
			var col_set := {}
			for v in in_box:
				row_set[v.x] = true
				col_set[v.y] = true
			if row_set.size() != 2 or col_set.size() != 2:
				continue
			var rows: Array = row_set.keys()
			var cols: Array = col_set.keys()
			for r in rows:
				for c in cols:
					if Cardinals.Bxy[r * 9 + c] == b:
						continue
					if sudoku.grid[r][c] != 0:
						continue
					if not _get_candidates(r, c).get_bit(digit - 1):
						continue
					# Conjugate outside the box along row or column
					var row_pos: Array[int] = []
					for cc in range(9):
						if Cardinals.Bxy[r * 9 + cc] == b:
							continue
						if sudoku.grid[r][cc] == 0 and _get_candidates(r, cc).get_bit(digit - 1):
							row_pos.append(cc)
					var col_pos: Array[int] = []
					for rr in range(9):
						if Cardinals.Bxy[rr * 9 + c] == b:
							continue
						if sudoku.grid[rr][c] == 0 and _get_candidates(rr, c).get_bit(digit - 1):
							col_pos.append(rr)
					if row_pos.size() == 1 or col_pos.size() == 1:
						var hint = Hint.new(Hint.HintTechnique.AIC_CHAIN, "")
						hint.title = "Empty Rectangle"
						hint.numbers.append(digit)
						hint.cells.append_array(in_box)
						hint.elim_cells.append(Vector2i(r, c))
						hint.elim_numbers.append(digit)
						var s1 = "Empty Rectangle on %d in box %d aligned to rows %d/%d and cols %d/%d." % [digit, b + 1, rows[0] + 1, rows[1] + 1, cols[0] + 1, cols[1] + 1]
						var s2 = "Therefore eliminate %d from %s." % [digit, _format_cell_list([Vector2i(r, c)])]
						hint.description = s1 + "\n\n" + s2
						hint.add_step(s1, in_box.duplicate())
						hint.add_step(s2, [], [], [], [Vector2i(r, c)], [digit])
						hints.append(hint)

func _get_candidates(r: int, c: int) -> BitSet:
	return generator_ref._get_candidates(r, c)

func _are_peers(c1: Vector2i, c2: Vector2i) -> bool:
	return generator_ref._are_peers(c1, c2)

func _format_cell_list(cells: Array[Vector2i]) -> String:
	return generator_ref._format_cell_list(cells)
