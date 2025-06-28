extends RefCounted
class_name SudokuHintGenerator
const Hint = preload("res://hint.gd")
var sudoku: Sudoku
var strong_links: Array

func _get_candidates(r: int, c: int) -> BitSet:
	var cands = sudoku.sbrc_grid.get_candidates_for_cell(r, c).clone()
	var bits_to_exclude = sudoku.exclude_bits[r][c]
	if bits_to_exclude > 0:
		cands.data &= ~bits_to_exclude
	return cands

func get_hints() -> Array[Hint]:
	var hints: Array[Hint] = []
	_build_strong_links()

	# Single Candidate
	for row in range(9):
		for col in range(9):
			if sudoku.grid[row][col] == 0:
				var possible_numbers = []
				var candidates = _get_candidates(row, col)
				for i in range(9):
					if candidates.get_bit(i):
						possible_numbers.append(i + 1)
				if possible_numbers.size() == 1:
					var num = possible_numbers[0]
					var desc = "This cell can only be %d. All other numbers from 1 to 9 are present in this cell's row, column, or box." % num
					var hint = Hint.new(Hint.HintTechnique.SINGLE_CANDIDATE, desc)
					hint.cells.append(Vector2i(row, col))
					hint.numbers.append(num)
					
					# Populate highlighting data
					var peers = _get_peer_cells(row, col)
					hint.secondary_cells.append_array(peers)
					for peer in peers:
						if sudoku.grid[peer.x][peer.y] != 0:
							hint.cause_cells.append(peer)
					
					hints.append(hint)

	# --- Hidden Singles ---
	var hidden_singles = find_hidden_singles()
	for single in hidden_singles:
		var r = single.row
		var c = single.col
		var num = single.digit
		var type = single.type
		
		var unit_idx = r if type == "row" else (c if type == "column" else (int(r / 3) * 3 + int(c / 3)))
		var desc = "In this %s, the number %d can only be placed in this single cell. All other empty cells in the %s are blocked by existing %d's in their corresponding rows, columns, or boxes." % [type, num, type, num]
		var hint = Hint.new(Hint.HintTechnique.HIDDEN_SINGLE, desc)
		hint.cells.append(Vector2i(r, c))
		hint.numbers.append(num)
		
		# Populate highlighting data
		if type == "row":
			for c_other in range(9):
				if c_other != c:
					hint.secondary_cells.append(Vector2i(r, c_other))
		elif type == "column":
			for r_other in range(9):
				if r_other != r:
					hint.secondary_cells.append(Vector2i(r_other, c))
		else: # box
			var box_idx = Cardinals.Bxy[r * 9 + c]
			for i in range(9):
				var pos = Cardinals.box_to_rc(box_idx, i)
				if pos.x != r or pos.y != c:
					hint.secondary_cells.append(pos)
		
		# Find the cause cells
		for cell_to_check in hint.secondary_cells:
			if sudoku.grid[cell_to_check.x][cell_to_check.y] == 0:
				var peers = _get_peer_cells(cell_to_check.x, cell_to_check.y)
				for peer in peers:
					if sudoku.grid[peer.x][peer.y] == num:
						if not peer in hint.cause_cells:
							hint.cause_cells.append(peer)
		
		hints.append(hint)

	# --- Naked Groups (Pairs, Triples, Quads) ---
	# Rows
	for r in range(9):
		_find_naked_groups_in_unit(hints, r, "row", 2) # Naked Pairs
		_find_naked_groups_in_unit(hints, r, "row", 3) # Naked Triples
		_find_naked_groups_in_unit(hints, r, "row", 4) # Naked Quads

	# Columns
	for c in range(9):
		_find_naked_groups_in_unit(hints, c, "col", 2)
		_find_naked_groups_in_unit(hints, c, "col", 3)
		_find_naked_groups_in_unit(hints, c, "col", 4)

	# Boxes
	for b in range(9):
		_find_naked_groups_in_unit(hints, b, "box", 2)
		_find_naked_groups_in_unit(hints, b, "box", 3)
		_find_naked_groups_in_unit(hints, b, "box", 4)

	# --- X-Wing ---
	for digit in range(1, 10):
		# Row-based X-Wing
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if _get_candidates(r, c).get_bit(digit - 1):
					positions.set_bit(c)
			if positions.cardinality() == 2:
				row_candidates[r] = positions

		if row_candidates.size() >= 2:
			var rows = row_candidates.keys()
			for i in range(rows.size()):
				for j in range(i + 1, rows.size()):
					var r1 = rows[i]
					var r2 = rows[j]
					
					if row_candidates[r1].data == row_candidates[r2].data:
						# X-Wing found
						var cols = []
						var cands = row_candidates[r1]
						for c in range(9):
							if cands.get_bit(c):
								cols.append(c)
						
						var desc = "X-Wing: on digit %d in rows %d and %d, covering columns %d and %d." % [digit, r1+1, r2+1, cols[0]+1, cols[1]+1]
						var hint = Hint.new(Hint.HintTechnique.X_WING_ROW, desc)
						hint.cells.append_array([Vector2i(r1, cols[0]), Vector2i(r1, cols[1]), Vector2i(r2, cols[0]), Vector2i(r2, cols[1])])
						hint.numbers.append(digit)
						
						# Add elimination & highlighting info
						for c in cols:
							for r_check in range(9):
								if r_check != r1 and r_check != r2:
									var cell = Vector2i(r_check, c)
									hint.secondary_cells.append(cell)
									if _get_candidates(r_check, c).get_bit(digit-1):
										hint.elim_cells.append(cell)
						
						if not hint.elim_cells.is_empty():
							hint.elim_numbers.append(digit)
							desc = "Look at the rows %s and %s. The only places for a %d are in columns %d and %d.\n\n" % [r1+1, r2+1, digit, cols[0]+1, cols[1]+1]
							desc += "This forms an X-Wing. Since the %d in these rows must be in one of those two columns, we can eliminate %d as a candidate from all other cells in columns %d and %d.\n\n" % [digit, digit, cols[0]+1, cols[1]+1]
							desc += "Therefore, we can eliminate %d from: %s." % [digit, _format_cell_list(hint.elim_cells)]
							hint.description = desc
							hints.append(hint)
		# Column-based X-Wing
		var col_candidates = {}
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if _get_candidates(r, c).get_bit(digit - 1):
					positions.set_bit(r)
			if positions.cardinality() == 2:
				col_candidates[c] = positions
		
		if col_candidates.size() >= 2:
			var cols = col_candidates.keys()
			for i in range(cols.size()):
				for j in range(i + 1, cols.size()):
					var c1 = cols[i]
					var c2 = cols[j]
					
					if col_candidates[c1].data == col_candidates[c2].data:
						# X-Wing found
						var rows = []
						var cands = col_candidates[c1]
						for r in range(9):
							if cands.get_bit(r):
								rows.append(r)
						
						var desc = "X-Wing: on digit %d in columns %d and %d, covering rows %d and %d." % [digit, c1+1, c2+1, rows[0]+1, rows[1]+1]
						var hint = Hint.new(Hint.HintTechnique.X_WING_COL, desc)
						hint.cells.append_array([Vector2i(rows[0], c1), Vector2i(rows[1], c1), Vector2i(rows[0], c2), Vector2i(rows[1], c2)])
						hint.numbers.append(digit)

						# Add elimination & highlighting info
						for r in rows:
							for c_check in range(9):
								if c_check != c1 and c_check != c2:
									var cell = Vector2i(r, c_check)
									hint.secondary_cells.append(cell)
									if _get_candidates(r, c_check).get_bit(digit-1):
										hint.elim_cells.append(cell)

						if not hint.elim_cells.is_empty():
							hint.elim_numbers.append(digit)
							desc = "Look at the columns %s and %s. The only places for a %d are in rows %d and %d.\n\n" % [c1+1, c2+1, digit, rows[0]+1, rows[1]+1]
							desc += "This forms an X-Wing. Since the %d in these columns must be in one of those two rows, we can eliminate %d as a candidate from all other cells in rows %d and %d.\n\n" % [digit, digit, rows[0]+1, rows[1]+1]
							desc += "Therefore, we can eliminate %d from: %s." % [digit, _format_cell_list(hint.elim_cells)]
							hint.description = desc
							hints.append(hint)

	# --- Swordfish ---
	for digit in range(1, 10):
		# Row-based Swordfish
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if _get_candidates(r, c).get_bit(digit - 1):
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
							# Swordfish found
							var cols = []
							for c in range(9):
								if union_cols.get_bit(c):
									cols.append(c)
							var desc = "Swordfish: on digit %d" % digit
							var hint = Hint.new(Hint.HintTechnique.SWORDFISH_ROW, desc)
							for r in [r1, r2, r3]:
								for c in cols:
									if _get_candidates(r, c).get_bit(digit - 1):
										hint.cells.append(Vector2i(r,c))
							hint.numbers.append(digit)
							
							# Add elimination & highlighting info
							for c in cols:
								for r_check in range(9):
									if not r_check in [r1, r2, r3]:
										var cell = Vector2i(r_check, c)
										hint.secondary_cells.append(cell)
										if _get_candidates(r_check, c).get_bit(digit - 1):
											hint.elim_cells.append(cell)
						
							if not hint.elim_cells.is_empty():
								hint.elim_numbers.append(digit)
								desc = "A Swordfish pattern exists for the number %d.\n\n" % digit
								desc += "In rows %s, %s, and %s, the only places for a %d are in columns %s, %s, and %s. " % [r1+1, r2+1, r3+1, digit, cols[0]+1, cols[1]+1, cols[2]+1]
								desc += "This means that in these three columns, the %d must be in one of the three rows.\n\n" % digit
								desc += "Therefore, we can eliminate %d from other cells in these columns: %s" % [digit, _format_cell_list(hint.elim_cells)]
								hint.description = desc
								hints.append(hint)

		# Column-based Swordfish
		var col_candidates = {}
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if _get_candidates(r, c).get_bit(digit - 1):
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
							var desc = "Swordfish: on digit %d" % digit
							var hint = Hint.new(Hint.HintTechnique.SWORDFISH_COL, desc)
							for c in [c1, c2, c3]:
								for r in rows:
									if _get_candidates(r, c).get_bit(digit - 1):
										hint.cells.append(Vector2i(r,c))
							hint.numbers.append(digit)
							
							# Add elimination & highlighting info
							for r in rows:
								for c_check in range(9):
									if not c_check in [c1, c2, c3]:
										var cell = Vector2i(r, c_check)
										hint.secondary_cells.append(cell)
										if _get_candidates(r, c_check).get_bit(digit - 1):
											hint.elim_cells.append(cell)
						
							if not hint.elim_cells.is_empty():
								hint.elim_numbers.append(digit)
								desc = "A Swordfish pattern exists for the number %d.\n\n" % digit
								desc += "In columns %s, %s, and %s, the only places for a %d are in rows %s, %s, and %s. " % [c1+1, c2+1, c3+1, digit, rows[0]+1, rows[1]+1, rows[2]+1]
								desc += "This means that in these three rows, the %d must be in one of the three columns.\n\n" % digit
								desc += "Therefore, we can eliminate %d from other cells in these rows: %s" % [digit, _format_cell_list(hint.elim_cells)]
								hint.description = desc
								hints.append(hint)

	# --- Jellyfish ---
	for digit in range(1, 10):
		# Row-based Jellyfish
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if _get_candidates(r, c).get_bit(digit - 1):
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
								var desc = "Jellyfish: on digit %d" % digit
								var hint = Hint.new(Hint.HintTechnique.JELLYFISH_ROW, desc)
								for r in [r1, r2, r3, r4]:
									for c in cols:
										if _get_candidates(r, c).get_bit(digit - 1):
											hint.cells.append(Vector2i(r,c))
								hint.numbers.append(digit)
								
								# Add elimination & highlighting info
								for c in cols:
									for r_check in range(9):
										if not r_check in [r1, r2, r3, r4]:
											var cell = Vector2i(r_check, c)
											hint.secondary_cells.append(cell)
											if _get_candidates(r_check, c).get_bit(digit-1):
												hint.elim_cells.append(cell)
							
								if not hint.elim_cells.is_empty():
									hint.elim_numbers.append(digit)
									var r_str = ", ".join([str(r1+1), str(r2+1), str(r3+1), str(r4+1)])
									var c_str = ", ".join([str(cols[0]+1), str(cols[1]+1), str(cols[2]+1), str(cols[3]+1)])
									desc = "A Jellyfish pattern exists for the number %d.\n\n" % digit
									desc += "In rows %s, the only places for a %d are in columns %s. " % [r_str, digit, c_str]
									desc += "This means that in these four columns, the %d must be in one of the four rows.\n\n" % digit
									desc += "Therefore, we can eliminate %d from other cells in these columns: %s" % [digit, _format_cell_list(hint.elim_cells)]
									hint.description = desc
									hints.append(hint)

		# Column-based Jellyfish
		var col_candidates = {}
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if _get_candidates(r, c).get_bit(digit - 1):
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
								var desc = "Jellyfish: on digit %d" % digit
								var hint = Hint.new(Hint.HintTechnique.JELLYFISH_COL, desc)
								for c in [c1, c2, c3, c4]:
									for r in rows:
										if _get_candidates(r, c).get_bit(digit - 1):
											hint.cells.append(Vector2i(r,c))
								hint.numbers.append(digit)
								
								# Add elimination & highlighting info
								for r in rows:
									for c_check in range(9):
										if not c_check in [c1, c2, c3, c4]:
											var cell = Vector2i(r, c_check)
											hint.secondary_cells.append(cell)
											if _get_candidates(r, c_check).get_bit(digit-1):
												hint.elim_cells.append(cell)
							
								if not hint.elim_cells.is_empty():
									hint.elim_numbers.append(digit)
									var c_str = ", ".join([str(c1+1), str(c2+1), str(c3+1), str(c4+1)])
									var r_str = ", ".join([str(rows[0]+1), str(rows[1]+1), str(rows[2]+1), str(rows[3]+1)])
									desc = "A Jellyfish pattern exists for the number %d.\n\n" % digit
									desc += "In columns %s, the only places for a %d are in rows %s. " % [c_str, digit, r_str]
									desc += "This means that in these four rows, the %d must be in one of the four columns.\n\n" % digit
									desc += "Therefore, we can eliminate %d from other cells in these rows: %s" % [digit, _format_cell_list(hint.elim_cells)]
									hint.description = desc
									hints.append(hint)

	# --- Pointing Pairs / Triples ---
	for num in range(1, 10):
		for b in range(9): # Iterate through each box
			var box_cells_with_cand = []
			for i in range(9):
				var pos = Cardinals.box_to_rc(b, i)
				if sudoku.grid[pos.x][pos.y] == 0 and _get_candidates(pos.x, pos.y).get_bit(num - 1):
					box_cells_with_cand.append(pos)

			if box_cells_with_cand.size() > 0:
				# Check if all candidates for 'num' in this box fall on the same row
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
					
					# Find eliminations and secondary cells
					for c in range(9):
						var current_cell = Vector2i(first_row, c)
						if Cardinals.Bxy[first_row * 9 + c] != b:
							hint.secondary_cells.append(current_cell)
							if _get_candidates(first_row, c).get_bit(num - 1):
								hint.elim_cells.append(current_cell)

					if not hint.elim_cells.is_empty():
						hint.elim_numbers.append(num)
						var desc = "In this box, the only place for a %d is somewhere in row %d.\n\n" % [num, first_row + 1]
						desc += "This forms a Pointing group. Because one of these cells must be %d, we can be sure that no other cell in row %d can be %d.\n\n" % [num, first_row + 1]
						desc += "Therefore, we can eliminate %d as a candidate from cells: %s." % [num, _format_cell_list(hint.elim_cells)]
						hint.description = desc
						hints.append(hint)

				# Check if all candidates for 'num' in this box fall on the same column
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

					# Find eliminations and secondary cells
					for r in range(9):
						var current_cell = Vector2i(r, first_col)
						if Cardinals.Bxy[r * 9 + first_col] != b:
							hint.secondary_cells.append(current_cell)
							if _get_candidates(r, first_col).get_bit(num - 1):
								hint.elim_cells.append(current_cell)
					
					if not hint.elim_cells.is_empty():
						hint.elim_numbers.append(num)
						var desc = "In this box, the only place for a %d is somewhere in column %d.\n\n" % [num, first_col + 1]
						desc += "This forms a Pointing group. Because one of these cells must be %d, we can be sure that no other cell in column %d can be %d.\n\n" % [num, first_col + 1]
						desc += "Therefore, we can eliminate %d as a candidate from cells: %s." % [num, _format_cell_list(hint.elim_cells)]
						hint.description = desc
						hints.append(hint)

	# --- Box-Line Reduction (Claiming) ---
	for num in range(1, 10):
		# Row-based reduction
		for r in range(9):
			var row_cells_with_cand = []
			for c in range(9):
				if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(num - 1):
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

					# Find eliminations and secondary cells
					for i in range(9):
						var box_cell = Cardinals.box_to_rc(first_box, i)
						if box_cell.x != r: # If not in the claiming row
							hint.secondary_cells.append(box_cell)
							if sudoku.grid[box_cell.x][box_cell.y] == 0 and _get_candidates(box_cell.x, box_cell.y).get_bit(num-1):
								hint.elim_cells.append(box_cell)

					if not hint.elim_cells.is_empty():
						hint.elim_numbers.append(num)
						var desc = "In row %d, the only cells that can be a %d are all in the same box.\n\n" % [r + 1, num]
						desc += "This is a Box/Line Reduction. Since %d must be in this row, and all possibilities for it are in this box, the %d for this box must be in this row.\n\n" % [num, num]
						desc += "Therefore, we can eliminate %d as a candidate from other cells in this box: %s." % [num, _format_cell_list(hint.elim_cells)]
						hint.description = desc
						hints.append(hint)

		# Column-based reduction
		for c in range(9):
			var col_cells_with_cand = []
			for r in range(9):
				if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(num - 1):
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
					
					# Find eliminations and secondary cells
					for i in range(9):
						var box_cell = Cardinals.box_to_rc(first_box, i)
						if box_cell.y != c: # If not in the claiming col
							hint.secondary_cells.append(box_cell)
							if sudoku.grid[box_cell.x][box_cell.y] == 0 and _get_candidates(box_cell.x, box_cell.y).get_bit(num-1):
								hint.elim_cells.append(box_cell)

					if not hint.elim_cells.is_empty():
						hint.elim_numbers.append(num)
						var desc = "In column %d, the only cells that can be a %d are all in the same box.\n\n" % [c + 1, num]
						desc += "This is a Box/Line Reduction. Since %d must be in this column, and all possibilities for it are in this box, the %d for this box must be in this column.\n\n" % [num, num]
						desc += "Therefore, we can eliminate %d as a candidate from other cells in this box: %s." % [num, _format_cell_list(hint.elim_cells)]
						hint.description = desc
						hints.append(hint)

	return hints

func _find_naked_groups_in_unit(hints: Array[Hint], unit_index: int, unit_type: String, group_size: int):
	var unit_cells: Array[Vector2i] = []
	if unit_type == "row":
		for c in range(9): unit_cells.append(Vector2i(unit_index, c))
	elif unit_type == "col":
		for r in range(9): unit_cells.append(Vector2i(r, unit_index))
	else: # box
		for i in range(9): unit_cells.append(Cardinals.box_to_rc(unit_index, i))

	var potential_cells = []
	for cell in unit_cells:
		var cand_count = _get_candidates(cell.x, cell.y).cardinality()
		if cand_count > 1 && cand_count <= group_size:
			potential_cells.append(cell)
	
	if potential_cells.size() < group_size:
		return

	for group_indices in combinations(range(potential_cells.size()), group_size):
		var group_cells = []
		for i in group_indices:
			group_cells.append(potential_cells[i])
		
		var union_cands = BitSet.new(9)
		for cell in group_cells:
			union_cands = union_cands.union(_get_candidates(cell.x, cell.y))
			
		if union_cands.cardinality() == group_size:
			var elim_found = false
			var hint = Hint.new(Hint.HintTechnique.NAKED_TRIPLE_ROW, "") # Technique will be updated
			hint.cells.append_array(group_cells)
			for i in range(9):
				if union_cands.get_bit(i):
					hint.numbers.append(i + 1)

			for cell_to_check in unit_cells:
				if not cell_to_check in group_cells:
					var cands_to_check = _get_candidates(cell_to_check.x, cell_to_check.y)
					var intersection = cands_to_check.intersection(union_cands)
					
					if intersection.cardinality() > 0:
						elim_found = true
						hint.elim_cells.append(cell_to_check)
						for i in range(9):
							if intersection.get_bit(i):
								if not (i + 1) in hint.elim_numbers:
									hint.elim_numbers.append(i + 1)
			
			if elim_found:
				var technique_name = "NAKED_"
				if group_size == 2: technique_name += "PAIR_"
				elif group_size == 3: technique_name += "TRIPLE_"
				elif group_size == 4: technique_name += "QUAD_"
				technique_name += unit_type.to_upper()
				
				var technique_enum = Hint.HintTechnique.get(technique_name)
				if technique_enum == null:
					push_error("Invalid technique name generated: " + technique_name)
					continue
				
				hint.technique = technique_enum
				hint.description = _generate_naked_group_description(hint, unit_type, unit_index)
				hints.append(hint)

func _format_cell_list(cells: Array[Vector2i]) -> String:
	return ", ".join(cells.map(func(c): return "(%d, %d)" % [c.x + 1, c.y + 1]))

func _generate_naked_group_description(hint: Hint, unit_type: String, unit_index: int) -> String:
	var group_type = ""
	if hint.cells.size() == 2: group_type = "Pair"
	elif hint.cells.size() == 3: group_type = "Triple"
	elif hint.cells.size() == 4: group_type = "Quad"

	var numbers_str = ", ".join(hint.numbers.map(func(n): return str(n)))
	var cells_str = _format_cell_list(hint.cells)
	var elim_numbers_str = ", ".join(hint.elim_numbers.map(func(n): return str(n)))
	var elim_cells_str = _format_cell_list(hint.elim_cells)
	
	var unit_str = "%s %d" % [unit_type.capitalize(), unit_index + 1]

	var desc = "In %s, these %d cells (%s) are the only ones that can contain the numbers %s.\n\n" % [unit_str, hint.cells.size(), cells_str, numbers_str]
	desc += "This is a Naked %s. Because these %d numbers must be placed in these %d cells, they cannot appear anywhere else in the same %s.\n\n" % [group_type, hint.cells.size(), hint.cells.size(), unit_type.capitalize()]
	desc += "Therefore, we can eliminate the number(s) %s from the following cell(s): %s." % [elim_numbers_str, elim_cells_str]
	
	return desc

# Godot has no built-in `combinations`, so here's one.
func combinations(arr, k):
	var result = []
	_combinations_recursive(arr, k, 0, [], result)
	return result

func _combinations_recursive(arr, k, start, current, result):
	if current.size() == k:
		result.append(current.duplicate())
		return

	if start >= arr.size():
		return

	# Include current element
	current.append(arr[start])
	_combinations_recursive(arr, k, start + 1, current, result)
	current.pop_back()

	# Exclude current element
	if arr.size() - (start + 1) >= k - current.size():
		_combinations_recursive(arr, k, start + 1, current, result)

func _build_strong_links():
	strong_links = []
	
	# Bivalue cells
	for r in range(9):
		for c in range(9):
			var candidates = _get_candidates(r, c)
			if candidates.cardinality() == 2:
				var d1 = candidates.next_set_bit(0)
				var d2 = candidates.next_set_bit(d1 + 1)
				strong_links.append(StrongLink.new_bivalue(r, c, d1, d2))
	
	# Bilocal units
	for d in range(9):
		# Rows
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if _get_candidates(r, c).get_bit(d):
					positions.set_bit(c)
			if positions.cardinality() == 2:
				var c1 = positions.next_set_bit(0)
				var c2 = positions.next_set_bit(c1 + 1)
				strong_links.append(StrongLink.new_bilocal(d, r, c1, r, c2))

		# Columns
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if _get_candidates(r, c).get_bit(d):
					positions.set_bit(r)
			if positions.cardinality() == 2:
				var r1 = positions.next_set_bit(0)
				var r2 = positions.next_set_bit(r1 + 1)
				strong_links.append(StrongLink.new_bilocal(d, r1, c, r2, c))

		# Boxes
		for b in range(9):
			var positions = BitSet.new(9)
			for i in range(9):
				var cell = Cardinals.box_to_rc(b, i)
				if _get_candidates(cell.x, cell.y).get_bit(d):
					positions.set_bit(i)
			if positions.cardinality() == 2:
				var i1 = positions.next_set_bit(0)
				var i2 = positions.next_set_bit(i1 + 1)
				var cell1 = Cardinals.box_to_rc(b, i1)
				var cell2 = Cardinals.box_to_rc(b, i2)
				strong_links.append(StrongLink.new_bilocal(d, cell1.x, cell1.y, cell2.x, cell2.y))

func _get_peer_cells(row: int, col: int) -> Array[Vector2i]:
	var peers: Array[Vector2i] = []
	var seen_coords = {}
	
	# Add row peers
	for c in range(9):
		if c != col:
			peers.append(Vector2i(row, c))
			seen_coords[Vector2i(row, c)] = true
			
	# Add col peers
	for r in range(9):
		if r != row:
			var coord = Vector2i(r, col)
			if not seen_coords.has(coord):
				peers.append(coord)
				seen_coords[coord] = true

	# Add box peers
	var box_idx = Cardinals.Bxy[row * 9 + col]
	for i in range(9):
		var pos = Cardinals.box_to_rc(box_idx, i)
		if pos.x != row or pos.y != col:
			if not seen_coords.has(pos):
				peers.append(pos)
				seen_coords[pos] = true
				
	return peers
func find_hidden_singles() -> Array:
	var singles = []

	# Rows
	for r in range(9):
		for d in range(9):  # digit-1
			var count = 0
			var found_c = -1
			for c in range(9):
				if sudoku.grid[r][c] == 0:
					var cell_candidates = _get_candidates(r, c)
					if cell_candidates.get_bit(d):
						count += 1
						found_c = c
			if count == 1:
				singles.append({"row": r, "col": found_c, "digit": d + 1, "type": "row"})

	# Columns
	for c in range(9):
		for d in range(9):  # digit-1
			var count = 0
			var found_r = -1
			for r in range(9):
				if sudoku.grid[r][c] == 0:
					var cell_candidates = _get_candidates(r, c)
					if cell_candidates.get_bit(d):
						count += 1
						found_r = r
			if count == 1:
				singles.append({"row": found_r, "col": c, "digit": d + 1, "type": "column"})

	# Boxes
	for b in range(9):
		for d in range(9):  # digit-1
			var count = 0
			var found_i = -1
			for i in range(9):
				var cell = Cardinals.box_to_rc(b, i)
				if sudoku.grid[cell.x][cell.y] == 0:
					var cell_candidates = _get_candidates(cell.x, cell.y)
					if cell_candidates.get_bit(d):
						count += 1
						found_i = i
			if count == 1:
				var cell = Cardinals.box_to_rc(b, found_i)
				singles.append({"row": cell.x, "col": cell.y, "digit": d + 1, "type": "box"})
	
	return singles
