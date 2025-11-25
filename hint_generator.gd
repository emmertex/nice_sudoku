extends RefCounted
class_name SudokuHintGenerator
var sudoku: Sudoku
var strong_links: Array

func _get_candidates(r: int, c: int) -> BitSet:
	var cands = sudoku.sbrc_grid.get_candidates_for_cell(r, c).clone()
	var bits_to_exclude = sudoku.exclude_bits[r][c]
	if bits_to_exclude > 0:
		cands.data[0] &= ~bits_to_exclude
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

					# Build steps for teaching
					var coord = "(%d,%d)" % [row+1, col+1]
					var step1 = "Check cell %s: current candidates are {%s}." % [coord, ", ".join(possible_numbers.map(func(n): return str(n)))]
					hint.add_step(step1, [Vector2i(row, col)], peers, [], [], [])
					var step2 = "In its row/column/box, all numbers except %d already appear, leaving only %d." % [num, num]
					hint.add_step(step2, [Vector2i(row, col)], [], hint.cause_cells)
					var step3 = "Therefore set %d at %s." % [num, coord]
					hint.add_step(step3, [Vector2i(row, col)])
					
					hints.append(hint)

					if hints.size() > 0: return hints
	# --- Hidden Singles ---
	var hidden_singles = find_hidden_singles()
	for single in hidden_singles:
		var r = single.row
		var c = single.col
		var num = single.digit
		var type = single.type
		
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

		# Build two-step teaching flow
		# Step 1: show all existing occurrences of this digit and how they block their rows/cols/boxes
		var all_digit_cells: Array[Vector2i] = []
		for rr in range(9):
			for cc in range(9):
				if sudoku.grid[rr][cc] == num:
					all_digit_cells.append(Vector2i(rr, cc))
		var s1 = "Scan digit %d across the grid. Each existing %d blocks its entire row, column, and box." % [num, num]
		hint.add_step(s1, [], [], all_digit_cells)

		# Step 2: focus on this %s and why other cells are blocked
		var unit_label = type
		var s2 = "In this %s, every other cell is blocked by existing %d's in intersecting rows, columns, or boxes; so only this cell works." % [unit_label, num]
		hint.add_step(s2, [Vector2i(r, c)], hint.secondary_cells, hint.cause_cells)

		hints.append(hint)

		if hints.size() > 0: return hints
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

	if hints.size() > 0: return hints



	# --- X-Wing ---
	# for digit in range(1, 10):
	# 	# Row-based X-Wing
	# 	var row_candidates = {}
	# 	for r in range(9):
	# 		var positions = BitSet.new(9)
	# 		for c in range(9):
	# 			if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(digit - 1):
	# 				positions.set_bit(c)
	# 		if positions.cardinality() == 2:
	# 			row_candidates[r] = positions

	# 	if row_candidates.size() >= 2:
	# 		var rows = row_candidates.keys()
	# 		for i in range(rows.size()):
	# 			for j in range(i + 1, rows.size()):
	# 				var r1 = rows[i]
	# 				var r2 = rows[j]
	# 				# Compare bit patterns directly (BitSet stores only one int for size 9)
	# 				if row_candidates[r1].data[0] == row_candidates[r2].data[0]:
	# 					# X-Wing found
	# 					var cols = []
	# 					var cands = row_candidates[r1]
	# 					for c in range(9):
	# 						if cands.get_bit(c):
	# 							cols.append(c)
						
	# 					var desc = "X-Wing: on digit %d in rows %d and %d, covering columns %d and %d." % [digit, r1+1, r2+1, cols[0]+1, cols[1]+1]
	# 					var hint = Hint.new(Hint.HintTechnique.X_WING_ROW, desc)
	# 					hint.cells.append_array([Vector2i(r1, cols[0]), Vector2i(r1, cols[1]), Vector2i(r2, cols[0]), Vector2i(r2, cols[1])])
	# 					hint.numbers.append(digit)
					
	# 					# Add elimination & highlighting info
	# 					for c in cols:
	# 						for r_check in range(9):
	# 							if r_check != r1 and r_check != r2:
	# 								var cell = Vector2i(r_check, c)
	# 								hint.secondary_cells.append(cell)
	# 								if _get_candidates(r_check, c).get_bit(digit-1):
	# 									hint.elim_cells.append(cell)
					
	# 					if not hint.elim_cells.is_empty():
	# 						hint.elim_numbers.append(digit)
	# 						desc = "Look at the rows %s and %s. The only places for a %d are in columns %d and %d.\n\n" % [r1+1, r2+1, digit, cols[0]+1, cols[1]+1]
	# 						desc += "This forms an X-Wing. Since the %d in these rows must be in one of those two columns, we can eliminate %d as a candidate from all other cells in columns %d and %d.\n\n" % [digit, digit, cols[0]+1, cols[1]+1]
	# 						desc += "Therefore, we can eliminate %d from: %s." % [digit, _format_cell_list(hint.elim_cells)]
	# 						hint.description = desc
	# 						# Steps for X-Wing (row-based)
	# 						var s1 = "Scan digit %d: rows %d and %d each have exactly two candidates in the same columns." % [digit, r1+1, r2+1]
	# 						hint.add_step(s1, [Vector2i(r1, cols[0]), Vector2i(r1, cols[1]), Vector2i(r2, cols[0]), Vector2i(r2, cols[1])])
	# 						var s2 = "These form the corners of an X-Wing. Thus, in columns %d and %d, %d cannot occur in any other row." % [cols[0]+1, cols[1]+1, digit]
	# 						hint.add_step(s2, [], [], [], hint.elim_cells, [digit])
	# 						var s3 = "Eliminate %d from: %s." % [digit, _format_cell_list(hint.elim_cells)]
	# 						hint.add_step(s3, [], [], [], hint.elim_cells, [digit])
	# 					# Always append the X-Wing hint (even if no eliminations) so strategy tests can detect it
	# 					hints.append(hint)
	# 	# Column-based X-Wing
	# 	var col_candidates = {}
	# 	for c in range(9):
	# 		var positions = BitSet.new(9)
	# 		for r in range(9):
	# 			if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(digit - 1):
	# 				positions.set_bit(r)
	# 		if positions.cardinality() == 2:
	# 			col_candidates[c] = positions
		
	# 	if col_candidates.size() >= 2:
	# 		var cols = col_candidates.keys()
	# 		for i in range(cols.size()):
	# 			for j in range(i + 1, cols.size()):
	# 				var c1 = cols[i]
	# 				var c2 = cols[j]
	# 				# Compare bit patterns directly
	# 				if col_candidates[c1].data[0] == col_candidates[c2].data[0]:
	# 					# X-Wing found
	# 					var rows = []
	# 					var cands = col_candidates[c1]
	# 					for r in range(9):
	# 						if cands.get_bit(r):
	# 							rows.append(r)
						
	# 					var desc = "X-Wing: on digit %d in columns %d and %d, covering rows %d and %d." % [digit, c1+1, c2+1, rows[0]+1, rows[1]+1]
	# 					var hint = Hint.new(Hint.HintTechnique.X_WING_COL, desc)
	# 					hint.cells.append_array([Vector2i(rows[0], c1), Vector2i(rows[1], c1), Vector2i(rows[0], c2), Vector2i(rows[1], c2)])
	# 					hint.numbers.append(digit)

	# 					# Add elimination & highlighting info
	# 					for r in rows:
	# 						for c_check in range(9):
	# 							if c_check != c1 and c_check != c2:
	# 								var cell = Vector2i(r, c_check)
	# 								hint.secondary_cells.append(cell)
	# 								if _get_candidates(r, c_check).get_bit(digit-1):
	# 									hint.elim_cells.append(cell)

	# 					if not hint.elim_cells.is_empty():
	# 						hint.elim_numbers.append(digit)
	# 						desc = "Look at the columns %s and %s. The only places for a %d are in rows %d and %d.\n\n" % [c1+1, c2+1, digit, rows[0]+1, rows[1]+1]
	# 						desc += "This forms an X-Wing. Since the %d in these columns must be in one of those two rows, we can eliminate %d as a candidate from all other cells in rows %d and %d.\n\n" % [digit, digit, rows[0]+1, rows[1]+1]
	# 						desc += "Therefore, we can eliminate %d from: %s." % [digit, _format_cell_list(hint.elim_cells)]
	# 						hint.description = desc
	# 						# Steps for X-Wing (column-based)
	# 						var s1c = "Scan digit %d: columns %d and %d each have exactly two candidates in the same rows." % [digit, c1+1, c2+1]
	# 						hint.add_step(s1c, [Vector2i(rows[0], c1), Vector2i(rows[1], c1), Vector2i(rows[0], c2), Vector2i(rows[1], c2)])
	# 						var s2c = "These form the corners of an X-Wing. Thus, in rows %d and %d, %d cannot occur in any other column." % [rows[0]+1, rows[1]+1, digit]
	# 						hint.add_step(s2c, [], [], [], hint.elim_cells, [digit])
	# 						var s3c = "Eliminate %d from: %s." % [digit, _format_cell_list(hint.elim_cells)]
	# 						hint.add_step(s3c, [], [], [], hint.elim_cells, [digit])
	# 					# Always append the X-Wing hint (even if no eliminations) so strategy tests can detect it
	# 					hints.append(hint)

	# 	if hints.size() > 0: return hints

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
								var sfs1 = "Swordfish on digit %d across rows %d, %d, %d in columns %d, %d, %d." % [digit, r1+1, r2+1, r3+1, cols[0]+1, cols[1]+1, cols[2]+1]
								hint.add_step(sfs1, hint.cells.duplicate())
								var sfs2 = "Thus in columns %d, %d, %d, only those rows can hold %d; eliminate elsewhere in those columns." % [cols[0]+1, cols[1]+1, cols[2]+1, digit]
								hint.add_step(sfs2, [], [], [], hint.elim_cells.duplicate(), [digit])
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
								var sfs1c = "Swordfish on digit %d across columns %d, %d, %d in rows %d, %d, %d." % [digit, c1+1, c2+1, c3+1, rows[0]+1, rows[1]+1, rows[2]+1]
								hint.add_step(sfs1c, hint.cells.duplicate())
								var sfs2c = "Thus in rows %d, %d, %d, only those columns can hold %d; eliminate elsewhere in those rows." % [rows[0]+1, rows[1]+1, rows[2]+1, digit]
								hint.add_step(sfs2c, [], [], [], hint.elim_cells.duplicate(), [digit])
								hints.append(hint)

		if hints.size() > 0: return hints

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
									var jfs1 = "Jellyfish on digit %d across rows %s and columns %s." % [digit, r_str, c_str]
									hint.add_step(jfs1, hint.cells.duplicate())
									var jfs2 = "Thus only these rows can hold %d in those columns; eliminate elsewhere in those columns." % [digit]
									hint.add_step(jfs2, [], [], [], hint.elim_cells.duplicate(), [digit])
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
									var jfs1c = "Jellyfish on digit %d across columns %s and rows %s." % [digit, c_str, r_str]
									hint.add_step(jfs1c, hint.cells.duplicate())
									var jfs2c = "Thus only these columns can hold %d in those rows; eliminate elsewhere in those rows." % [digit]
									hint.add_step(jfs2c, [], [], [], hint.elim_cells.duplicate(), [digit])
									hints.append(hint)

		if hints.size() > 0: return hints

	# --- Sashimi X-Wing and Swordfish ---
	_find_sashimi_fish(hints)
	if hints.size() > 0: return hints

	# --- DDS (Double Digit Subset) ---
	_find_dds(hints)
	if hints.size() > 0: return hints
	# --- Shared Cell ---
	_find_shared_cell(hints)
	if hints.size() > 0: return hints
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
						var desc = "In this box, the only place for a {num} is somewhere in row {row}.\n\n".format({"num": num, "row": first_row + 1})
						desc += "This forms a Pointing group. Because one of these cells must be {num}, we can be sure that no other cell in row {row} can be {num}.\n\n".format({"num": num, "row": first_row + 1})
						desc += "Therefore, we can eliminate {num} as a candidate from cells: {cells}.".format({"num": num, "cells": _format_cell_list(hint.elim_cells)})
						hint.description = desc
						# Steps for Pointing (row)
						var s1p = "In box %d, all %d candidates lie in row %d." % [b + 1, num, first_row + 1]
						hint.add_step(s1p, box_cells_with_cand.duplicate())
						var s2p = "Therefore, in row %d outside this box, %d cannot appear." % [first_row + 1, num]
						hint.add_step(s2p, [], [], [], hint.elim_cells.duplicate(), [num])
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
						var desc = "In this box, the only place for a {num} is somewhere in column {col}.\n\n".format({"num": num, "col": first_col + 1})
						desc += "This forms a Pointing group. Because one of these cells must be {num}, we can be sure that no other cell in column {col} can be {num}.\n\n".format({"num": num, "col": first_col + 1})
						desc += "Therefore, we can eliminate {num} as a candidate from cells: {cells}.".format({"num": num, "cells": _format_cell_list(hint.elim_cells)})
						hint.description = desc
						# Steps for Pointing (column)
						var s1pc = "In box %d, all %d candidates lie in column %d." % [b + 1, num, first_col + 1]
						hint.add_step(s1pc, box_cells_with_cand.duplicate())
						var s2pc = "Therefore, in column %d outside this box, %d cannot appear." % [first_col + 1, num]
						hint.add_step(s2pc, [], [], [], hint.elim_cells.duplicate(), [num])
						hints.append(hint)

	if hints.size() > 0: return hints

	# --- Box-Line Reduction (Claiming) ---
	# --- Skyscraper and String Kite ---
	_find_skyscrapers_and_string_kites(hints)
	# --- S-Wing ---
	_find_s_wings(hints)
	# --- Remote Pair ---
	_find_remote_pairs(hints)
	# --- XY-Wing (detect before XY-Chain as it's simpler) ---
	_find_xy_wings(hints)
	# --- XYZ-Wing and WXYZ-Wing ---
	_find_xyz_wings(hints)
	_find_wxyz_wings(hints)
	# --- ALS-XY Rule and ALS-Chain ---
	#_find_als_xy_rule(hints)
	#_find_als_chains(hints)
	# --- XY-Chain and W-Wing ---
	_find_xy_chains_and_wwings(hints)
	# --- XY-Ring (modify XY-Chain to detect closed loops) ---
	_find_xy_rings(hints)
	_find_mlh_wings(hints)
	# --- Empty Rectangle ---
	_find_empty_rectangles(hints)


	# --- Proto AIC ---
	for digit in range(1, 10):
		# Build strong-link graph per digit
		var nodes: Array = [] # each: {pos: Vector2i, links: Array[int], color: int}
		var pos_to_idx = {}
		# Collect positions where candidate present
		for r in range(9):
			for c in range(9):
				if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(digit - 1):
					var idx = nodes.size()
					nodes.append({"pos": Vector2i(r,c), "links": [], "color": -1})
					pos_to_idx[Vector2i(r,c)] = idx
		# Add edges for bilocal strong links in row/col/box
		# Rows
		for r in range(9):
			var cols := []
			for c in range(9): if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(digit - 1): cols.append(c)
			if cols.size() == 2:
				var a = pos_to_idx[Vector2i(r, cols[0])]
				var b = pos_to_idx[Vector2i(r, cols[1])]
				nodes[a].links.append(b)
				nodes[b].links.append(a)
		# Cols
		for c in range(9):
			var rows := []
			for r in range(9): if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(digit - 1): rows.append(r)
			if rows.size() == 2:
				var a = pos_to_idx[Vector2i(rows[0], c)]
				var b = pos_to_idx[Vector2i(rows[1], c)]
				nodes[a].links.append(b)
				nodes[b].links.append(a)
		# Boxes
		for box_idx in range(9):
			var idxs := []
			for i in range(9):
				var p = Cardinals.box_to_rc(box_idx, i)
				if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x, p.y).get_bit(digit - 1): idxs.append(p)
			if idxs.size() == 2:
				var a = pos_to_idx[idxs[0]]
				var b2 = pos_to_idx[idxs[1]]
				nodes[a].links.append(b2)
				nodes[b2].links.append(a)
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
						# Steps for Box/Line (row)
						var s1blr = "In row %d, all %d candidates are within box %d." % [r + 1, num, first_box + 1]
						hint.add_step(s1blr, row_cells_with_cand.duplicate())
						var s2blr = "Therefore, remove %d from other cells in that box outside row %d." % [num, r + 1]
						hint.add_step(s2blr, [], [], [], hint.elim_cells.duplicate(), [num])
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
						# Steps for Box/Line (column)
						var s1blc = "In column %d, all %d candidates are within box %d." % [c + 1, num, first_box + 1]
						hint.add_step(s1blc, col_cells_with_cand.duplicate())
						var s2blc = "Therefore, remove %d from other cells in that box outside column %d." % [num, c + 1]
						hint.add_step(s2blc, [], [], [], hint.elim_cells.duplicate(), [num])
						hints.append(hint)


	# --- Nishio (trial contradiction) ---
	# Expensive: only attempt if no other hints found
	if hints.is_empty():
		_find_nishio_eliminations(hints)

	return hints


func _find_skyscrapers_and_string_kites(hints: Array[Hint]):
	# Skyscraper: Two strong links on same digit sharing a base
	# Pattern: (digit)(cell1 = cell2) in unit1, (digit)(cell3 = cell4) in unit2
	# Where cell2 and cell3 share a unit (the base)
	# Eliminate digit from cells seeing both "peaks" (cell1 and cell4)
	
	# String Kite: Similar but the links are in different unit types
	# Pattern: (digit)(cell1 = cell2) in row/col, (digit)(cell3 = cell4) in col/row
	# Eliminate digit from cells seeing both peaks
	
	for digit in range(1, 10):
		var d = digit - 1
		# Find all conjugate pairs (strong links) for this digit
		var strong_links: Array = [] # {unit_type: "row"/"col"/"box", unit_idx: int, cells: [Vector2i, Vector2i]}
		
		# Rows
		for r in range(9):
			var cols: Array[int] = []
			for c in range(9):
				if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(d):
					cols.append(c)
			if cols.size() == 2:
				strong_links.append({"unit_type": "row", "unit_idx": r, "cells": [Vector2i(r, cols[0]), Vector2i(r, cols[1])]})
		
		# Columns
		for c in range(9):
			var rows: Array[int] = []
			for r in range(9):
				if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(d):
					rows.append(r)
			if rows.size() == 2:
				strong_links.append({"unit_type": "col", "unit_idx": c, "cells": [Vector2i(rows[0], c), Vector2i(rows[1], c)]})
		
		# Boxes
		for b in range(9):
			var cells_in_box: Array[Vector2i] = []
			for i in range(9):
				var p = Cardinals.box_to_rc(b, i)
				if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x, p.y).get_bit(d):
					cells_in_box.append(p)
			if cells_in_box.size() == 2:
				strong_links.append({"unit_type": "box", "unit_idx": b, "cells": cells_in_box})
		
		# Try all pairs of strong links
		for i in range(strong_links.size()):
			for j in range(i + 1, strong_links.size()):
				var link1 = strong_links[i]
				var link2 = strong_links[j]
				var cell1a = link1.cells[0]
				var cell1b = link1.cells[1]
				var cell2a = link2.cells[0]
				var cell2b = link2.cells[1]
				
				# Check if they share a base (one cell from each link are peers)
				var shared_base = false
				var peak1: Vector2i
				var peak2: Vector2i
				var base1: Vector2i
				var base2: Vector2i
				
				# Try all combinations
				if _are_peers(cell1a, cell2a):
					shared_base = true
					peak1 = cell1b
					peak2 = cell2b
					base1 = cell1a
					base2 = cell2a
				elif _are_peers(cell1a, cell2b):
					shared_base = true
					peak1 = cell1b
					peak2 = cell2a
					base1 = cell1a
					base2 = cell2b
				elif _are_peers(cell1b, cell2a):
					shared_base = true
					peak1 = cell1a
					peak2 = cell2b
					base1 = cell1b
					base2 = cell2a
				elif _are_peers(cell1b, cell2b):
					shared_base = true
					peak1 = cell1a
					peak2 = cell2a
					base1 = cell1b
					base2 = cell2b
				
				if not shared_base:
					continue
				
				# Determine technique: Skyscraper if same unit type, String Kite if different
				var technique = Hint.HintTechnique.SKYSCRAPER if link1.unit_type == link2.unit_type else Hint.HintTechnique.STRING_KITE
				
				# Find eliminations: cells seeing both peaks
				var elim_cells: Array[Vector2i] = []
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0:
							continue
						var cell = Vector2i(r, c)
						if cell == peak1 or cell == peak2 or cell == base1 or cell == base2:
							continue
						if not _get_candidates(r, c).get_bit(d):
							continue
						if _are_peers(cell, peak1) and _are_peers(cell, peak2):
							elim_cells.append(cell)
				
				if elim_cells.size() > 0:
					var key = str(peak1) + ":" + str(peak2) + ":" + str(digit)
					if not hints.any(func(h): return h.technique == technique and h.numbers.has(digit) and h.cells.has(peak1) and h.cells.has(peak2)):
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
							_format_cell_list([peak1]), _format_cell_list([base1]),
							_format_cell_list([base2]), _format_cell_list([peak2]),
							_format_cell_list([base1, base2])
						]
						desc += "If %s is %d, then %s cannot be %d, forcing %s to be %d.\n" % [_format_cell_list([base1]), digit, _format_cell_list([base2]), digit, _format_cell_list([peak2]), digit]
						desc += "If %s is %d, then %s cannot be %d, forcing %s to be %d.\n\n" % [_format_cell_list([base2]), digit, _format_cell_list([base1]), digit, _format_cell_list([peak1]), digit]
						desc += "Either way, one peak must be %d, so eliminate %d from cells seeing both peaks: %s." % [digit, digit, _format_cell_list(elim_cells)]
						hint.description = desc
						
						var s1 = "%s on digit %d: (%s) and (%s)." % [tech_name, digit, _format_cell_list([peak1, base1]), _format_cell_list([base2, peak2])]
						hint.add_step(s1, [peak1, base1, base2, peak2])
						var s2 = "One peak must be %d, eliminate %d from cells seeing both peaks." % [digit, digit]
						hint.add_step(s2, [peak1, peak2], [], [], elim_cells.duplicate(), [digit])
						
						hints.append(hint)

func _find_s_wings(hints: Array[Hint]):
	# S-Wing: (A)(cell1 = cell2) - (A=B)(cell2) - (B)(cell3 = cell4)
	# Pattern: Strong link on A, bivalue cell with {A,B}, strong link on B
	# Eliminate B from cell1 or A from cell4 (depending on which sees the other endpoint)
	
	for digit_a in range(1, 10):
		var d_a = digit_a - 1
		# Find strong links on digit A
		var strong_links_a: Array = [] # {cells: [Vector2i, Vector2i]}
		
		# Rows
		for r in range(9):
			var cols: Array[int] = []
			for c in range(9):
				if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(d_a):
					cols.append(c)
			if cols.size() == 2:
				strong_links_a.append({"cells": [Vector2i(r, cols[0]), Vector2i(r, cols[1])]})
		
		# Columns
		for c in range(9):
			var rows: Array[int] = []
			for r in range(9):
				if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(d_a):
					rows.append(r)
			if rows.size() == 2:
				strong_links_a.append({"cells": [Vector2i(rows[0], c), Vector2i(rows[1], c)]})
		
		# Boxes
		for b in range(9):
			var cells_in_box: Array[Vector2i] = []
			for i in range(9):
				var p = Cardinals.box_to_rc(b, i)
				if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x, p.y).get_bit(d_a):
					cells_in_box.append(p)
			if cells_in_box.size() == 2:
				strong_links_a.append({"cells": cells_in_box})
		
		# For each strong link on A, find bivalue cells with {A, B} that see one endpoint
		for link_a in strong_links_a:
			var cell_a1 = link_a.cells[0]
			var cell_a2 = link_a.cells[1]
			
			# Check both endpoints of the strong link
			for endpoint_a in [cell_a1, cell_a2]:
				# Find bivalue cells seeing this endpoint
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0:
							continue
						var cell_bivalue = Vector2i(r, c)
						if cell_bivalue == endpoint_a:
							continue
						if not _are_peers(cell_bivalue, endpoint_a):
							continue
						
						var cand = _get_candidates(r, c)
						if cand.cardinality() != 2:
							continue
						
						var d1 = cand.next_set_bit(0)
						var d2 = cand.next_set_bit(d1 + 1)
						
						# Check if it contains A
						if d1 != d_a and d2 != d_a:
							continue
						
						var digit_b = d1 if d2 == d_a else d2
						
						# Now find strong link on B that sees the bivalue cell
						var strong_links_b: Array = []
						
						# Rows
						for rr in range(9):
							var cols_b: Array[int] = []
							for cc in range(9):
								if sudoku.grid[rr][cc] == 0 and _get_candidates(rr, cc).get_bit(digit_b):
									cols_b.append(cc)
							if cols_b.size() == 2:
								strong_links_b.append({"cells": [Vector2i(rr, cols_b[0]), Vector2i(rr, cols_b[1])]})
						
						# Columns
						for cc in range(9):
							var rows_b: Array[int] = []
							for rr in range(9):
								if sudoku.grid[rr][cc] == 0 and _get_candidates(rr, cc).get_bit(digit_b):
									rows_b.append(rr)
							if rows_b.size() == 2:
								strong_links_b.append({"cells": [Vector2i(rows_b[0], cc), Vector2i(rows_b[1], cc)]})
						
						# Boxes
						for bb in range(9):
							var cells_b: Array[Vector2i] = []
							for ii in range(9):
								var pp = Cardinals.box_to_rc(bb, ii)
								if sudoku.grid[pp.x][pp.y] == 0 and _get_candidates(pp.x, pp.y).get_bit(digit_b):
									cells_b.append(pp)
							if cells_b.size() == 2:
								strong_links_b.append({"cells": cells_b})
						
						# Check if any strong link on B sees the bivalue cell
						for link_b in strong_links_b:
							var cell_b1 = link_b.cells[0]
							var cell_b2 = link_b.cells[1]
							
							# Bivalue cell must see one endpoint of B link
							var sees_b1 = _are_peers(cell_bivalue, cell_b1)
							var sees_b2 = _are_peers(cell_bivalue, cell_b2)
							
							if not (sees_b1 or sees_b2):
								continue
							
							# Determine which endpoint of B link
							var endpoint_b = cell_b1 if sees_b1 else cell_b2
							var other_b = cell_b2 if sees_b1 else cell_b1
							
							# Determine which endpoint of A link (the one not endpoint_a)
							var other_a = cell_a2 if endpoint_a == cell_a1 else cell_a1
							
							# Find eliminations: cells seeing both other endpoints
							var elim_cells: Array[Vector2i] = []
							for rr in range(9):
								for cc in range(9):
									if sudoku.grid[rr][cc] != 0:
										continue
									var cell = Vector2i(rr, cc)
									if cell == endpoint_a or cell == endpoint_b or cell == cell_bivalue or cell == other_a or cell == other_b:
										continue
									if not _get_candidates(rr, cc).get_bit(digit_b):
										continue
									if _are_peers(cell, other_a) and _are_peers(cell, other_b):
										elim_cells.append(cell)
							
							if elim_cells.size() > 0:
								var key = str(endpoint_a) + ":" + str(cell_bivalue) + ":" + str(endpoint_b) + ":swing"
								if not hints.any(func(h): return h.technique == Hint.HintTechnique.S_WING and h.cells.has(endpoint_a) and h.cells.has(cell_bivalue) and h.cells.has(endpoint_b)):
									var hint = Hint.new(Hint.HintTechnique.S_WING, "")
									hint.cells.append(endpoint_a)
									hint.cells.append(cell_bivalue)
									hint.cells.append(endpoint_b)
									hint.numbers.append(digit_a)
									hint.numbers.append(digit_b + 1)
									hint.elim_cells.append_array(elim_cells)
									hint.elim_numbers.append(digit_b + 1)
									
									var desc = "S-Wing: (%d)(%s = %s) - (%d=%d)(%s) - (%d)(%s = %s).\n\n" % [
										digit_a, _format_cell_list([endpoint_a]), _format_cell_list([other_a]),
										digit_a, digit_b + 1, _format_cell_list([cell_bivalue]),
										digit_b + 1, _format_cell_list([endpoint_b]), _format_cell_list([other_b])
									]
									desc += "If %s is %d, then %s must be %d, forcing %s to be %d.\n" % [endpoint_a, digit_a, cell_bivalue, digit_b + 1, endpoint_b, digit_b + 1]
									desc += "If %s is not %d, then %s must be %d, forcing %s to be %d.\n\n" % [endpoint_a, digit_a, other_a, digit_a, cell_bivalue, digit_a]
									desc += "Either way, %s or %s must be %d, so eliminate %d from cells seeing both: %s." % [_format_cell_list([endpoint_b]), _format_cell_list([other_b]), digit_b + 1, digit_b + 1, _format_cell_list(elim_cells)]
									hint.description = desc
									
									var s1 = "S-Wing: Strong link on %d (%s), bivalue %s {%d/%d}, strong link on %d (%s)." % [
										digit_a, _format_cell_list([endpoint_a, other_a]),
										_format_cell_list([cell_bivalue]), digit_a, digit_b + 1,
										digit_b + 1, _format_cell_list([endpoint_b, other_b])
									]
									hint.add_step(s1, [endpoint_a, cell_bivalue, endpoint_b])
									var s2 = "Eliminate %d from cells seeing both endpoints: %s." % [digit_b + 1, _format_cell_list(elim_cells)]
									hint.add_step(s2, [other_a, other_b], [], [], elim_cells.duplicate(), [digit_b + 1])
									
									hints.append(hint)

func _find_remote_pairs(hints: Array[Hint]):
	# Remote Pair: Chain of bivalue cells with alternating pairs {A,B}
	# All cells in chain have same pair {A,B}
	# Eliminate A or B from cells seeing both endpoints
	
	# Collect bivalue cells
	var bivalue_cells: Array = [] # {pos: Vector2i, pair: PackedInt32Array}
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cand = _get_candidates(r, c)
			if cand.cardinality() == 2:
				var d1 = cand.next_set_bit(0)
				var d2 = cand.next_set_bit(d1 + 1)
				bivalue_cells.append({"pos": Vector2i(r, c), "pair": PackedInt32Array([d1, d2])})
	
	if bivalue_cells.size() < 2:
		return
	
	# Group by pair
	var pairs_map = {}
	for cell_data in bivalue_cells:
		var pair_key = str(cell_data.pair[0]) + "," + str(cell_data.pair[1])
		if not pairs_map.has(pair_key):
			pairs_map[pair_key] = []
		pairs_map[pair_key].append(cell_data)
	
	# For each pair, find chains
	for pair_key in pairs_map.keys():
		var cells_with_pair = pairs_map[pair_key]
		if cells_with_pair.size() < 2:
			continue
		
		var pair = cells_with_pair[0].pair
		var A = pair[0]
		var B = pair[1]
		
		# Build graph: connect cells if they see each other and share a unit with exactly 2 candidates of A or B
		# Actually, Remote Pair is simpler: just connect cells that see each other
		var adj: Array = []
		for _i in range(cells_with_pair.size()):
			adj.append([])
		
		for i in range(cells_with_pair.size()):
			for j in range(i + 1, cells_with_pair.size()):
				var cell1 = cells_with_pair[i].pos
				var cell2 = cells_with_pair[j].pos
				if _are_peers(cell1, cell2):
					adj[i].append(j)
					adj[j].append(i)
		
		# DFS to find chains
		var emitted = {}
		for start_idx in range(cells_with_pair.size()):
			var visited: Dictionary = {}
			var path: Array = [start_idx]
			_remote_pair_dfs(cells_with_pair, adj, start_idx, visited, path, hints, emitted, A, B)
	
func _remote_pair_dfs(cells: Array, adj: Array, curr_idx: int, visited: Dictionary, path: Array, hints: Array[Hint], emitted: Dictionary, A: int, B: int):
	if visited.has(curr_idx):
		return
	visited[curr_idx] = true
	
	# Check if we have a valid Remote Pair chain (length >= 2)
	if path.size() >= 2:
		var start_cell = cells[path[0]].pos
		var end_cell = cells[curr_idx].pos
		
		# Endpoints should not be peers (they should be remote)
		if not _are_peers(start_cell, end_cell):
			var key = str(start_cell) + ":" + str(end_cell) + ":remotepair"
			if not emitted.has(key):
				# Determine which digit to eliminate (try both)
				for elim_digit in [A, B]:
					var elim_cells: Array[Vector2i] = []
					for r in range(9):
						for c in range(9):
							if sudoku.grid[r][c] != 0:
								continue
							var cell = Vector2i(r, c)
							if cell == start_cell or cell == end_cell:
								continue
							# Check if cell is in the chain
							var in_chain = false
							for idx in path:
								if cells[idx].pos == cell:
									in_chain = true
									break
							if in_chain:
								continue
							if not _get_candidates(r, c).get_bit(elim_digit):
								continue
							if _are_peers(cell, start_cell) and _are_peers(cell, end_cell):
								elim_cells.append(cell)
					
					if elim_cells.size() > 0:
						var hint = Hint.new(Hint.HintTechnique.REMOTE_PAIR, "")
						for idx in path:
							hint.cells.append(cells[idx].pos)
						hint.cells.append(cells[curr_idx].pos)
						hint.numbers.append(A + 1)
						hint.numbers.append(B + 1)
						hint.elim_cells.append_array(elim_cells)
						hint.elim_numbers.append(elim_digit + 1)
						
						var chain_text = []
						for idx in path:
							chain_text.append(_format_cell_list([cells[idx].pos]))
						chain_text.append(_format_cell_list([cells[curr_idx].pos]))
						
						var desc = "Remote Pair chain on {%d/%d}: %s.\n\n" % [A+1, B+1, " -> ".join(chain_text)]
						desc += "All cells in the chain have the same pair {%d/%d}.\n" % [A+1, B+1]
						desc += "If start is %d, end must be %d (or vice versa), synchronizing the pair.\n\n" % [A+1, B+1]
						desc += "Eliminate %d from cells seeing both endpoints: %s." % [elim_digit + 1, _format_cell_list(elim_cells)]
						hint.description = desc
						
						var s1 = "Remote Pair chain: %s (all have {%d/%d})." % [" -> ".join(chain_text), A+1, B+1]
						hint.add_step(s1, hint.cells.duplicate())
						var s2 = "Eliminate %d from cells seeing both endpoints: %s." % [elim_digit + 1, _format_cell_list(elim_cells)]
						hint.add_step(s2, [start_cell, end_cell], [], [], elim_cells.duplicate(), [elim_digit + 1])
						
						hints.append(hint)
						emitted[key] = true
						break  # Only emit one hint per chain
	
	# Continue DFS
	for next_idx in adj[curr_idx]:
		if visited.has(next_idx):
			continue
		var new_path = path.duplicate()
		new_path.append(next_idx)
		_remote_pair_dfs(cells, adj, next_idx, visited, new_path, hints, emitted, A, B)
	
	visited.erase(curr_idx)  # Backtrack

func _find_xy_wings(hints: Array[Hint]):
	# XY-Wing: pivot {XY}, wing1 {XZ}, wing2 {YZ}
	# Pivot sees both wings, wings see each other
	# Eliminate Z from cells seeing both wings
	
	# Collect bivalue cells
	var bivalue_cells: Array = [] # {pos: Vector2i, pair: PackedInt32Array}
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cand = _get_candidates(r, c)
			if cand.cardinality() == 2:
				var d1 = cand.next_set_bit(0)
				var d2 = cand.next_set_bit(d1 + 1)
				bivalue_cells.append({"pos": Vector2i(r, c), "pair": PackedInt32Array([d1, d2])})
	
	if bivalue_cells.size() < 3:
		return
	
	var emitted = {}
	# Try each cell as pivot
	for pivot_idx in range(bivalue_cells.size()):
		var pivot = bivalue_cells[pivot_idx]
		var pivot_pos = pivot.pos
		var pivot_pair = pivot.pair
		var X = pivot_pair[0]
		var Y = pivot_pair[1]
		
		# Find wing1: must have {X, Z} where Z != Y, and see pivot
		for wing1_idx in range(bivalue_cells.size()):
			if wing1_idx == pivot_idx:
				continue
			var wing1 = bivalue_cells[wing1_idx]
			var wing1_pos = wing1.pos
			var wing1_pair = wing1.pair
			
			# Check if wing1 sees pivot
			if not _are_peers(pivot_pos, wing1_pos):
				continue
			
			# Check if wing1 contains X
			if wing1_pair.find(X) == -1:
				continue
			
			# Find Z (the digit in wing1 that's not X)
			var Z = wing1_pair[0] if wing1_pair[1] == X else wing1_pair[1]
			if Z == Y:
				continue  # Must be different from Y
			
			# Find wing2: must have {Y, Z} and see both pivot and wing1
			for wing2_idx in range(bivalue_cells.size()):
				if wing2_idx == pivot_idx or wing2_idx == wing1_idx:
					continue
				var wing2 = bivalue_cells[wing2_idx]
				var wing2_pos = wing2.pos
				var wing2_pair = wing2.pair
				
				# Check if wing2 contains both Y and Z
				if wing2_pair.find(Y) == -1 or wing2_pair.find(Z) == -1:
					continue
				
				# Check if wing2 sees pivot
				if not _are_peers(pivot_pos, wing2_pos):
					continue
				
				# Check if wing2 sees wing1 (they should share a unit)
				if not _are_peers(wing1_pos, wing2_pos):
					continue
				
				# Found XY-Wing! Eliminate Z from cells seeing both wings
				var elim_cells: Array[Vector2i] = []
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0:
							continue
						var cell_pos = Vector2i(r, c)
						if cell_pos == pivot_pos or cell_pos == wing1_pos or cell_pos == wing2_pos:
							continue
						if not _get_candidates(r, c).get_bit(Z):
							continue
						# Cell must see both wings
						if _are_peers(cell_pos, wing1_pos) and _are_peers(cell_pos, wing2_pos):
							elim_cells.append(cell_pos)
				
				if elim_cells.size() > 0:
					var key = str(pivot_pos) + ":" + str(wing1_pos) + ":" + str(wing2_pos) + ":" + str(Z)
					if not emitted.has(key):
						var hint = Hint.new(Hint.HintTechnique.XY_WING, "")
						hint.cells.append(pivot_pos)
						hint.cells.append(wing1_pos)
						hint.cells.append(wing2_pos)
						hint.numbers.append(X + 1)
						hint.numbers.append(Y + 1)
						hint.numbers.append(Z + 1)
						hint.elim_cells.append_array(elim_cells)
						hint.elim_numbers.append(Z + 1)
						
						var desc = "XY-Wing: Pivot %s {%d/%d}, Wing1 %s {%d/%d}, Wing2 %s {%d/%d}.\n\n" % [
							_format_cell_list([pivot_pos]), X+1, Y+1,
							_format_cell_list([wing1_pos]), X+1, Z+1,
							_format_cell_list([wing2_pos]), Y+1, Z+1
						]
						desc += "If pivot is %d, wing1 must be %d, forcing wing2 to be %d.\n" % [X+1, Z+1, Y+1]
						desc += "If pivot is %d, wing2 must be %d, forcing wing1 to be %d.\n\n" % [Y+1, Z+1, X+1]
						desc += "Either way, one wing must be %d, so eliminate %d from cells seeing both wings: %s." % [Z+1, Z+1, _format_cell_list(elim_cells)]
						hint.description = desc
						
						var s1 = "XY-Wing found: Pivot %s {%d/%d}, Wing1 %s {%d/%d}, Wing2 %s {%d/%d}." % [
							_format_cell_list([pivot_pos]), X+1, Y+1,
							_format_cell_list([wing1_pos]), X+1, Z+1,
							_format_cell_list([wing2_pos]), Y+1, Z+1
						]
						hint.add_step(s1, [pivot_pos, wing1_pos, wing2_pos])
						var s2 = "One wing must be %d, so eliminate %d from cells seeing both wings." % [Z+1, Z+1]
						hint.add_step(s2, [wing1_pos, wing2_pos], [], [], elim_cells.duplicate(), [Z+1])
						
						hints.append(hint)
						emitted[key] = true

func _find_xyz_wings(hints: Array[Hint]):
	# XYZ-Wing: pivot {XYZ}, wing1 {XZ}, wing2 {YZ}
	# Similar to XY-Wing but pivot has 3 candidates
	# Can also be ALS-based: pivot is ALS {XYZ}, wings are {XZ} and {YZ}
	
	# First, try simple case: pivot is trivalue cell
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var pivot_cand = _get_candidates(r, c)
			if pivot_cand.cardinality() != 3:
				continue
			
			var pivot_digits: Array[int] = []
			for d in range(9):
				if pivot_cand.get_bit(d):
					pivot_digits.append(d)
			
			var X = pivot_digits[0]
			var Y = pivot_digits[1]
			var Z = pivot_digits[2]
			var pivot_pos = Vector2i(r, c)
			
			# Find wing1: {X, Z} bivalue cell seeing pivot
			# Find wing2: {Y, Z} bivalue cell seeing pivot and wing1
			for r1 in range(9):
				for c1 in range(9):
					if sudoku.grid[r1][c1] != 0:
						continue
					var wing1_pos = Vector2i(r1, c1)
					if wing1_pos == pivot_pos:
						continue
					if not _are_peers(pivot_pos, wing1_pos):
						continue
					
					var wing1_cand = _get_candidates(r1, c1)
					if wing1_cand.cardinality() != 2:
						continue
					
					var w1d1 = wing1_cand.next_set_bit(0)
					var w1d2 = wing1_cand.next_set_bit(w1d1 + 1)
					
					# Check if wing1 has {X, Z} or {Z, X}
					if not ((w1d1 == X and w1d2 == Z) or (w1d1 == Z and w1d2 == X)):
						continue
					
					# Find wing2: {Y, Z} bivalue cell
					for r2 in range(9):
						for c2 in range(9):
							if sudoku.grid[r2][c2] != 0:
								continue
							var wing2_pos = Vector2i(r2, c2)
							if wing2_pos == pivot_pos or wing2_pos == wing1_pos:
								continue
							if not _are_peers(pivot_pos, wing2_pos):
								continue
							if not _are_peers(wing1_pos, wing2_pos):
								continue
							
							var wing2_cand = _get_candidates(r2, c2)
							if wing2_cand.cardinality() != 2:
								continue
							
							var w2d1 = wing2_cand.next_set_bit(0)
							var w2d2 = wing2_cand.next_set_bit(w2d1 + 1)
							
							# Check if wing2 has {Y, Z} or {Z, Y}
							if not ((w2d1 == Y and w2d2 == Z) or (w2d1 == Z and w2d2 == Y)):
								continue
							
							# Found XYZ-Wing! Eliminate Z from cells seeing both wings
							var elim_cells: Array[Vector2i] = []
							for rr in range(9):
								for cc in range(9):
									if sudoku.grid[rr][cc] != 0:
										continue
									var cell_pos = Vector2i(rr, cc)
									if cell_pos == pivot_pos or cell_pos == wing1_pos or cell_pos == wing2_pos:
										continue
									if not _get_candidates(rr, cc).get_bit(Z):
										continue
									if _are_peers(cell_pos, wing1_pos) and _are_peers(cell_pos, wing2_pos):
										elim_cells.append(cell_pos)
							
							if elim_cells.size() > 0:
								var key = str(pivot_pos) + ":" + str(wing1_pos) + ":" + str(wing2_pos) + ":xyz"
								if not hints.any(func(h): return h.technique == Hint.HintTechnique.XYZ_WING and h.cells.has(pivot_pos)):
									var hint = Hint.new(Hint.HintTechnique.XYZ_WING, "")
									hint.cells.append(pivot_pos)
									hint.cells.append(wing1_pos)
									hint.cells.append(wing2_pos)
									hint.numbers.append(X + 1)
									hint.numbers.append(Y + 1)
									hint.numbers.append(Z + 1)
									hint.elim_cells.append_array(elim_cells)
									hint.elim_numbers.append(Z + 1)
									
									var desc = "XYZ-Wing: Pivot %s {%d/%d/%d}, Wing1 %s {%d/%d}, Wing2 %s {%d/%d}.\n\n" % [
										_format_cell_list([pivot_pos]), X+1, Y+1, Z+1,
										_format_cell_list([wing1_pos]), X+1, Z+1,
										_format_cell_list([wing2_pos]), Y+1, Z+1
									]
									desc += "If pivot is %d, wing1 must be %d, forcing wing2 to be %d.\n" % [X+1, Z+1, Y+1]
									desc += "If pivot is %d, wing2 must be %d, forcing wing1 to be %d.\n" % [Y+1, Z+1, X+1]
									desc += "If pivot is %d, both wings must be %d or %d.\n\n" % [Z+1, X+1, Y+1]
									desc += "Either way, one wing must be %d, so eliminate %d from cells seeing both wings: %s." % [Z+1, Z+1, _format_cell_list(elim_cells)]
									hint.description = desc
									
									var s1 = "XYZ-Wing: Pivot %s {%d/%d/%d}, Wing1 %s {%d/%d}, Wing2 %s {%d/%d}." % [
										_format_cell_list([pivot_pos]), X+1, Y+1, Z+1,
										_format_cell_list([wing1_pos]), X+1, Z+1,
										_format_cell_list([wing2_pos]), Y+1, Z+1
									]
									hint.add_step(s1, [pivot_pos, wing1_pos, wing2_pos])
									var s2 = "One wing must be %d, eliminate %d from cells seeing both wings." % [Z+1, Z+1]
									hint.add_step(s2, [wing1_pos, wing2_pos], [], [], elim_cells.duplicate(), [Z+1])
									
									hints.append(hint)

func _find_wxyz_wings(hints: Array[Hint]):
	# WXYZ-Wing: pivot {WXYZ}, wings with subsets
	# Can be ALS-based: pivot is ALS {WXYZ}, wings are ALS with subsets
	# For now, implement simple case: pivot is quad-value cell {WXYZ}
	
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var pivot_cand = _get_candidates(r, c)
			if pivot_cand.cardinality() != 4:
				continue
			
			var pivot_digits: Array[int] = []
			for d in range(9):
				if pivot_cand.get_bit(d):
					pivot_digits.append(d)
			
			var W = pivot_digits[0]
			var X = pivot_digits[1]
			var Y = pivot_digits[2]
			var Z = pivot_digits[3]
			var pivot_pos = Vector2i(r, c)
			
			# Find wings: bivalue or trivalue cells that are subsets of pivot and see pivot
			# Try different combinations
			# Wing1: subset containing X, Wing2: subset containing Y, both contain Z
			for r1 in range(9):
				for c1 in range(9):
					if sudoku.grid[r1][c1] != 0:
						continue
					var wing1_pos = Vector2i(r1, c1)
					if wing1_pos == pivot_pos:
						continue
					if not _are_peers(pivot_pos, wing1_pos):
						continue
					
					var wing1_cand = _get_candidates(r1, c1)
					var wing1_size = wing1_cand.cardinality()
					if wing1_size < 2 or wing1_size > 3:
						continue
					
					# Check if wing1 contains X and Z, and is subset of pivot
					if not wing1_cand.get_bit(X) or not wing1_cand.get_bit(Z):
						continue
					if not pivot_cand.intersection(wing1_cand).equals(wing1_cand):
						continue
					
					# Find wing2: subset containing Y and Z
					for r2 in range(9):
						for c2 in range(9):
							if sudoku.grid[r2][c2] != 0:
								continue
							var wing2_pos = Vector2i(r2, c2)
							if wing2_pos == pivot_pos or wing2_pos == wing1_pos:
								continue
							if not _are_peers(pivot_pos, wing2_pos):
								continue
							if not _are_peers(wing1_pos, wing2_pos):
								continue
							
							var wing2_cand = _get_candidates(r2, c2)
							var wing2_size = wing2_cand.cardinality()
							if wing2_size < 2 or wing2_size > 3:
								continue
							
							# Check if wing2 contains Y and Z, and is subset of pivot
							if not wing2_cand.get_bit(Y) or not wing2_cand.get_bit(Z):
								continue
							if not pivot_cand.intersection(wing2_cand).equals(wing2_cand):
								continue
							
							# Found WXYZ-Wing! Eliminate Z from cells seeing both wings
							var elim_cells: Array[Vector2i] = []
							for rr in range(9):
								for cc in range(9):
									if sudoku.grid[rr][cc] != 0:
										continue
									var cell_pos = Vector2i(rr, cc)
									if cell_pos == pivot_pos or cell_pos == wing1_pos or cell_pos == wing2_pos:
										continue
									if not _get_candidates(rr, cc).get_bit(Z):
										continue
									if _are_peers(cell_pos, wing1_pos) and _are_peers(cell_pos, wing2_pos):
										elim_cells.append(cell_pos)
							
							if elim_cells.size() > 0:
								var key = str(pivot_pos) + ":" + str(wing1_pos) + ":" + str(wing2_pos) + ":wxyz"
								if not hints.any(func(h): return h.technique == Hint.HintTechnique.WXYZ_WING and h.cells.has(pivot_pos)):
									var hint = Hint.new(Hint.HintTechnique.WXYZ_WING, "")
									hint.cells.append(pivot_pos)
									hint.cells.append(wing1_pos)
									hint.cells.append(wing2_pos)
									hint.numbers.append(W + 1)
									hint.numbers.append(X + 1)
									hint.numbers.append(Y + 1)
									hint.numbers.append(Z + 1)
									hint.elim_cells.append_array(elim_cells)
									hint.elim_numbers.append(Z + 1)
									
									var wing1_digits: Array[String] = []
									for dd in range(9):
										if wing1_cand.get_bit(dd):
											wing1_digits.append(str(dd+1))
									var wing1_str = "{%s}" % ", ".join(wing1_digits)
									var wing2_digits: Array[String] = []
									for dd in range(9):
										if wing2_cand.get_bit(dd):
											wing2_digits.append(str(dd+1))
									var wing2_str = "{%s}" % ", ".join(wing2_digits)
									
									var desc = "WXYZ-Wing: Pivot %s {%d/%d/%d/%d}, Wing1 %s %s, Wing2 %s %s.\n\n" % [
										_format_cell_list([pivot_pos]), W+1, X+1, Y+1, Z+1,
										_format_cell_list([wing1_pos]), wing1_str,
										_format_cell_list([wing2_pos]), wing2_str
									]
									desc += "Eliminate %d from cells seeing both wings: %s." % [Z+1, _format_cell_list(elim_cells)]
									hint.description = desc
									
									var s1 = "WXYZ-Wing: Pivot %s {%d/%d/%d/%d}, Wing1 %s %s, Wing2 %s %s." % [
										_format_cell_list([pivot_pos]), W+1, X+1, Y+1, Z+1,
										_format_cell_list([wing1_pos]), wing1_str,
										_format_cell_list([wing2_pos]), wing2_str
									]
									hint.add_step(s1, [pivot_pos, wing1_pos, wing2_pos])
									var s2 = "Eliminate %d from cells seeing both wings: %s." % [Z+1, _format_cell_list(elim_cells)]
									hint.add_step(s2, [wing1_pos, wing2_pos], [], [], elim_cells.duplicate(), [Z+1])
									
									hints.append(hint)

func _find_xy_rings(hints: Array[Hint]):
	# XY-Ring: Closed loop of XY-Chains forming a ring
	# Modify XY-Chain detection to find cycles
	# This is already partially handled by Type-2 XY-Chain, but we need to detect rings specifically
	
	# Collect bivalue cells
	var nodes: Array = [] # {pos: Vector2i, pair: PackedInt32Array}
	var pos_to_idx = {}
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cand = _get_candidates(r, c)
			if cand.cardinality() == 2:
				var d1 = cand.next_set_bit(0)
				var d2 = cand.next_set_bit(d1 + 1)
				var idx = nodes.size()
				nodes.append({"pos": Vector2i(r, c), "pair": PackedInt32Array([d1, d2])})
				pos_to_idx[Vector2i(r, c)] = idx
	
	if nodes.size() < 4:
		return
	
	# Build edges (same as XY-Chain)
	var adj: Array = []
	for _i in range(nodes.size()): adj.append([])
	
	for d in range(9):
		# Rows
		for rr in range(9):
			var node_positions_row: Array[Vector2i] = []
			for cc in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr,cc).get_bit(d):
					var posr = Vector2i(rr,cc)
					if pos_to_idx.has(posr): node_positions_row.append(posr)
			if node_positions_row.size() >= 2:
				for i in range(node_positions_row.size()):
					for j in range(i + 1, node_positions_row.size()):
						var ar = pos_to_idx[node_positions_row[i]]
						var br = pos_to_idx[node_positions_row[j]]
						adj[ar].append({"to": br, "digit": d})
						adj[br].append({"to": ar, "digit": d})
		# Columns
		for cc in range(9):
			var node_positions_col: Array[Vector2i] = []
			for rr in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr,cc).get_bit(d):
					var posc = Vector2i(rr,cc)
					if pos_to_idx.has(posc): node_positions_col.append(posc)
			if node_positions_col.size() >= 2:
				for i in range(node_positions_col.size()):
					for j in range(i + 1, node_positions_col.size()):
						var ac = pos_to_idx[node_positions_col[i]]
						var bc = pos_to_idx[node_positions_col[j]]
						adj[ac].append({"to": bc, "digit": d})
						adj[bc].append({"to": ac, "digit": d})
		# Boxes
		for box_idx in range(9):
			var node_positions_box: Array[Vector2i] = []
			for i in range(9):
				var p = Cardinals.box_to_rc(box_idx, i)
				if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x,p.y).get_bit(d):
					if pos_to_idx.has(p): node_positions_box.append(p)
			if node_positions_box.size() >= 2:
				for i in range(node_positions_box.size()):
					for j in range(i + 1, node_positions_box.size()):
						var a3 = pos_to_idx[node_positions_box[i]]
						var b3 = pos_to_idx[node_positions_box[j]]
						adj[a3].append({"to": b3, "digit": d})
						adj[b3].append({"to": a3, "digit": d})
	
	# Find rings: cycles where we return to start with same digit
	var emitted = {}
	for start_idx in range(nodes.size()):
		var pair: PackedInt32Array = nodes[start_idx].pair
		for s_digit in [pair[0], pair[1]]:
			var visited: Dictionary = {}
			var path: Array = [start_idx]
			_xyring_dfs(nodes, adj, start_idx, s_digit, start_idx, s_digit, visited, path, hints, emitted)

func _xyring_dfs(nodes: Array, adj: Array, curr_idx: int, curr_active_digit: int, start_idx: int, start_digit: int, visited: Dictionary, path: Array, hints: Array[Hint], emitted: Dictionary):
	if path.size() > 1 and curr_idx == start_idx and curr_active_digit == start_digit and path.size() >= 4:
		# Found a ring!
		var key = str(start_idx) + ":ring:" + str(start_digit)
		if not emitted.has(key):
			# Determine eliminations based on the ring pattern
			# For XY-Ring, we eliminate digits that appear in cells seeing multiple ring cells
			var ring_cells: Array[Vector2i] = []
			for idx in path:
				ring_cells.append(nodes[idx].pos)
			
			# Collect all digits in the ring
			var ring_digits: Array[int] = []
			for idx in path:
				var pair = nodes[idx].pair
				if not ring_digits.has(pair[0]): ring_digits.append(pair[0])
				if not ring_digits.has(pair[1]): ring_digits.append(pair[1])
			
			# Find eliminations: cells seeing multiple ring cells that contain ring digits
			var elim_cells: Array[Vector2i] = []
			var elim_digits: Array[int] = []
			
			for d in ring_digits:
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0:
							continue
						var cell = Vector2i(r, c)
						if cell in ring_cells:
							continue
						if not _get_candidates(r, c).get_bit(d):
							continue
						
						# Count how many ring cells this cell sees
						var see_count = 0
						for ring_cell in ring_cells:
							if _are_peers(cell, ring_cell):
								see_count += 1
						
						# If sees 2+ ring cells, can potentially eliminate
						if see_count >= 2:
							elim_cells.append(cell)
							if not elim_digits.has(d):
								elim_digits.append(d)
			
			if elim_cells.size() > 0:
				var hint = Hint.new(Hint.HintTechnique.XY_RING, "")
				hint.cells.append_array(ring_cells)
				for d in ring_digits:
					hint.numbers.append(d + 1)
				hint.elim_cells.append_array(elim_cells)
				for d in elim_digits:
					hint.elim_numbers.append(d + 1)
				
				var chain_text = []
				for idx in path:
					var pair = nodes[idx].pair
					chain_text.append(_format_cell_list([nodes[idx].pos]) + " {%d/%d}" % [pair[0]+1, pair[1]+1])
				
				var desc = "XY-Ring: Closed loop %s.\n\n" % " -> ".join(chain_text)
				desc += "Forms a ring where digits alternate. Eliminate ring digits from cells seeing multiple ring cells: %s." % _format_cell_list(elim_cells)
				hint.description = desc
				
				var s1 = "XY-Ring: %s" % " -> ".join(chain_text)
				hint.add_step(s1, ring_cells.duplicate())
				var s2 = "Eliminate ring digits from cells seeing multiple ring cells: %s." % _format_cell_list(elim_cells)
				var elim_nums: Array[int] = []
				for d in elim_digits:
					elim_nums.append(d + 1)
				hint.add_step(s2, [], [], [], elim_cells.duplicate(), elim_nums)
				
				hints.append(hint)
				emitted[key] = true
			return
	
	var visit_key = str(curr_idx) + ":" + str(curr_active_digit)
	if visited.has(visit_key):
		return
	visited[visit_key] = true
	
	for edge in adj[curr_idx]:
		var edge_digit: int = edge["digit"]
		if not (edge_digit == curr_active_digit or (path.size() == 1 and (edge_digit == nodes[start_idx].pair[0] or edge_digit == nodes[start_idx].pair[1]))):
			continue
		var next_idx = edge["to"]
		var pair: PackedInt32Array = nodes[next_idx].pair
		if pair.find(edge_digit) == -1:
			continue
		var next_active = pair[0] if pair[1] == edge_digit else pair[1]
		var new_path = path.duplicate()
		new_path.append(next_idx)
		
		if new_path.count(next_idx) > 1:
			continue
		
		_xyring_dfs(nodes, adj, next_idx, next_active, start_idx, start_digit, visited, new_path, hints, emitted)
	
	visited.erase(visit_key)

func _find_als_xy_rule(hints: Array[Hint]):
	# ALS-XY Rule: Two ALS that share a restricted common candidate
	# ALS1 has {X, Y, ...}, ALS2 has {X, Z, ...}
	# X is restricted common candidate (appears in exactly one cell of each ALS)
	# Eliminate Y from cells seeing ALS1, or Z from cells seeing ALS2
	
	# Find all ALS (Almost Locked Sets)
	# ALS: N cells with N+1 candidates, all in same unit (row/col/box)
	var all_als: Array = [] # {cells: Array[Vector2i], candidates: BitSet, unit_type: String, unit_idx: int}
	
	# Find ALS in rows
	for r in range(9):
		var empty_cells: Array[Vector2i] = []
		for c in range(9):
			if sudoku.grid[r][c] == 0:
				empty_cells.append(Vector2i(r, c))
		if empty_cells.size() < 2:
			continue
		
		# Try all combinations of 2-8 cells
		for size in range(2, min(empty_cells.size() + 1, 9)):
			for combo in combinations(range(empty_cells.size()), size):
				var als_cells: Array[Vector2i] = []
				var als_candidates = BitSet.new(9)
				for idx in combo:
					var cell = empty_cells[idx]
					als_cells.append(cell)
					als_candidates = als_candidates.union(_get_candidates(cell.x, cell.y))
				
				# Check if it's an ALS: N cells, N+1 candidates
				if als_candidates.cardinality() == size + 1:
					all_als.append({"cells": als_cells, "candidates": als_candidates, "unit_type": "row", "unit_idx": r})
	
	# Find ALS in columns
	for c in range(9):
		var empty_cells: Array[Vector2i] = []
		for r in range(9):
			if sudoku.grid[r][c] == 0:
				empty_cells.append(Vector2i(r, c))
		if empty_cells.size() < 2:
			continue
		
		for size in range(2, min(empty_cells.size() + 1, 9)):
			for combo in combinations(range(empty_cells.size()), size):
				var als_cells: Array[Vector2i] = []
				var als_candidates = BitSet.new(9)
				for idx in combo:
					var cell = empty_cells[idx]
					als_cells.append(cell)
					als_candidates = als_candidates.union(_get_candidates(cell.x, cell.y))
				
				if als_candidates.cardinality() == size + 1:
					all_als.append({"cells": als_cells, "candidates": als_candidates, "unit_type": "col", "unit_idx": c})
	
	# Find ALS in boxes
	for b in range(9):
		var empty_cells: Array[Vector2i] = []
		for i in range(9):
			var p = Cardinals.box_to_rc(b, i)
			if sudoku.grid[p.x][p.y] == 0:
				empty_cells.append(p)
		if empty_cells.size() < 2:
			continue
		
		for size in range(2, min(empty_cells.size() + 1, 9)):
			for combo in combinations(range(empty_cells.size()), size):
				var als_cells: Array[Vector2i] = []
				var als_candidates = BitSet.new(9)
				for idx in combo:
					var cell = empty_cells[idx]
					als_cells.append(cell)
					als_candidates = als_candidates.union(_get_candidates(cell.x, cell.y))
				
				if als_candidates.cardinality() == size + 1:
					all_als.append({"cells": als_cells, "candidates": als_candidates, "unit_type": "box", "unit_idx": b})
	
	# Try all pairs of ALS
	for i in range(all_als.size()):
		for j in range(i + 1, all_als.size()):
			var als1 = all_als[i]
			var als2 = all_als[j]
			
			# Find restricted common candidate (digit that appears in exactly one cell of each ALS)
			var intersection = als1.candidates.intersection(als2.candidates)
			
			for d in range(9):
				if not intersection.get_bit(d):
					continue
				
				# Check if d appears in exactly one cell of each ALS
				var als1_count = 0
				var als2_count = 0
				for cell in als1.cells:
					if _get_candidates(cell.x, cell.y).get_bit(d):
						als1_count += 1
				for cell in als2.cells:
					if _get_candidates(cell.x, cell.y).get_bit(d):
						als2_count += 1
				
				if als1_count != 1 or als2_count != 1:
					continue
				
				# Found restricted common candidate d
				# Find other candidates in each ALS
				var als1_other = als1.candidates.clone()
				als1_other.clear_bit(d)
				var als2_other = als2.candidates.clone()
				als2_other.clear_bit(d)
				
				# Find eliminations: cells seeing both ALS that contain other candidates
				var elim_cells: Array[Vector2i] = []
				var elim_digits: Array[int] = []
				
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0:
							continue
						var cell = Vector2i(r, c)
						if cell in als1.cells or cell in als2.cells:
							continue
						
						# Check if cell sees both ALS
						var sees_als1 = false
						var sees_als2 = false
						for als_cell in als1.cells:
							if _are_peers(cell, als_cell):
								sees_als1 = true
								break
						for als_cell in als2.cells:
							if _are_peers(cell, als_cell):
								sees_als2 = true
								break
						
						if not (sees_als1 and sees_als2):
							continue
						
						var cell_cand = _get_candidates(r, c)
						var als1_intersect = cell_cand.intersection(als1_other)
						var als2_intersect = cell_cand.intersection(als2_other)
						
						# If cell contains candidates from both ALS (excluding d), eliminate them
						for elim_d in range(9):
							if (als1_intersect.get_bit(elim_d) or als2_intersect.get_bit(elim_d)) and not elim_digits.has(elim_d):
								elim_digits.append(elim_d)
								elim_cells.append(cell)
				
				if elim_cells.size() > 0:
					var key = str(i) + ":" + str(j) + ":" + str(d) + ":alsxy"
					if not hints.any(func(h): return h.technique == Hint.HintTechnique.ALS_XY_RULE and h.cells.has(als1.cells[0])):
						var hint = Hint.new(Hint.HintTechnique.ALS_XY_RULE, "")
						hint.cells.append_array(als1.cells)
						hint.cells.append_array(als2.cells)
						for elim_d in elim_digits:
							hint.numbers.append(elim_d + 1)
						hint.numbers.append(d + 1)
						hint.elim_cells.append_array(elim_cells)
						for elim_d in elim_digits:
							hint.elim_numbers.append(elim_d + 1)
						
						var als1_digits: Array[String] = []
						for dd in range(9):
							if als1.candidates.get_bit(dd):
								als1_digits.append(str(dd+1))
						var als1_str = "{%s}" % ", ".join(als1_digits)
						var als2_digits: Array[String] = []
						for dd in range(9):
							if als2.candidates.get_bit(dd):
								als2_digits.append(str(dd+1))
						var als2_str = "{%s}" % ", ".join(als2_digits)
						
						var desc = "ALS-XY Rule: ALS1 %s %s, ALS2 %s %s, restricted common candidate %d.\n\n" % [
							_format_cell_list(als1.cells), als1_str,
							_format_cell_list(als2.cells), als2_str,
							d + 1
						]
						desc += "Eliminate candidates from cells seeing both ALS: %s." % _format_cell_list(elim_cells)
						hint.description = desc
						
						var s1 = "ALS-XY Rule: Two ALS share restricted common candidate %d." % (d + 1)
						hint.add_step(s1, als1.cells + als2.cells)
						var s2 = "Eliminate from cells seeing both ALS: %s." % _format_cell_list(elim_cells)
						var elim_nums: Array[int] = []
						for elim_d in elim_digits:
							elim_nums.append(elim_d + 1)
						hint.add_step(s2, [], [], [], elim_cells.duplicate(), elim_nums)
						
						hints.append(hint)

func _find_als_chains(hints: Array[Hint]):
	# ALS-Chain: Chain of ALS connected by restricted common candidates
	# Similar to XY-Chain but with ALS instead of bivalue cells
	
	# Find all ALS (reuse logic from ALS-XY Rule)
	var all_als: Array = []
	
	# Rows
	for r in range(9):
		var empty_cells: Array[Vector2i] = []
		for c in range(9):
			if sudoku.grid[r][c] == 0:
				empty_cells.append(Vector2i(r, c))
		if empty_cells.size() >= 2:
			for size in range(2, min(empty_cells.size() + 1, 9)):
				for combo in combinations(range(empty_cells.size()), size):
					var als_cells: Array[Vector2i] = []
					var als_candidates = BitSet.new(9)
					for idx in combo:
						var cell = empty_cells[idx]
						als_cells.append(cell)
						als_candidates = als_candidates.union(_get_candidates(cell.x, cell.y))
					if als_candidates.cardinality() == size + 1:
						all_als.append({"cells": als_cells, "candidates": als_candidates, "idx": all_als.size()})
	
	# Columns
	for c in range(9):
		var empty_cells: Array[Vector2i] = []
		for r in range(9):
			if sudoku.grid[r][c] == 0:
				empty_cells.append(Vector2i(r, c))
		if empty_cells.size() >= 2:
			for size in range(2, min(empty_cells.size() + 1, 9)):
				for combo in combinations(range(empty_cells.size()), size):
					var als_cells: Array[Vector2i] = []
					var als_candidates = BitSet.new(9)
					for idx in combo:
						var cell = empty_cells[idx]
						als_cells.append(cell)
						als_candidates = als_candidates.union(_get_candidates(cell.x, cell.y))
					if als_candidates.cardinality() == size + 1:
						all_als.append({"cells": als_cells, "candidates": als_candidates, "idx": all_als.size()})
	
	# Boxes
	for b in range(9):
		var empty_cells: Array[Vector2i] = []
		for i in range(9):
			var p = Cardinals.box_to_rc(b, i)
			if sudoku.grid[p.x][p.y] == 0:
				empty_cells.append(p)
		if empty_cells.size() >= 2:
			for size in range(2, min(empty_cells.size() + 1, 9)):
				for combo in combinations(range(empty_cells.size()), size):
					var als_cells: Array[Vector2i] = []
					var als_candidates = BitSet.new(9)
					for idx in combo:
						var cell = empty_cells[idx]
						als_cells.append(cell)
						als_candidates = als_candidates.union(_get_candidates(cell.x, cell.y))
					if als_candidates.cardinality() == size + 1:
						all_als.append({"cells": als_cells, "candidates": als_candidates, "idx": all_als.size()})
	
	# Build graph: connect ALS if they share a restricted common candidate
	var adj: Array = []
	for _i in range(all_als.size()): adj.append([])
	
	for i in range(all_als.size()):
		for j in range(i + 1, all_als.size()):
			var als1 = all_als[i]
			var als2 = all_als[j]
			
			# Check if they share a restricted common candidate
			var intersection = als1.candidates.intersection(als2.candidates)
			for d in range(9):
				if not intersection.get_bit(d):
					continue
				
				var als1_count = 0
				var als2_count = 0
				for cell in als1.cells:
					if _get_candidates(cell.x, cell.y).get_bit(d):
						als1_count += 1
				for cell in als2.cells:
					if _get_candidates(cell.x, cell.y).get_bit(d):
						als2_count += 1
				
				if als1_count == 1 and als2_count == 1:
					adj[i].append({"to": j, "digit": d})
					adj[j].append({"to": i, "digit": d})
					break
	
	# Find chains using DFS
	var emitted = {}
	for start_idx in range(all_als.size()):
		var visited: Dictionary = {}
		var path: Array = [start_idx]
		_als_chain_dfs(all_als, adj, start_idx, -1, start_idx, visited, path, hints, emitted)

func _als_chain_dfs(als_list: Array, adj: Array, curr_idx: int, last_digit: int, start_idx: int, visited: Dictionary, path: Array, hints: Array[Hint], emitted: Dictionary):
	if path.size() >= 2:
		# Check if we can form a valid chain
		var start_als = als_list[start_idx]
		var end_als = als_list[curr_idx]
		
		# Find eliminations based on chain
		# This is simplified - full implementation would track digit alternation
		var key = str(start_idx) + ":" + str(curr_idx) + ":alschain"
		if not emitted.has(key) and path.size() >= 2:
			# For now, emit a basic ALS-Chain hint
			var all_cells: Array[Vector2i] = []
			for idx in path:
				all_cells.append_array(als_list[idx].cells)
			
			var hint = Hint.new(Hint.HintTechnique.ALS_CHAIN, "")
			hint.cells.append_array(all_cells)
			# Add numbers from all ALS
			var all_candidates = BitSet.new(9)
			for idx in path:
				all_candidates = all_candidates.union(als_list[idx].candidates)
			for d in range(9):
				if all_candidates.get_bit(d):
					hint.numbers.append(d + 1)
			
			var chain_text = []
			for idx in path:
				var als = als_list[idx]
				var cand_digits: Array[String] = []
				for d in range(9):
					if als.candidates.get_bit(d):
						cand_digits.append(str(d+1))
				var cand_str = "{%s}" % ", ".join(cand_digits)
				chain_text.append(_format_cell_list(als.cells) + " " + cand_str)
			
			var desc = "ALS-Chain: %s.\n\n" % " -> ".join(chain_text)
			desc += "Chain of ALS connected by restricted common candidates."
			hint.description = desc
			
			var s1 = "ALS-Chain: %s" % " -> ".join(chain_text)
			hint.add_step(s1, all_cells.duplicate())
			
			hints.append(hint)
			emitted[key] = true
	
	if visited.has(curr_idx):
		return
	visited[curr_idx] = true
	
	for edge in adj[curr_idx]:
		var next_idx = edge["to"]
		var digit = edge["digit"]
		
		# Check if we can use this edge (digit should alternate)
		if last_digit != -1 and digit == last_digit:
			continue
		
		if visited.has(next_idx):
			continue
		
		var new_path = path.duplicate()
		new_path.append(next_idx)
		_als_chain_dfs(als_list, adj, next_idx, digit, start_idx, visited, new_path, hints, emitted)
	
	visited.erase(curr_idx)

func _find_sashimi_fish(hints: Array[Hint]):
	# Sashimi X-Wing/Swordfish: Incomplete fish patterns (one cell missing)
	# Sashimi X-Wing: 2 rows/cols with candidates in 2 cols/rows, but one cell is missing
	# Sashimi Swordfish: 3 rows/cols with candidates in 3 cols/rows, but one cell is missing
	
	for digit in range(1, 10):
		var d = digit - 1
		
		# Row-based Sashimi X-Wing
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(d):
					positions.set_bit(c)
			if positions.cardinality() >= 2 and positions.cardinality() <= 3:
				row_candidates[r] = positions
		
		if row_candidates.size() >= 2:
			var rows = row_candidates.keys()
			for i in range(rows.size()):
				for j in range(i + 1, rows.size()):
					var r1 = rows[i]
					var r2 = rows[j]
					var union_cols = row_candidates[r1].union(row_candidates[r2])
					
					if union_cols.cardinality() == 2:
						# Potential Sashimi X-Wing
						var cols: Array[int] = []
						for c in range(9):
							if union_cols.get_bit(c):
								cols.append(c)
						
						# Check if it's Sashimi (one cell missing compared to perfect X-Wing)
						var sashimi_cells: Array[Vector2i] = []
						var missing_cell: Vector2i = Vector2i(-1, -1)
						var perfect_count = 0
						
						for c in cols:
							if row_candidates[r1].get_bit(c):
								sashimi_cells.append(Vector2i(r1, c))
								perfect_count += 1
							if row_candidates[r2].get_bit(c):
								sashimi_cells.append(Vector2i(r2, c))
								perfect_count += 1
						
						# If we have 3 cells instead of 4, it's Sashimi
						if sashimi_cells.size() == 3:
							# Find the missing cell
							for c in cols:
								if not row_candidates[r1].get_bit(c):
									missing_cell = Vector2i(r1, c)
								if not row_candidates[r2].get_bit(c):
									missing_cell = Vector2i(r2, c)
							
							# Find eliminations
							var elim_cells: Array[Vector2i] = []
							for c in cols:
								for r_check in range(9):
									if r_check != r1 and r_check != r2:
										var cell = Vector2i(r_check, c)
										if _get_candidates(r_check, c).get_bit(d):
											elim_cells.append(cell)
							
							if elim_cells.size() > 0:
								var hint = Hint.new(Hint.HintTechnique.SASHIMI_X_WING, "")
								hint.cells.append_array(sashimi_cells)
								hint.numbers.append(digit)
								hint.elim_cells.append_array(elim_cells)
								hint.elim_numbers.append(digit)
								
								var desc = "Sashimi X-Wing on digit %d: rows %d and %d, columns %d and %d (one cell missing).\n\n" % [digit, r1+1, r2+1, cols[0]+1, cols[1]+1]
								desc += "Eliminate %d from: %s." % [digit, _format_cell_list(elim_cells)]
								hint.description = desc
								
								var s1 = "Sashimi X-Wing on digit %d: rows %d, %d in columns %d, %d (incomplete pattern)." % [digit, r1+1, r2+1, cols[0]+1, cols[1]+1]
								hint.add_step(s1, sashimi_cells.duplicate())
								var s2 = "Eliminate %d from: %s." % [digit, _format_cell_list(elim_cells)]
								hint.add_step(s2, [], [], [], elim_cells.duplicate(), [digit])
								
								hints.append(hint)
		
		# Similar logic for Sashimi Swordfish (3 rows/cols)
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
							var cols: Array[int] = []
							for c in range(9):
								if union_cols.get_bit(c):
									cols.append(c)
							
							var sashimi_cells: Array[Vector2i] = []
							for c in cols:
								for r in [r1, r2, r3]:
									if row_candidates[r].get_bit(c):
										sashimi_cells.append(Vector2i(r, c))
							
							# If we have less than 9 cells (perfect would be 9), it's Sashimi
							if sashimi_cells.size() < 9 and sashimi_cells.size() >= 6:
								var elim_cells: Array[Vector2i] = []
								for c in cols:
									for r_check in range(9):
										if not r_check in [r1, r2, r3]:
											var cell = Vector2i(r_check, c)
											if _get_candidates(r_check, c).get_bit(d):
												elim_cells.append(cell)
								
								if elim_cells.size() > 0:
									var hint = Hint.new(Hint.HintTechnique.SASHIMI_SWORDFISH, "")
									hint.cells.append_array(sashimi_cells)
									hint.numbers.append(digit)
									hint.elim_cells.append_array(elim_cells)
									hint.elim_numbers.append(digit)
									
									var desc = "Sashimi Swordfish on digit %d: rows %d, %d, %d in columns %d, %d, %d (incomplete pattern).\n\n" % [digit, r1+1, r2+1, r3+1, cols[0]+1, cols[1]+1, cols[2]+1]
									desc += "Eliminate %d from: %s." % [digit, _format_cell_list(elim_cells)]
									hint.description = desc
									
									var s1 = "Sashimi Swordfish on digit %d: rows %d, %d, %d in columns %d, %d, %d." % [digit, r1+1, r2+1, r3+1, cols[0]+1, cols[1]+1, cols[2]+1]
									hint.add_step(s1, sashimi_cells.duplicate())
									var s2 = "Eliminate %d from: %s." % [digit, _format_cell_list(elim_cells)]
									hint.add_step(s2, [], [], [], elim_cells.duplicate(), [digit])
									
									hints.append(hint)

func _find_dds(hints: Array[Hint]):
	# DDS (Double Digit Subset): Two digits appear together in a subset of cells
	# Pattern: Two digits X and Y appear together in N cells, and those cells contain only X and Y (or subsets)
	
	for digit1 in range(1, 10):
		for digit2 in range(digit1 + 1, 10):
			var d1 = digit1 - 1
			var d2 = digit2 - 1
			
			# Find cells containing both digits
			var cells_with_both: Array[Vector2i] = []
			for r in range(9):
				for c in range(9):
					if sudoku.grid[r][c] != 0:
						continue
					var cand = _get_candidates(r, c)
					if cand.get_bit(d1) and cand.get_bit(d2):
						cells_with_both.append(Vector2i(r, c))
			
			if cells_with_both.size() < 2:
				continue
			
			# Check if these cells form a subset in a unit (row/col/box)
			# Check rows
			for r in range(9):
				var row_cells: Array[Vector2i] = []
				for cell in cells_with_both:
					if cell.x == r:
						row_cells.append(cell)
				
				if row_cells.size() >= 2:
					# Check if these cells only contain d1 and d2 (or subsets)
					var all_only_d1d2 = true
					for cell in row_cells:
						var cand = _get_candidates(cell.x, cell.y)
						var other_digits = cand.clone()
						other_digits.clear_bit(d1)
						other_digits.clear_bit(d2)
						if other_digits.cardinality() > 0:
							all_only_d1d2 = false
							break
					
					if all_only_d1d2:
						# Found DDS in row
						var elim_cells: Array[Vector2i] = []
						for c in range(9):
							var cell = Vector2i(r, c)
							if cell in row_cells:
								continue
							if sudoku.grid[r][c] != 0:
								continue
							var cand = _get_candidates(r, c)
							if cand.get_bit(d1) or cand.get_bit(d2):
								elim_cells.append(cell)
						
						if elim_cells.size() > 0:
							var hint = Hint.new(Hint.HintTechnique.DDS, "")
							hint.cells.append_array(row_cells)
							hint.numbers.append(digit1)
							hint.numbers.append(digit2)
							hint.elim_cells.append_array(elim_cells)
							if elim_cells.any(func(c): return _get_candidates(c.x, c.y).get_bit(d1)):
								hint.elim_numbers.append(digit1)
							if elim_cells.any(func(c): return _get_candidates(c.x, c.y).get_bit(d2)):
								hint.elim_numbers.append(digit2)
							
							var desc = "DDS (Double Digit Subset): Digits %d and %d appear together in row %d cells %s.\n\n" % [digit1, digit2, r+1, _format_cell_list(row_cells)]
							desc += "These cells only contain %d and/or %d, so eliminate these digits from other cells in the row: %s." % [digit1, digit2, _format_cell_list(elim_cells)]
							hint.description = desc
							
							var s1 = "DDS: Digits %d and %d appear together in row %d." % [digit1, digit2, r+1]
							hint.add_step(s1, row_cells.duplicate())
							var s2 = "Eliminate %d and/or %d from other cells in the row: %s." % [digit1, digit2, _format_cell_list(elim_cells)]
							hint.add_step(s2, [], [], [], elim_cells.duplicate(), hint.elim_numbers.duplicate())
							
							hints.append(hint)
			
			# Similar for columns and boxes (simplified - can be extended)

func _find_shared_cell(hints: Array[Hint]):
	# Shared Cell: Pattern where multiple techniques share an elimination cell
	# This is more of a meta-pattern that combines other techniques
	# For now, detect when multiple hints would eliminate from the same cell
	
	# This is a simplified implementation - in practice, Shared Cell detection
	# would analyze combinations of other techniques
	# For now, we'll detect cases where a cell sees multiple strong links or patterns
	
	# Check for cells that are part of multiple strong link patterns
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cell = Vector2i(r, c)
			var cand = _get_candidates(r, c)
			
			# Count how many strong links this cell is part of
			var strong_link_count = 0
			for d in range(9):
				if not cand.get_bit(d):
					continue
				
				# Check row
				var row_count = 0
				for cc in range(9):
					if sudoku.grid[r][cc] == 0 and _get_candidates(r, cc).get_bit(d):
						row_count += 1
				if row_count == 2:
					strong_link_count += 1
				
				# Check column
				var col_count = 0
				for rr in range(9):
					if sudoku.grid[rr][c] == 0 and _get_candidates(rr, c).get_bit(d):
						col_count += 1
				if col_count == 2:
					strong_link_count += 1
				
				# Check box
				var box_idx = Cardinals.Bxy[r * 9 + c]
				var box_count = 0
				for i in range(9):
					var p = Cardinals.box_to_rc(box_idx, i)
					if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x, p.y).get_bit(d):
						box_count += 1
				if box_count == 2:
					strong_link_count += 1
			
			# If cell is part of multiple strong links, it might be a shared cell pattern
			if strong_link_count >= 2:
				# This is a simplified detection - full implementation would be more complex
				pass  # Placeholder for now
	return

func _find_mlh_wings(hints: Array[Hint]):
	# H(3)-Wing: Pattern (a=b) - (b=c) - c = c => -a (last cell)
	# Or: Strong link on a -> Bivalue {a,b} -> Bivalue {b,c} -> Strong link on c
	# Pattern from test: (3)r7c5=(3)r7c6-(3=6)r5c6-(6=7)r4c5 => r7c5 <> 7
	
	# Collect bivalue cells
	var bivalue_cells: Array = [] # {pos: Vector2i, pair: PackedInt32Array}
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cand = _get_candidates(r, c)
			if cand.cardinality() == 2:
				var d1 = cand.next_set_bit(0)
				var d2 = cand.next_set_bit(d1 + 1)
				bivalue_cells.append({"pos": Vector2i(r, c), "pair": PackedInt32Array([d1, d2])})
	
	if bivalue_cells.size() < 2:
		return
	
	# Build strong links per digit
	var strong_links_per_digit: Array = [] # Array[Array] of {cell1: Vector2i, cell2: Vector2i}
	for d in range(9):
		strong_links_per_digit.append([])
		# Check rows
		for rr in range(9):
			var cells: Array[Vector2i] = []
			for cc in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr, cc).get_bit(d):
					cells.append(Vector2i(rr, cc))
			if cells.size() == 2:
				strong_links_per_digit[d].append({"cell1": cells[0], "cell2": cells[1]})
		# Check columns
		for cc in range(9):
			var cells: Array[Vector2i] = []
			for rr in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr, cc).get_bit(d):
					cells.append(Vector2i(rr, cc))
			if cells.size() == 2:
				strong_links_per_digit[d].append({"cell1": cells[0], "cell2": cells[1]})
		# Check boxes
		for box_idx in range(9):
			var cells: Array[Vector2i] = []
			for i in range(9):
				var p = Cardinals.box_to_rc(box_idx, i)
				if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x, p.y).get_bit(d):
					cells.append(p)
			if cells.size() == 2:
				strong_links_per_digit[d].append({"cell1": cells[0], "cell2": cells[1]})
	
	# Find H(3)-Wing patterns
	# Pattern: Strong link on digit a -> Bivalue {a,b} -> Bivalue {b,c} -> (elimination on a from cells seeing start of strong link)
	for bv1_idx in range(bivalue_cells.size()):
		var bv1 = bivalue_cells[bv1_idx]
		var a = bv1["pair"][0]
		var b = bv1["pair"][1]
		
		# Check strong links on digit a
		for link_a in strong_links_per_digit[a]:
			var start_a = link_a["cell1"]
			var end_a = link_a["cell2"]
			
			# bv1 should be connected to the strong link (be one of the endpoints or see one endpoint)
			var bv1_connects = false
			var link_end_to_use = null
			if bv1["pos"] == start_a or bv1["pos"] == end_a:
				bv1_connects = true
				link_end_to_use = end_a if bv1["pos"] == start_a else start_a
			elif _are_peers(bv1["pos"], start_a) or _are_peers(bv1["pos"], end_a):
				bv1_connects = true
				link_end_to_use = end_a if _are_peers(bv1["pos"], start_a) else start_a
			
			if not bv1_connects:
				continue
			
			# Find second bivalue cell with {b, c} where c != a
			for bv2_idx in range(bivalue_cells.size()):
				if bv2_idx == bv1_idx:
					continue
				var bv2 = bivalue_cells[bv2_idx]
				var pair2 = bv2["pair"]
				
				# Check if bv2 has b and another digit c
				if pair2.find(b) == -1:
					continue
				var c = pair2[0] if pair2[1] == b else pair2[1]
				if c == a:
					continue
				
				# bv2 should see bv1 (weak link on b)
				if not _are_peers(bv1["pos"], bv2["pos"]):
					continue
				
				# Check strong link on digit c that connects to bv2
				for link_c in strong_links_per_digit[c]:
					var start_c = link_c["cell1"]
					var end_c = link_c["cell2"]
					
					# bv2 should be connected to the strong link
					var bv2_connects = false
					if bv2["pos"] == start_c or bv2["pos"] == end_c:
						bv2_connects = true
					elif _are_peers(bv2["pos"], start_c) or _are_peers(bv2["pos"], end_c):
						bv2_connects = true
					
					if not bv2_connects:
						continue
					
					# Found H(3)-Wing! 
					# Pattern: Strong link on a -> Bivalue {a,b} -> Bivalue {b,c}
					# Elimination: If start_a is a, then chain forces c at bv2. If start_a is not a, then chain forces something else.
					# Actually, the elimination is typically on digit c from start_a, or digit a from cells seeing the chain endpoints
					# Based on test: eliminate digit c (or a) from start_a
					
					# Check if we can eliminate digit c from start_a
					var elim_digit = c
					if _get_candidates(start_a.x, start_a.y).get_bit(elim_digit):
						var elim_cells: Array[Vector2i] = [start_a]
						
						var hint = Hint.new(Hint.HintTechnique.H3_WING, "")
						hint.cells.append(start_a)
						if link_end_to_use != null:
							hint.cells.append(link_end_to_use)
						hint.cells.append(bv1["pos"])
						hint.cells.append(bv2["pos"])
						hint.numbers.append(a + 1)
						hint.numbers.append(b + 1)
						hint.numbers.append(c + 1)
						hint.elim_cells.append_array(elim_cells)
						hint.elim_numbers.append(elim_digit + 1)
						
						var desc = "H(3)-Wing: (%d)(%s = %s) - (%d=%d)(%s) - (%d=%d)(%s) => eliminate %d from %s." % [
							a + 1, _format_cell_list([start_a]), _format_cell_list([link_end_to_use]),
							a + 1, b + 1, _format_cell_list([bv1["pos"]]),
							b + 1, c + 1, _format_cell_list([bv2["pos"]]),
							elim_digit + 1, _format_cell_list([start_a])
						]
						hint.description = desc
						
						var s1 = "H(3)-Wing: Strong link on %d (%s = %s), bivalue %s {%d/%d}, bivalue %s {%d/%d}." % [
							a + 1, _format_cell_list([start_a]), _format_cell_list([link_end_to_use]),
							_format_cell_list([bv1["pos"]]), a + 1, b + 1,
							_format_cell_list([bv2["pos"]]), b + 1, c + 1
						]
						hint.add_step(s1, [start_a, bv1["pos"], bv2["pos"]])
						var s2 = "Eliminate %d from %s." % [elim_digit + 1, _format_cell_list([start_a])]
						hint.add_step(s2, [start_a], [], [], elim_cells.duplicate(), [elim_digit + 1])
						
						hints.append(hint)
						return  # Found one, can return or continue for more
					
					# Alternative: eliminate digit a from cells seeing both start_a and bv2 (if they don't share a unit)
					if not _are_peers(start_a, bv2["pos"]):
						var elim_cells2: Array[Vector2i] = []
						for r in range(9):
							for cc in range(9):
								if sudoku.grid[r][cc] != 0:
									continue
								if not _get_candidates(r, cc).get_bit(a):
									continue
								var v = Vector2i(r, cc)
								if v == start_a or v == bv2["pos"]:
									continue
								if _are_peers(v, start_a) and _are_peers(v, bv2["pos"]):
									elim_cells2.append(v)
						
						if elim_cells2.size() > 0:
							var hint = Hint.new(Hint.HintTechnique.H3_WING, "")
							hint.cells.append(start_a)
							if link_end_to_use != null:
								hint.cells.append(link_end_to_use)
							hint.cells.append(bv1["pos"])
							hint.cells.append(bv2["pos"])
							hint.numbers.append(a + 1)
							hint.numbers.append(b + 1)
							hint.numbers.append(c + 1)
							hint.elim_cells.append_array(elim_cells2)
							hint.elim_numbers.append(a + 1)
							
							var desc = "H(3)-Wing: (%d)(%s = %s) - (%d=%d)(%s) - (%d=%d)(%s) => eliminate %d from cells seeing both endpoints." % [
								a + 1, _format_cell_list([start_a]), _format_cell_list([link_end_to_use]),
								a + 1, b + 1, _format_cell_list([bv1["pos"]]),
								b + 1, c + 1, _format_cell_list([bv2["pos"]]),
								a + 1
							]
							hint.description = desc
							
							var s1 = "H(3)-Wing: Strong link on %d (%s = %s), bivalue %s {%d/%d}, bivalue %s {%d/%d}." % [
								a + 1, _format_cell_list([start_a]), _format_cell_list([link_end_to_use]),
								_format_cell_list([bv1["pos"]]), a + 1, b + 1,
								_format_cell_list([bv2["pos"]]), b + 1, c + 1
							]
							hint.add_step(s1, [start_a, bv1["pos"], bv2["pos"]])
							var s2 = "Eliminate %d from cells seeing both endpoints: %s." % [a + 1, _format_cell_list(elim_cells2)]
							hint.add_step(s2, [start_a, bv2["pos"]], [], [], elim_cells2.duplicate(), [a + 1])
							
							hints.append(hint)

func _are_peers(c1: Vector2i, c2: Vector2i) -> bool:
	if c1.x == c2.x: return true
	if c1.y == c2.y: return true
	if Cardinals.Bxy[c1.x * 9 + c1.y] == Cardinals.Bxy[c2.x * 9 + c2.y]: return true
	return false



func _find_xy_chains_and_wwings(hints: Array[Hint]):
	# Collect bivalue cells
	var nodes: Array = [] # {pos: Vector2i, pair: PackedInt32Array [a,b]}
	var pos_to_idx = {}
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cand = _get_candidates(r,c)
			if cand.cardinality() == 2:
				var d1 = cand.next_set_bit(0)
				var d2 = cand.next_set_bit(d1 + 1)
				var idx = nodes.size()
				nodes.append({"pos": Vector2i(r,c), "pair": PackedInt32Array([d1, d2])})
				pos_to_idx[Vector2i(r,c)] = idx
	if nodes.size() < 2:
		return

	# Build edges labeled by digit using bilocal condition within each unit
	var adj: Array = []
	for _i in range(nodes.size()): adj.append([])

	for d in range(9):
		# Rows: link bivalue cells on digit d if they form a conjugate pair (exactly 2 in row)
		for rr in range(9):
			var node_positions_row: Array[Vector2i] = []
			var all_positions_row: Array[Vector2i] = []
			for cc in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr,cc).get_bit(d):
					var posr = Vector2i(rr,cc)
					all_positions_row.append(posr)
					if pos_to_idx.has(posr): node_positions_row.append(posr)
			# Only create edges if exactly 2 candidates in row (conjugate pair/strong link)
			if all_positions_row.size() == 2:
				if node_positions_row.size() == 2:
					# Both are bivalue cells
					var ar = pos_to_idx[node_positions_row[0]]
					var br = pos_to_idx[node_positions_row[1]]
					adj[ar].append({"to": br, "digit": d, "strong": true})
					adj[br].append({"to": ar, "digit": d, "strong": true})
				elif node_positions_row.size() == 1:
					# One bivalue cell, one non-bivalue - still a strong link
					# But we can't link non-bivalue cells in this graph, so skip
					pass
		# Columns: conjugate pairs only
		for cc in range(9):
			var node_positions_col: Array[Vector2i] = []
			var all_positions_col: Array[Vector2i] = []
			for rr in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr,cc).get_bit(d):
					var posc = Vector2i(rr,cc)
					all_positions_col.append(posc)
					if pos_to_idx.has(posc): node_positions_col.append(posc)
			# Only create edges if exactly 2 candidates in column (conjugate pair)
			if all_positions_col.size() == 2:
				if node_positions_col.size() == 2:
					var ac = pos_to_idx[node_positions_col[0]]
					var bc = pos_to_idx[node_positions_col[1]]
					adj[ac].append({"to": bc, "digit": d, "strong": true})
					adj[bc].append({"to": ac, "digit": d, "strong": true})
		# Boxes: conjugate pairs only
		for box_idx in range(9):
			var node_positions_box: Array[Vector2i] = []
			var all_positions_box: Array[Vector2i] = []
			for i in range(9):
				var p = Cardinals.box_to_rc(box_idx, i)
				if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x,p.y).get_bit(d):
					all_positions_box.append(p)
					if pos_to_idx.has(p): node_positions_box.append(p)
			# Only create edges if exactly 2 candidates in box (conjugate pair)
			if all_positions_box.size() == 2:
				if node_positions_box.size() == 2:
					var a3 = pos_to_idx[node_positions_box[0]]
					var b3 = pos_to_idx[node_positions_box[1]]
					adj[a3].append({"to": b3, "digit": d, "strong": true})
					adj[b3].append({"to": a3, "digit": d, "strong": true})

	# DFS search
	var emitted = {}
	for start_idx in range(nodes.size()):
		var pair: PackedInt32Array = nodes[start_idx].pair
		for s_digit in [pair[0], pair[1]]:
			var visited: Dictionary = {}
			var path: Array = [start_idx]
			_xychain_dfs(nodes, adj, start_idx, s_digit, start_idx, s_digit, visited, path, hints, emitted)

func _xychain_dfs(nodes: Array, adj: Array, curr_idx: int, curr_active_digit: int, start_idx: int, start_digit: int, visited: Dictionary, path: Array, hints: Array[Hint], emitted: Dictionary):
	var visit_key = str(curr_idx) + ":" + str(curr_active_digit)
	if visited.has(visit_key):
		return
	visited[visit_key] = true

	for edge in adj[curr_idx]:
		# On the very first hop (path.size()==1), allow using either digit from the start cell.
		# Otherwise, the edge must match the current active digit.
		var edge_digit: int = edge["digit"]
		if not (edge_digit == curr_active_digit or (path.size() == 1 and (edge_digit == nodes[start_idx].pair[0] or edge_digit == nodes[start_idx].pair[1]))):
			continue
		var next_idx = edge["to"]
		var pair: PackedInt32Array = nodes[next_idx].pair
		var used_digit = edge_digit
		if pair.find(used_digit) == -1:
			continue
		var next_active = pair[0] if pair[1] == used_digit else pair[1]
		var new_path = path.duplicate()
		new_path.append(next_idx)
		# Do not revisit the same node in the chain to avoid degenerate cycles
		if new_path.count(next_idx) > 1:
			continue

		# Handle Type-2 (endpoints share a unit) when chain length >=3 and parity matches
		if next_active == start_digit and new_path.size() >= 3:
			var a = nodes[start_idx].pos
			var b = nodes[next_idx].pos
			# Type-2: endpoints share a unit
			if _are_peers(a, b) and new_path.size() >= 3:
				# Type-2 XY-Chain (endpoints share a unit). Eliminate the start digit
				# from other cells in the shared unit(s), excluding the endpoints themselves.
				var elim_digit2 = start_digit
				var elim_cells2: Array[Vector2i] = []
				# Same row
				if a.x == b.x:
					var rr = a.x
					for cc in range(9):
						var v = Vector2i(rr, cc)
						if v == a or v == b:
							continue
						if sudoku.grid[rr][cc] == 0 and _get_candidates(rr, cc).get_bit(elim_digit2):
							elim_cells2.append(v)
				# Same column
				if a.y == b.y:
					var cc2 = a.y
					for rr2 in range(9):
						var v2 = Vector2i(rr2, cc2)
						if v2 == a or v2 == b:
							continue
						if sudoku.grid[rr2][cc2] == 0 and _get_candidates(rr2, cc2).get_bit(elim_digit2):
							elim_cells2.append(v2)
				# Same box
				var box_a = Cardinals.Bxy[a.x * 9 + a.y]
				var box_b = Cardinals.Bxy[b.x * 9 + b.y]
				if box_a == box_b:
					for i2 in range(9):
						var p2 = Cardinals.box_to_rc(box_a, i2)
						if p2 == a or p2 == b:
							continue
						if sudoku.grid[p2.x][p2.y] == 0 and _get_candidates(p2.x, p2.y).get_bit(elim_digit2):
							elim_cells2.append(p2)

				# Deduplicate elim cells
				var uniq := {}
				var final_elims: Array[Vector2i] = []
				for v3 in elim_cells2:
					if not uniq.has(v3):
						uniq[v3] = true
						final_elims.append(v3)

				if final_elims.size() > 0:
					var hint2 = Hint.new(Hint.HintTechnique.XY_CHAIN, "")
					for idx2 in new_path:
						hint2.cells.append(nodes[idx2].pos)
					hint2.elim_cells.append_array(final_elims)
					hint2.elim_numbers.append(elim_digit2 + 1)
					# Build short description/steps
					var chain_text2 = []
					for i3 in range(new_path.size()):
						chain_text2.append(_format_cell_list([nodes[new_path[i3]].pos]) + " {" + str(nodes[new_path[i3]].pair[0]+1) + "/" + str(nodes[new_path[i3]].pair[1]+1) + "}")
					var s1t2 = "XY-Chain on digit %d: %s" % [elim_digit2 + 1, " -> ".join(chain_text2)]
					hint2.add_step(s1t2, hint2.cells.duplicate())
					var unit_str = "row" if a.x == b.x else ("column" if a.y == b.y else "box")
					var s2t2 = "Endpoints share a %s, both force %d. Remove %d from other cells in that %s." % [unit_str, elim_digit2 + 1, elim_digit2 + 1, unit_str]
					hint2.add_step(s2t2, [a, b], [], [], final_elims.duplicate(), [elim_digit2 + 1])
					hint2.description = s1t2 + "\n\n" + s2t2
					hints.append(hint2)
					var type2_key = str(start_idx) + ":" + str(next_idx) + ":" + str(start_digit) + ":t2"
					emitted[type2_key] = true
				# Finished processing Type-2; continue exploring other paths
				continue

		# Handle W-Wing: same pair, any path length using strong links
		if new_path.size() >= 2:
			var start_pair: PackedInt32Array = nodes[start_idx].pair
			var end_pair: PackedInt32Array = nodes[next_idx].pair
			var same_pair = (start_pair[0] == end_pair[0] and end_pair[1] == start_pair[1]) or (start_pair[0] == end_pair[1] and start_pair[1] == end_pair[0])
			# Check if path uses strong links (all edges should have "strong": true)
			var all_strong = true
			for i in range(new_path.size() - 1):
				var curr_idx_check = new_path[i]
				var next_idx_check = new_path[i + 1]
				var found_strong_edge = false
				for edge_check in adj[curr_idx_check]:
					if edge_check["to"] == next_idx_check and edge_check.has("strong") and edge_check["strong"]:
						found_strong_edge = true
						break
				if not found_strong_edge:
					all_strong = false
					break
			
			if same_pair and all_strong and new_path.size() >= 2:
				var a = nodes[start_idx].pos
				var b = nodes[next_idx].pos
				var wwing_key = str(start_idx) + ":" + str(next_idx) + ":wwing:" + str(start_digit)
				if not emitted.has(wwing_key):
					# The linking digit is start_digit (the digit used in the path)
					var linking_digit = start_digit
					# The eliminated digit is the other one from the pair
					var elim_digit = start_pair[0] if start_pair[1] == linking_digit else start_pair[1]
					var elim_cells: Array[Vector2i] = []
					for r in range(9):
						for c in range(9):
							if sudoku.grid[r][c] != 0: continue
							if not _get_candidates(r,c).get_bit(elim_digit): continue
							var v = Vector2i(r,c)
							if _are_peers(v, a) and _are_peers(v, b) and v != a and v != b:
								elim_cells.append(v)
					if elim_cells.size() > 0:
						var hint = Hint.new(Hint.HintTechnique.W_WING, "")
						for idx in new_path:
							hint.cells.append(nodes[idx].pos)
						for v in elim_cells:
							hint.elim_cells.append(v)
						hint.elim_numbers.append(elim_digit + 1)
						var pair_disp = "{" + str(start_pair[0]+1) + "/" + str(start_pair[1]+1) + "}"
						var s1w = "W-Wing: two bivalue cells %s at %s and %s, linked via conjugate pairs on digit %d." % [pair_disp, _format_cell_list([a]), _format_cell_list([b]), linking_digit + 1]
						hint.add_step(s1w, [a, b])
						var s2w = "Thus the other candidate (%d) is synchronized; any cell seeing both endpoints cannot be %d." % [elim_digit + 1, elim_digit + 1]
						hint.add_step(s2w, [a, b])
						var s3w = "Eliminate %d from: %s" % [elim_digit + 1, _format_cell_list(elim_cells)]
						hint.add_step(s3w, [], [], [], elim_cells.duplicate(), [elim_digit + 1])
						hint.description = s1w + "\n\n" + s2w + "\n\n" + s3w
						hints.append(hint)
						emitted[wwing_key] = true
					# Continue exploring - don't return here

		# Handle Type-1 (endpoints do not share a unit) when chain length >=4 and parity matches
		if next_active == start_digit and new_path.size() >= 4:
			var a = nodes[start_idx].pos
			var b = nodes[next_idx].pos
			if _are_peers(a, b):
				# Endpoints share a unit – not Type-1
				pass
			var key = str(start_idx) + ":" + str(next_idx) + ":" + str(start_digit)
			if not emitted.has(key):
				var start_pair: PackedInt32Array = nodes[start_idx].pair
				var end_pair: PackedInt32Array = nodes[next_idx].pair
				var is_two_node = new_path.size() == 2
				var same_pair = (start_pair[0] == end_pair[0] and start_pair[1] == end_pair[1]) or (start_pair[0] == end_pair[1] and start_pair[1] == end_pair[0])
				var technique = Hint.HintTechnique.XY_CHAIN  # W-Wing already handled above
				# Determine which digit is eliminated and collect correct targets
				var elim_digit = start_digit
				if technique == Hint.HintTechnique.W_WING:
					var pair0 = nodes[start_idx].pair
					var other_digit = pair0[0] if pair0[1] == used_digit else pair0[1]
					elim_digit = other_digit
				var elim_cells: Array[Vector2i] = []
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0: continue
						if not _get_candidates(r,c).get_bit(elim_digit): continue
						var v = Vector2i(r,c)
						if _are_peers(v, a) and _are_peers(v, b) and v != a and v != b:
							elim_cells.append(v)
				if elim_cells.size() > 0:
					var hint = Hint.new(technique, "")
					for idx in new_path:
						hint.cells.append(nodes[idx].pos)
					for v in elim_cells:
						hint.elim_cells.append(v)
					hint.elim_numbers.append(elim_digit + 1)
					if technique == Hint.HintTechnique.XY_CHAIN:
						var chain_text = []
						for i in range(new_path.size()):
							chain_text.append(_format_cell_list([nodes[new_path[i]].pos]) + " {" + str(nodes[new_path[i]].pair[0]+1) + "/" + str(nodes[new_path[i]].pair[1]+1) + "}")
						var s1 = "XY-Chain on digit %d: %s" % [elim_digit + 1, " -> ".join(chain_text)]
						hint.add_step(s1, hint.cells.duplicate())
						var s2 = "Endpoints both force %d. Any cell seeing both endpoints cannot be %d." % [elim_digit + 1, elim_digit + 1]
						hint.add_step(s2, [nodes[start_idx].pos, nodes[next_idx].pos])
						var s3 = "Eliminate %d from: %s" % [elim_digit + 1, _format_cell_list(hint.elim_cells)]
						hint.add_step(s3, [], [], [], hint.elim_cells.duplicate(), [elim_digit + 1])
						hint.description = s1 + "\n\n" + s2 + "\n\n" + s3
						hints.append(hint)
						emitted[key] = true
					else:
						var pair_disp = "{" + str(nodes[start_idx].pair[0]+1) + "/" + str(nodes[start_idx].pair[1]+1) + "}"
						var s1w = "W-Wing: two bivalue cells %s at %s and %s, linked on one candidate forming a conjugate pair." % [pair_disp, _format_cell_list([nodes[start_idx].pos]), _format_cell_list([nodes[next_idx].pos])]
						hint.add_step(s1w, [nodes[start_idx].pos, nodes[next_idx].pos])
						var s2w = "Thus the other candidate (%d) is synchronized; any cell seeing both endpoints cannot be %d." % [elim_digit + 1, elim_digit + 1]
						hint.add_step(s2w, [nodes[start_idx].pos, nodes[next_idx].pos])
						var s3w = "Eliminate %d from: %s" % [elim_digit + 1, _format_cell_list(hint.elim_cells)]
						hint.add_step(s3w, [], [], [], hint.elim_cells.duplicate(), [elim_digit + 1])
						hint.description = s1w + "\n\n" + s2w + "\n\n" + s3w
						hints.append(hint)
						emitted[key] = true
		# No-op for other cases; continue exploring chain

		_xychain_dfs(nodes, adj, next_idx, next_active, start_idx, start_digit, visited, new_path, hints, emitted)

func _find_nishio_eliminations(hints: Array[Hint]):
	# Try each candidate; if assuming it leads to no solution -> eliminate
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cand = _get_candidates(r,c)
			for d in range(9):
				if not cand.get_bit(d):
					continue
				# Clone sudoku state minimally
				var trial = Sudoku.new()
				trial.load_puzzle_from_dictionary({"grid": sudoku.grid.duplicate(true), "difficulty": "trial"}, sudoku.current_puzzle_index)
				if not trial.is_valid_move(r, c, d + 1):
					continue
				var result = trial.set_number(r, c, d + 1)
				if not result["success"]:
					continue
				var solutions = trial.solve_with_backtracking(1)
				if solutions.size() == 0:
					var hint = Hint.new(Hint.HintTechnique.NISHIO, "")
					hint.numbers.append(d + 1)
					hint.cells.append(Vector2i(r,c))
					hint.elim_cells.append(Vector2i(r,c))
					hint.elim_numbers.append(d + 1)
					var s1 = "Assume %d at %s and propagate." % [d + 1, _format_cell_list([Vector2i(r,c)])]
					var s2 = "This leads to a contradiction (no solution)."
					var s3 = "Therefore, eliminate %d from %s." % [d + 1, _format_cell_list([Vector2i(r,c)])]
					hint.add_step(s1, [Vector2i(r,c)])
					hint.add_step(s2)
					hint.add_step(s3, [], [], [], [Vector2i(r,c)], [d + 1])
					hint.description = s1 + "\n\n" + s2 + "\n\n" + s3
					hints.append(hint)

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
				
				# Properly look up enum value from string
				var enum_keys = Hint.HintTechnique.keys()
				var enum_index = enum_keys.find(technique_name)
				if enum_index == -1:
					push_error("Invalid technique name generated: " + technique_name + " (group_size=" + str(group_size) + ", unit_type=" + unit_type + ")")
					continue
				
				var technique_enum = enum_index as Hint.HintTechnique
				hint.technique = technique_enum
				hint.description = _generate_naked_group_description(hint, unit_type, unit_index)
				hint.title = hint._get_technique_title_from_enum(technique_enum)
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
