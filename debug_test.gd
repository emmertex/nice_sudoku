extends SceneTree

func _init():
	if Engine.is_editor_hint():
		return

	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()

	# Test puzzle from failing backtracking test (this one is invalid)
	var puzzle_str = "000260701680070090190004500820102900004602910098000063050090020070000036902010000"

	# Try a different valid puzzle
	var valid_puzzle = "530070000600195000098000060800060003400803001700020006060000280000419005000080079"
	print("Testing with invalid puzzle first:")
	var sudoku_invalid = Sudoku.new()
	sudoku_invalid.load_puzzle_from_string(puzzle_str)
	var is_valid_invalid = _validate_puzzle(sudoku_invalid.grid)
	print("Invalid puzzle validation: %s" % ("valid" if is_valid_invalid else "invalid"))

	print("\nTesting with valid puzzle:")
	var sudoku_valid = Sudoku.new()
	sudoku_valid.load_puzzle_from_string(valid_puzzle)
	var is_valid_valid = _validate_puzzle(sudoku_valid.grid)
	print("Valid puzzle validation: %s" % ("valid" if is_valid_valid else "invalid"))

	var solutions_valid = sudoku_valid.solve_with_backtracking(1)
	print("Valid puzzle solutions found: ", solutions_valid.size())

	return  # Don't run the rest of the test
	sudoku.load_puzzle_from_string(puzzle_str)

	print("Testing backtracking solver on puzzle:")
	print("Puzzle string: ", puzzle_str)
	print("\nGrid state:")
	for r in range(9):
		print("Row %d: %s" % [r, sudoku.grid[r]])

	print("\nEmpty cells:")
	var empty_cells = sudoku.sbrc_grid.get_empty_cells()
	print("Number of empty cells: ", empty_cells.size())
	for cell in empty_cells:
		var candidates = sudoku.sbrc_grid.get_candidates_for_cell(cell.x, cell.y)
		var cand_list = []
		var cand_index = candidates.next_set_bit(0)
		while cand_index != -1:
			cand_list.append(cand_index + 1)
			cand_index = candidates.next_set_bit(cand_index + 1)
		print("Cell (%d,%d): candidates = %s" % [cell.x, cell.y, cand_list])

	print("\nTesting candidates validation...")
	# Test some basic placements to see if validation works
	var test_cell = Vector2i(0, 0)  # Should be able to place 3, 4, or 5
	print("Testing cell (0,0) with candidates [3,4,5]:")
	for num in [3, 4, 5]:
		var valid = sudoku._is_valid_for_backtrack(0, 0, num)
		print("  Number %d: %s" % [num, "valid" if valid else "invalid"])

	print("\nTesting cell (4,1) with candidate [3]:")
	var valid = sudoku._is_valid_for_backtrack(4, 1, 3)
	print("  Number 3: %s" % ["valid" if valid else "invalid"])

	print("\nValidating initial puzzle...")
	var is_valid = _validate_puzzle(sudoku.grid)
	print("Puzzle validation: %s" % ("valid" if is_valid else "invalid"))

	if not is_valid:
		print("Puzzle has conflicts in the given digits!")
		quit(1)

	print("\nTesting simpler backtracking approach...")
	# Try a simpler backtracking that doesn't rely on sbrc_grid candidates
	var simple_solutions = _simple_backtracking(sudoku.grid.duplicate(true))
	print("Simple backtracking solutions found: ", simple_solutions.size())

	if simple_solutions.size() > 0:
		print("First solution from simple backtracking:")
		for r in range(9):
			print("Row %d: %s" % [r, simple_solutions[0][r]])

	print("\nRunning original backtracking solver...")
	var solutions = sudoku.solve_with_backtracking(1)
	print("Original backtracking solutions found: ", solutions.size())

	quit(0)

func _validate_puzzle(grid: Array) -> bool:
	# Check that given digits don't have conflicts
	for r in range(9):
		for c in range(9):
			if grid[r][c] != 0:
				var num = grid[r][c]
				# Temporarily remove the number to check if it's valid
				grid[r][c] = 0
				var valid = _is_valid_placement(grid, r, c, num)
				grid[r][c] = num
				if not valid:
					return false
	return true

func _simple_backtracking(grid: Array) -> Array:
	var solutions = []
	_simple_solve_recursive(0, 0, grid, solutions, 1)
	return solutions

func _simple_solve_recursive(row: int, col: int, grid: Array, solutions: Array, max_solutions: int):
	if solutions.size() >= max_solutions:
		return

	if row == 9:
		solutions.append(grid.duplicate(true))
		return

	var next_row = row
	var next_col = col + 1
	if next_col == 9:
		next_row += 1
		next_col = 0

	if grid[row][col] != 0:
		_simple_solve_recursive(next_row, next_col, grid, solutions, max_solutions)
		return

	for num in range(1, 10):
		if _is_valid_placement(grid, row, col, num):
			grid[row][col] = num
			_simple_solve_recursive(next_row, next_col, grid, solutions, max_solutions)
			grid[row][col] = 0
			if solutions.size() >= max_solutions:
				return

func _is_valid_placement(grid: Array, row: int, col: int, num: int) -> bool:
	# Check row
	for c in range(9):
		if grid[row][c] == num:
			return false
	# Check column
	for r in range(9):
		if grid[r][col] == num:
			return false
	# Check box
	var box_row = (row / 3) * 3
	var box_col = (col / 3) * 3
	for r in range(box_row, box_row + 3):
		for c in range(box_col, box_col + 3):
			if grid[r][c] == num:
				return false
	return true
