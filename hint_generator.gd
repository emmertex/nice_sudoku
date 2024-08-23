extends RefCounted
class_name SudokuHintGenerator
var sudoku: Sudoku

func get_hints() -> Array:
	var hints = []

	# Single Candidate
	for row in range(9):
		for col in range(9):
			if sudoku.grid[row][col] == 0:
				var possible_numbers = []
				for num in range(1, 10):
					if sudoku.is_valid_move(row, col, num):
						possible_numbers.append(num)
				if possible_numbers.size() == 1:
					hints.append({
						"row": row,
						"col": col,
						"number": possible_numbers[0],
						"technique": "Single Candidate",
						"description": "There's only one possible number (%d) that can be placed in cell (%d, %d). All other numbers are eliminated due to the existing numbers in the same row, column, or 3x3 box." % [possible_numbers[0], row + 1, col + 1]
					})

	# Naked Pairs
	for row in range(9):
		var pairs = {}
		for col in range(9):
			if sudoku.grid[row][col] == 0:
				var possible_numbers = []
				for num in range(1, 10):
					if sudoku.is_valid_move(row, col, num):
						possible_numbers.append(num)
				if possible_numbers.size() == 2:
					var key = str(possible_numbers)
					if not pairs.has(key):
						pairs[key] = []
					pairs[key].append([row, col])
		
		for key in pairs.keys():
			var positions = pairs[key]
			if len(positions) == 2:
				var numbers = JSON.parse_string(key)
				hints.append({
					"row": positions[0][0],
					"col": positions[0][1],
					"number": numbers[0],
					"technique": "Naked Pair",
					"description": "Cells (%d, %d) and (%d, %d) in row %d can only contain the numbers %d and %d. This means these numbers can be eliminated from all other cells in the same row." % [positions[0][0] + 1, positions[0][1] + 1, positions[1][0] + 1, positions[1][1] + 1, row + 1, numbers[0], numbers[1]]
				})

	# Naked Triples
	for row in range(9):
		var triples = {}
		for col in range(9):
			if sudoku.grid[row][col] == 0:
				var possible_numbers = []
				for num in range(1, 10):
					if sudoku.is_valid_move(row, col, num):
						possible_numbers.append(num)
				if possible_numbers.size() <= 3:
					var key = str(possible_numbers)
					if not triples.has(key):
						triples[key] = []
					triples[key].append([row, col])
		
		for key in triples.keys():
			var positions = triples[key]
			if len(positions) == 3:
				var numbers = JSON.parse_string(key)
				hints.append({
					"row": positions[0][0],
					"col": positions[0][1],
					"number": numbers[0],
					"technique": "Naked Triple",
					"description": "Cells (%d, %d), (%d, %d), and (%d, %d) in row %d can only contain the numbers %s. This means these numbers can be eliminated from all other cells in the same row." % [positions[0][0] + 1, positions[0][1] + 1, positions[1][0] + 1, positions[1][1] + 1, positions[2][0] + 1, positions[2][1] + 1, row + 1, ", ".join(numbers.map(func(n): return str(n)))]
				})

	# Hidden Singles
	for num in range(1, 10):
		for row in range(9):
			var positions = []
			for col in range(9):
				if sudoku.grid[row][col] == 0 and sudoku.is_valid_move(row, col, num):
					positions.append([row, col])
			if positions.size() == 1:
				hints.append({
					"row": positions[0][0],
					"col": positions[0][1],
					"number": num,
					"technique": "Hidden Single",
					"description": "The number %d can only be placed in cell (%d, %d) of row %d. It's the only cell in this row that can accommodate this number due to the constraints in other cells." % [num, positions[0][0] + 1, positions[0][1] + 1, row + 1]
				})

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
						hints.append({
							"row": positions[0][0],
							"col": positions[0][1],
							"number": num,
							"technique": "Pointing Pair (Row)",
							"description": "The number %d can only be placed in cells (%d, %d) and (%d, %d) within the 3x3 box. This means %d can be eliminated from all other cells in row %d outside this box." % [num, positions[0][0] + 1, positions[0][1] + 1, positions[1][0] + 1, positions[1][1] + 1, num, positions[0][0] + 1]
						})
					elif positions[0][1] == positions[1][1]:  # Same column
						hints.append({
							"row": positions[0][0],
							"col": positions[0][1],
							"number": num,
							"technique": "Pointing Pair (Column)",
							"description": "The number %d can only be placed in cells (%d, %d) and (%d, %d) within the 3x3 box. This means %d can be eliminated from all other cells in column %d outside this box." % [num, positions[0][0] + 1, positions[0][1] + 1, positions[1][0] + 1, positions[1][1] + 1, num, positions[0][1] + 1]
						})

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
					hints.append({
						"row": positions[0][0],
						"col": positions[0][1],
						"number": num,
						"technique": "Box-Line Reduction",
						"description": "In row %d, the number %d can only be placed in the 3x3 box containing column %d. This means %d can be eliminated from all other cells in this 3x3 box that are not in row %d." % [row + 1, num, (positions[0][1] / 3) * 3 + 1, num, row + 1]
					})

	return hints