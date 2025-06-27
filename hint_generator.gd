extends RefCounted
class_name SudokuHintGenerator
const Hint = preload("res://hint.gd")
var sudoku: Sudoku
var strong_links: Array

func get_hints() -> Array[Hint]:
	var hints: Array[Hint] = []
	_build_strong_links()

	# Single Candidate
	for row in range(9):
		for col in range(9):
			if sudoku.grid[row][col] == 0:
				var possible_numbers = []
				var candidates = sudoku.sbrc_grid.get_candidates_for_cell(row, col)
				for i in range(9):
					if candidates.get_bit(i):
						possible_numbers.append(i + 1)
				if possible_numbers.size() == 1:
					var desc = "There's only one possible number (%d) that can be placed in cell (%d, %d)." % [possible_numbers[0], row + 1, col + 1]
					var hint = Hint.new(Hint.HintTechnique.SINGLE_CANDIDATE, desc)
					hint.cells.append(Vector2i(row, col))
					hint.numbers.append(possible_numbers[0])
					hints.append(hint)

	# --- Naked Pairs ---
	# Rows
	for r in range(9):
		var cells_with_2_candidates = []
		for c in range(9):
			if sudoku.sbrc_grid.candidates[r][c].cardinality() == 2:
				cells_with_2_candidates.append(c)
		
		if cells_with_2_candidates.size() >= 2:
			for i in range(cells_with_2_candidates.size()):
				for j in range(i + 1, cells_with_2_candidates.size()):
					var c1 = cells_with_2_candidates[i]
					var c2 = cells_with_2_candidates[j]
					var cand1 = sudoku.sbrc_grid.candidates[r][c1]
					var cand2 = sudoku.sbrc_grid.candidates[r][c2]
					
					if cand1.data == cand2.data: # Direct bitmask comparison
						var nums: Array[int] = []
						for k in range(9):
							if cand1.get_bit(k):
								nums.append(k+1)
						var desc = "Cells (%d, %d) and (%d, %d) in row %d form a Naked Pair with numbers %d and %d." % [r + 1, c1 + 1, r + 1, c2 + 1, r + 1, nums[0], nums[1]]
						var hint = Hint.new(Hint.HintTechnique.NAKED_PAIR_ROW, desc)
						hint.cells.append_array([Vector2i(r, c1), Vector2i(r, c2)])
						hint.numbers = nums
						hints.append(hint)

	# Columns
	for c in range(9):
		var cells_with_2_candidates = []
		for r in range(9):
			if sudoku.sbrc_grid.candidates[r][c].cardinality() == 2:
				cells_with_2_candidates.append(r)

		if cells_with_2_candidates.size() >= 2:
			for i in range(cells_with_2_candidates.size()):
				for j in range(i + 1, cells_with_2_candidates.size()):
					var r1 = cells_with_2_candidates[i]
					var r2 = cells_with_2_candidates[j]
					var cand1 = sudoku.sbrc_grid.candidates[r1][c]
					var cand2 = sudoku.sbrc_grid.candidates[r2][c]

					if cand1.data == cand2.data:
						var nums: Array[int] = []
						for k in range(9):
							if cand1.get_bit(k):
								nums.append(k+1)
						var desc = "Cells (%d, %d) and (%d, %d) in column %d form a Naked Pair with numbers %d and %d." % [r1 + 1, c + 1, r2 + 1, c + 1, c + 1, nums[0], nums[1]]
						var hint = Hint.new(Hint.HintTechnique.NAKED_PAIR_COL, desc)
						hint.cells.append_array([Vector2i(r1, c), Vector2i(r2, c)])
						hint.numbers = nums
						hints.append(hint)

	# Boxes
	for b in range(9):
		var cells_with_2_candidates = []
		for i in range(9):
			var pos = Cardinals.box_to_rc(b, i)
			if sudoku.sbrc_grid.candidates[pos.x][pos.y].cardinality() == 2:
				cells_with_2_candidates.append(pos)
		
		if cells_with_2_candidates.size() >= 2:
			for i in range(cells_with_2_candidates.size()):
				for j in range(i + 1, cells_with_2_candidates.size()):
					var pos1 = cells_with_2_candidates[i]
					var pos2 = cells_with_2_candidates[j]
					var cand1 = sudoku.sbrc_grid.candidates[pos1.x][pos1.y]
					var cand2 = sudoku.sbrc_grid.candidates[pos2.x][pos2.y]
					
					if cand1.data == cand2.data:
						var nums: Array[int] = []
						for k in range(9):
							if cand1.get_bit(k):
								nums.append(k+1)
						var desc = "Cells (%d, %d) and (%d, %d) in the same box form a Naked Pair with numbers %d and %d." % [pos1.x + 1, pos1.y + 1, pos2.x + 1, pos2.y + 1, nums[0], nums[1]]
						var hint = Hint.new(Hint.HintTechnique.NAKED_PAIR_BOX, desc)
						hint.cells.append_array([pos1, pos2])
						hint.numbers = nums
						hints.append(hint)

	# --- Naked Triples ---
	# Rows
	for r in range(9):
		_find_naked_groups_in_unit(hints, r, "row", 3)

	# Columns
	for c in range(9):
		_find_naked_groups_in_unit(hints, c, "col", 3)

	# Boxes
	for b in range(9):
		_find_naked_groups_in_unit(hints, b, "box", 3)

	# --- Naked Quads ---
	# Rows
	for r in range(9):
		_find_naked_groups_in_unit(hints, r, "row", 4)
	# Columns
	for c in range(9):
		_find_naked_groups_in_unit(hints, c, "col", 4)

	# Boxes
	for b in range(9):
		_find_naked_groups_in_unit(hints, b, "box", 4)

	# --- X-Wing ---
	for digit in range(1, 10):
		# Row-based X-Wing
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if sudoku.sbrc_grid.candidates[r][c].get_bit(digit - 1):
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
						
						var desc = "X-Wing on digit %d in rows %d and %d, covering columns %d and %d." % [digit, r1+1, r2+1, cols[0]+1, cols[1]+1]
						var hint = Hint.new(Hint.HintTechnique.X_WING_ROW, desc)
						hint.cells.append_array([Vector2i(r1, cols[0]), Vector2i(r1, cols[1]), Vector2i(r2, cols[0]), Vector2i(r2, cols[1])])
						hint.numbers.append(digit)
						hints.append(hint)
		# Column-based X-Wing
		var col_candidates = {}
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if sudoku.sbrc_grid.candidates[r][c].get_bit(digit - 1):
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
						
						var desc = "X-Wing on digit %d in columns %d and %d, covering rows %d and %d." % [digit, c1+1, c2+1, rows[0]+1, rows[1]+1]
						var hint = Hint.new(Hint.HintTechnique.X_WING_COL, desc)
						hint.cells.append_array([Vector2i(rows[0], c1), Vector2i(rows[1], c1), Vector2i(rows[0], c2), Vector2i(rows[1], c2)])
						hint.numbers.append(digit)
						hints.append(hint)

	# --- Swordfish ---
	for digit in range(1, 10):
		# Row-based Swordfish
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if sudoku.sbrc_grid.candidates[r][c].get_bit(digit - 1):
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
							var desc = "Swordfish on digit %d" % digit
							var hint = Hint.new(Hint.HintTechnique.SWORDFISH_ROW, desc)
							for r in [r1, r2, r3]:
								for c in cols:
									if sudoku.sbrc_grid.candidates[r][c].get_bit(digit - 1):
										hint.cells.append(Vector2i(r,c))
							hint.numbers.append(digit)
							hints.append(hint)

		# Column-based Swordfish
		var col_candidates = {}
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if sudoku.sbrc_grid.candidates[r][c].get_bit(digit - 1):
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
							var desc = "Swordfish on digit %d" % digit
							var hint = Hint.new(Hint.HintTechnique.SWORDFISH_COL, desc)
							for c in [c1, c2, c3]:
								for r in rows:
									if sudoku.sbrc_grid.candidates[r][c].get_bit(digit - 1):
										hint.cells.append(Vector2i(r,c))
							hint.numbers.append(digit)
							hints.append(hint)

	# --- Jellyfish ---
	for digit in range(1, 10):
		# Row-based Jellyfish
		var row_candidates = {}
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if sudoku.sbrc_grid.candidates[r][c].get_bit(digit - 1):
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
								var desc = "Jellyfish on digit %d" % digit
								var hint = Hint.new(Hint.HintTechnique.JELLYFISH_ROW, desc)
								for r in [r1, r2, r3, r4]:
									for c in cols:
										if sudoku.sbrc_grid.candidates[r][c].get_bit(digit - 1):
											hint.cells.append(Vector2i(r,c))
								hint.numbers.append(digit)
								hints.append(hint)

		# Column-based Jellyfish
		var col_candidates = {}
		for c in range(9):
			var positions = BitSet.new(9)
			for r in range(9):
				if sudoku.sbrc_grid.candidates[r][c].get_bit(digit - 1):
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
								var desc = "Jellyfish on digit %d" % digit
								var hint = Hint.new(Hint.HintTechnique.JELLYFISH_COL, desc)
								for c in [c1, c2, c3, c4]:
									for r in rows:
										if sudoku.sbrc_grid.candidates[r][c].get_bit(digit - 1):
											hint.cells.append(Vector2i(r,c))
								hint.numbers.append(digit)
								hints.append(hint)

	# Hidden Singles
	for num in range(1, 10):
		for row in range(9):
			var positions = []
			for col in range(9):
				if sudoku.grid[row][col] == 0 and sudoku.is_valid_move(row, col, num):
					positions.append([row, col])
			if positions.size() == 1:
				var desc = "The number %d can only be placed in cell (%d, %d) of row %d. It's the only cell in this row that can accommodate this number due to the constraints in other cells." % [num, positions[0][0] + 1, positions[0][1] + 1, row + 1]
				var hint = Hint.new(Hint.HintTechnique.HIDDEN_SINGLE, desc)
				hint.cells.append(Vector2i(positions[0][0], positions[0][1]))
				hint.numbers.append(num)
				hints.append(hint)

	# Pointing Pairs
	for num in range(1, 10):
		for box_row in range(3):
			for box_col in range(3):
				var positions = []
				for row in range(box_row * 3, box_row * 3 + 3):
					for col in range(box_col * 3, box_col * 3 + 3):
						if sudoku.grid[row][col] == 0 and sudoku.is_valid_move(row, col, num):
							positions.append([row, col])
				if len(positions) == 2:
					if positions[0][0] == positions[1][0]:  # Same row
						var desc = "The number %d can only be placed in cells (%d, %d) and (%d, %d) within the 3x3 box. This means %d can be eliminated from all other cells in row %d outside this box." % [num, positions[0][0] + 1, positions[0][1] + 1, positions[1][0] + 1, positions[1][1] + 1, num, positions[0][0] + 1]
						var hint = Hint.new(Hint.HintTechnique.POINTING_PAIR, desc)
						hint.cells.append_array([Vector2i(positions[0][0], positions[0][1]), Vector2i(positions[1][0], positions[1][1])])
						hint.numbers.append(num)
						hints.append(hint)
					elif positions[0][1] == positions[1][1]:  # Same column
						var desc = "The number %d can only be placed in cells (%d, %d) and (%d, %d) within the 3x3 box. This means %d can be eliminated from all other cells in column %d outside this box." % [num, positions[0][0] + 1, positions[0][1] + 1, positions[1][0] + 1, positions[1][1] + 1, num, positions[0][1] + 1]
						var hint = Hint.new(Hint.HintTechnique.POINTING_PAIR, desc)
						hint.cells.append_array([Vector2i(positions[0][0], positions[0][1]), Vector2i(positions[1][0], positions[1][1])])
						hint.numbers.append(num)
						hints.append(hint)

	# Box-Line Reduction
	for num in range(1, 10):
		for row in range(9):
			var positions = []
			for col in range(9):
				if sudoku.grid[row][col] == 0 and sudoku.is_valid_move(row, col, num):
					positions.append([row, col])
			if len(positions) > 0 and len(positions) < 3:
				var same_box = true
				for pos in positions:
					if pos[1] / 3 != positions[0][1] / 3:
						same_box = false
						break
				if same_box:
					var desc = "In row %d, the number %d can only be placed in the 3x3 box containing column %d. This means %d can be eliminated from all other cells in this 3x3 box that are not in row %d." % [row + 1, num, (positions[0][1] / 3) * 3 + 1, num, row + 1]
					var hint = Hint.new(Hint.HintTechnique.BOX_LINE_REDUCTION, desc)
					hint.cells.append(Vector2i(positions[0][0], positions[0][1]))
					hint.numbers.append(num)
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
		var cand_count = sudoku.sbrc_grid.candidates[cell.x][cell.y].cardinality()
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
			union_cands = union_cands.union(sudoku.sbrc_grid.candidates[cell.x][cell.y])
			
		if union_cands.cardinality() == group_size:
			var elim_found = false
			var hint = Hint.new(Hint.HintTechnique.NAKED_TRIPLE_ROW, "") # Technique will be updated
			hint.cells.append_array(group_cells)
			for i in range(9):
				if union_cands.get_bit(i):
					hint.numbers.append(i + 1)

			for cell_to_check in unit_cells:
				if not cell_to_check in group_cells:
					var cands_to_check = sudoku.sbrc_grid.candidates[cell_to_check.x][cell_to_check.y]
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
				
				hint.technique = Hint.HintTechnique.get(technique_name)
				hint.description = _generate_naked_group_description(hint, unit_type, unit_index)
				hints.append(hint)

func _generate_naked_group_description(hint: Hint, unit_type: String, unit_index: int) -> String:
	var group_type = ""
	if hint.cells.size() == 2: group_type = "Pair"
	elif hint.cells.size() == 3: group_type = "Triple"
	elif hint.cells.size() == 4: group_type = "Quad"

	var numbers_str = ", ".join(hint.numbers.map(func(n): return str(n)))
	var cells_str = ", ".join(hint.cells.map(func(c): return "(%d, %d)" % [c.x + 1, c.y + 1]))
	var elim_numbers_str = ", ".join(hint.elim_numbers.map(func(n): return str(n)))
	
	var unit_str = "%s %d" % [unit_type, unit_index + 1]

	return "In %s, the cells %s form a Naked %s with the numbers %s. This means that these numbers can be eliminated as candidates from other cells in the same %s." % [unit_str, cells_str, group_type, numbers_str, unit_type]

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
			var candidates = sudoku.sbrc_grid.candidates[r][c]
			if candidates.cardinality() == 2:
				var d1 = candidates.next_set_bit()
				var d2 = candidates.next_set_bit(d1 + 1)
				var cell_bitset = BitSet.new()
				cell_bitset.set_bit(r * 9 + c)

				# This isn't quite right. A bivalue cell links two digits in ONE cell.
				# My StrongLink class assumes one digit and two cell sets.
				# I need to rethink the data structure.
				pass
	
	# Bilocal units
	for d in range(9):
		# Rows
		for r in range(9):
			var positions = BitSet.new(9)
			for c in range(9):
				if sudoku.sbrc_grid.candidates[r][c].get_bit(d):
					positions.set_bit(c)
			if positions.cardinality() == 2:
				var c1 = positions.next_set_bit()
				var c2 = positions.next_set_bit(c1 + 1)
				
				var node1 = BitSet.new(81)
				node1.set_bit(r * 9 + c1)
				var node2 = BitSet.new(81)
				node2.set_bit(r * 9 + c2)
				
				strong_links.append(StrongLink.new(StrongLink.LinkType.BILOCAL_UNIT, d, node1, node2))

		# ... (add cols and boxes)
