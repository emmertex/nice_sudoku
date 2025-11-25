extends RefCounted
class_name HiddenSingleSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for single in _collect_hidden_singles(generator):
		var r = single.row
		var c = single.col
		var num = single.digit
		var type = single.type
		
		var desc = "In this %s, the number %d can only be placed in this single cell. All other empty cells in the %s are blocked by existing %d's in their corresponding rows, columns, or boxes." % [type, num, type, num]
		var hint = Hint.new(Hint.HintTechnique.HIDDEN_SINGLE, desc)
		hint.cells.append(Vector2i(r, c))
		hint.numbers.append(num)

		if type == "row":
			for c_other in range(9):
				if c_other != c:
					hint.secondary_cells.append(Vector2i(r, c_other))
		elif type == "column":
			for r_other in range(9):
				if r_other != r:
					hint.secondary_cells.append(Vector2i(r_other, c))
		else:
			var box_idx = Cardinals.Bxy[r * 9 + c]
			for i in range(9):
				var pos = Cardinals.box_to_rc(box_idx, i)
				if pos.x != r or pos.y != c:
					hint.secondary_cells.append(pos)

		for cell_to_check in hint.secondary_cells:
			if sudoku.grid[cell_to_check.x][cell_to_check.y] == 0:
				var peers = generator._get_peer_cells(cell_to_check.x, cell_to_check.y)
				for peer in peers:
					if sudoku.grid[peer.x][peer.y] == num and not peer in hint.cause_cells:
						hint.cause_cells.append(peer)

		var all_digit_cells: Array[Vector2i] = []
		for rr in range(9):
			for cc in range(9):
				if sudoku.grid[rr][cc] == num:
					all_digit_cells.append(Vector2i(rr, cc))

		var s1 = "Scan digit %d across the grid. Each existing %d blocks its entire row, column, and box." % [num, num]
		hint.add_step(s1, [], [], all_digit_cells)

		var unit_label = type
		var s2 = "In this %s, every other cell is blocked by existing %d's in intersecting rows, columns, or boxes; so only this cell works." % [unit_label, num]
		hint.add_step(s2, [Vector2i(r, c)], hint.secondary_cells, hint.cause_cells)

		hints.append(hint)

func _collect_hidden_singles(generator: SudokuHintGenerator) -> Array:
	var sudoku = generator.sudoku
	var singles = []

	for r in range(9):
		for d in range(9):
			var count = 0
			var found_c = -1
			for c in range(9):
				if sudoku.grid[r][c] == 0 and generator._get_candidates(r, c).get_bit(d):
					count += 1
					found_c = c
			if count == 1:
				singles.append({"row": r, "col": found_c, "digit": d + 1, "type": "row"})

	for c in range(9):
		for d in range(9):
			var count = 0
			var found_r = -1
			for r in range(9):
				if sudoku.grid[r][c] == 0 and generator._get_candidates(r, c).get_bit(d):
					count += 1
					found_r = r
			if count == 1:
				singles.append({"row": found_r, "col": c, "digit": d + 1, "type": "column"})

	for b in range(9):
		for d in range(9):
			var count = 0
			var found_i = -1
			for i in range(9):
				var cell = Cardinals.box_to_rc(b, i)
				if sudoku.grid[cell.x][cell.y] == 0 and generator._get_candidates(cell.x, cell.y).get_bit(d):
					count += 1
					found_i = i
			if count == 1:
				var cell = Cardinals.box_to_rc(b, found_i)
				singles.append({"row": cell.x, "col": cell.y, "digit": d + 1, "type": "box"})

	return singles

