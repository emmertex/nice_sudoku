class_name SBRCGrid
extends RefCounted

var basic_grid: Array  # 9x9 grid
var sector_data: Array  # [sector][digit] -> BitSet
var row_data: Array     # [row][digit] -> BitSet  
var col_data: Array     # [col][digit] -> BitSet
var box_data: Array     # [box][digit] -> BitSet

func _init(grid: Array):
	basic_grid = grid.duplicate(true)
	_build_sector_data()
	_build_intersection_data()

func _build_sector_data():
	# Initialize arrays
	sector_data = []
	row_data = []
	col_data = []
	box_data = []
	
	for i in range(27):  # 9 rows + 9 cols + 9 boxes
		var sector_row = []
		for j in range(9):
			sector_row.append(BitSet.new(9))
		sector_data.append(sector_row)
	
	for i in range(9):
		var row_row = []
		var col_row = []
		var box_row = []
		for j in range(9):
			row_row.append(BitSet.new(9))
			col_row.append(BitSet.new(9))
			box_row.append(BitSet.new(9))
		row_data.append(row_row)
		col_data.append(col_row)
		box_data.append(box_row)
	
	# Build sector data from grid
	for row in range(9):
		for col in range(9):
			var value = basic_grid[row][col]
			if value != 0:
				var digit = value - 1
				var box = Cardinals.Bxy[row * 9 + col]
				
				# Add to row sector
				sector_data[row][digit].set_bit(col)
				row_data[row][digit].set_bit(col)
				
				# Add to column sector
				sector_data[col + 9][digit].set_bit(row)
				col_data[col][digit].set_bit(row)
				
				# Add to box sector
				sector_data[box + 18][digit].set_bit(Cardinals.BxyN[row * 9 + col])
				box_data[box][digit].set_bit(Cardinals.BxyN[row * 9 + col])

func _build_intersection_data():
	# Build intersection data for advanced techniques
	# This will be expanded in future phases for advanced solving techniques
	pass

func get_candidates_for_cell(row: int, col: int) -> BitSet:
	var result = BitSet.new(9)
	result.set_all()

	# Remove candidates present anywhere in the row
	for digit in range(9):
		if row_data[row][digit].cardinality() > 0:
			result.clear_bit(digit)

	# Remove candidates present anywhere in the column
	for digit in range(9):
		if col_data[col][digit].cardinality() > 0:
			result.clear_bit(digit)

	# Remove candidates present anywhere in the box
	var box = Cardinals.Bxy[row * 9 + col]
	for digit in range(9):
		if box_data[box][digit].cardinality() > 0:
			result.clear_bit(digit)

	return result

func get_cell_value(row: int, col: int) -> int:
	return basic_grid[row][col]

func set_cell_value(row: int, col: int, value: int):
	var old_value = basic_grid[row][col]
	basic_grid[row][col] = value
	
	# Update sector data
	if old_value != 0:
		var old_digit = old_value - 1
		var box = Cardinals.Bxy[row * 9 + col]
		
		# Remove from sectors
		sector_data[row][old_digit].clear_bit(col)
		row_data[row][old_digit].clear_bit(col)
		sector_data[col + 9][old_digit].clear_bit(row)
		col_data[col][old_digit].clear_bit(row)
		sector_data[box + 18][old_digit].clear_bit(Cardinals.BxyN[row * 9 + col])
		box_data[box][old_digit].clear_bit(Cardinals.BxyN[row * 9 + col])
	
	if value != 0:
		var digit = value - 1
		var box = Cardinals.Bxy[row * 9 + col]
		
		# Add to sectors
		sector_data[row][digit].set_bit(col)
		row_data[row][digit].set_bit(col)
		sector_data[col + 9][digit].set_bit(row)
		col_data[col][digit].set_bit(row)
		sector_data[box + 18][digit].set_bit(Cardinals.BxyN[row * 9 + col])
		box_data[box][digit].set_bit(Cardinals.BxyN[row * 9 + col])

func get_row_candidates(row: int, digit: int) -> BitSet:
	return row_data[row][digit].clone()

func get_col_candidates(col: int, digit: int) -> BitSet:
	return col_data[col][digit].clone()

func get_box_candidates(box: int, digit: int) -> BitSet:
	return box_data[box][digit].clone()

func get_sector_candidates(sector: int, digit: int) -> BitSet:
	return sector_data[sector][digit].clone()

func is_valid_placement(row: int, col: int, value: int) -> bool:
	if value == 0:
		return true
	
	var digit = value - 1
	var box = Cardinals.Bxy[row * 9 + col]
	
	# Check if digit is already in row
	if row_data[row][digit].cardinality() > 0:
		return false
	
	# Check if digit is already in column
	if col_data[col][digit].cardinality() > 0:
		return false
	
	# Check if digit is already in box
	if box_data[box][digit].cardinality() > 0:
		return false
	
	return true

func get_empty_cells() -> Array:
	var empty = []
	for row in range(9):
		for col in range(9):
			if basic_grid[row][col] == 0:
				empty.append(Vector2i(row, col))
	return empty

func get_grid_copy() -> Array:
	return basic_grid.duplicate(true)

func update_grid(new_grid: Array):
	basic_grid = new_grid.duplicate(true)
	_build_sector_data()

func is_complete() -> bool:
	for row in range(9):
		for col in range(9):
			if basic_grid[row][col] == 0:
				return false
	return true

func get_conflicts() -> Array:
	var conflicts = []
	
	# Check rows
	for row in range(9):
		var seen = {}
		for col in range(9):
			var value = basic_grid[row][col]
			if value != 0:
				if seen.has(value):
					conflicts.append({
						"type": "row",
						"row": row,
						"value": value,
						"positions": [seen[value], Vector2i(row, col)]
					})
				else:
					seen[value] = Vector2i(row, col)
	
	# Check columns
	for col in range(9):
		var seen = {}
		for row in range(9):
			var value = basic_grid[row][col]
			if value != 0:
				if seen.has(value):
					conflicts.append({
						"type": "column",
						"col": col,
						"value": value,
						"positions": [seen[value], Vector2i(row, col)]
					})
				else:
					seen[value] = Vector2i(row, col)
	
	# Check boxes
	for box in range(9):
		var seen = {}
		var box_row = (box / 3) * 3
		var box_col = (box % 3) * 3
		for r in range(3):
			for c in range(3):
				var row = box_row + r
				var col = box_col + c
				var value = basic_grid[row][col]
				if value != 0:
					if seen.has(value):
						conflicts.append({
							"type": "box",
							"box": box,
							"value": value,
							"positions": [seen[value], Vector2i(row, col)]
						})
					else:
						seen[value] = Vector2i(row, col)
	
	return conflicts

func to_string_representation() -> String:
	var result = ""
	for row in range(9):
		if row > 0 and row % 3 == 0:
			result += "---+---+---\n"
		for col in range(9):
			if col > 0 and col % 3 == 0:
				result += "|"
			var value = basic_grid[row][col]
			result += str(value) if value != 0 else "."
		result += "\n"
	return result 