extends SceneTree

func _init():
	var args = OS.get_cmdline_args()
	if args.has("--test_func"):
		var func_name = args[args.find("--test_func") + 1]
		if has_method(func_name):
			call(func_name)
		else:
			print("Test function not found: ", func_name)
	else:
		run_all_tests()
	
	var tree = Engine.get_main_loop()
	if tree is SceneTree:
		tree.quit()

func run_all_tests():
	test_naked_pair_row()
	test_naked_pair_column()
	test_naked_pair_box()
	test_naked_triple_row()
	test_naked_triple_column()
	test_naked_triple_box()
	test_x_wing_row()
	test_x_wing_column()
	test_backtracking_solver()

func test_naked_pair_row():
	var Sudoku = load("res://sudoku_code.gd")
	var SudokuHintGenerator = load("res://hint_generator.gd")
	var Hint = load("res://hint.gd")
	var sudoku = Sudoku.new()
	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku
	var puzzle_str = "003921000900307001001806400008102900700000008006708200002609500800203009005018300"
	sudoku.load_puzzle_from_string(puzzle_str)
	var hints = hint_generator.get_hints()
	var found_hint = false
	for hint in hints:
		if hint.technique == Hint.HintTechnique.NAKED_PAIR_ROW:
			if hint.cells.has(Vector2i(4, 3)) and hint.cells.has(Vector2i(4, 5)) and hint.numbers.has(4) and hint.numbers.has(5):
				found_hint = true
				break
	assert(found_hint, "Test Naked Pair (Row) FAILED")
	print("Test Naked Pair (Row) PASSED")

func test_naked_pair_column():
	var Sudoku = load("res://sudoku_code.gd")
	var SudokuHintGenerator = load("res://hint_generator.gd")
	var Hint = load("res://hint.gd")
	var sudoku = Sudoku.new()
	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku
	var puzzle_str = "...9.38...2...6.1..8.5.1.94...4.2...8.9...5.1...8.7...15.9.4.2..3.1...6...78.4..."
	sudoku.load_puzzle_from_string(puzzle_str)
	var hints = hint_generator.get_hints()
	var found_hint = false
	for hint in hints:
		if hint.technique == Hint.HintTechnique.NAKED_PAIR_COL:
			if hint.cells.has(Vector2i(1, 6)) and hint.cells.has(Vector2i(6, 6)) and hint.numbers.has(3) and hint.numbers.has(7):
				found_hint = true
				break
	assert(found_hint, "Test Naked Pair (Column) FAILED")
	print("Test Naked Pair (Column) PASSED")

func test_naked_pair_box():
	var Sudoku = load("res://sudoku_code.gd")
	var SudokuHintGenerator = load("res://hint_generator.gd")
	var Hint = load("res://hint.gd")
	var sudoku = Sudoku.new()
	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku
	var puzzle_str = "...9.38...2...6.1..8.5.1.94...4.2...8.9...5.1...8.7...15.9.4.2..3.1...6...78.4..."
	sudoku.load_puzzle_from_string(puzzle_str)
	var hints = hint_generator.get_hints()
	var found_hint = false
	for hint in hints:
		if hint.technique == Hint.HintTechnique.NAKED_PAIR_BOX:
			if hint.cells.has(Vector2i(4, 3)) and hint.cells.has(Vector2i(4, 4)) and hint.numbers.has(3) and hint.numbers.has(6):
				found_hint = true
				break
	assert(found_hint, "Test Naked Pair (Box) FAILED")
	print("Test Naked Pair (Box) PASSED")

func test_naked_triple_row():
	var Sudoku = load("res://sudoku_code.gd")
	var SudokuHintGenerator = load("res://hint_generator.gd")
	var Hint = load("res://hint.gd")
	var sudoku = Sudoku.new()
	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku
	var puzzle_str = "000260701680070090190004500820102900004602910098000063050090020070000036902010000"
	sudoku.load_puzzle_from_string(puzzle_str)
	var hints = hint_generator.get_hints()
	var found_hint = false
	for hint in hints:
		if hint.technique == Hint.HintTechnique.NAKED_TRIPLE_ROW:
			if hint.cells.has(Vector2i(0, 0)) and hint.cells.has(Vector2i(0, 1)) and hint.cells.has(Vector2i(0, 2)) and hint.numbers.has(3) and hint.numbers.has(4) and hint.numbers.has(5):
				found_hint = true
				break
	assert(found_hint, "Test Naked Triple (Row) FAILED")
	print("Test Naked Triple (Row) PASSED")

func test_naked_triple_column():
	var Sudoku = load("res://sudoku_code.gd")
	var SudokuHintGenerator = load("res://hint_generator.gd")
	var Hint = load("res://hint.gd")
	var sudoku = Sudoku.new()
	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku
	var puzzle_str = "000260701680070090190004500820102900004602910098000063050090020070000036902010000"
	sudoku.load_puzzle_from_string(puzzle_str)
	var hints = hint_generator.get_hints()
	var found_hint = false
	for hint in hints:
		if hint.technique == Hint.HintTechnique.NAKED_TRIPLE_COL:
			if hint.cells.has(Vector2i(0, 2)) and hint.cells.has(Vector2i(1, 2)) and hint.cells.has(Vector2i(2, 2)) and hint.numbers.has(3) and hint.numbers.has(5) and hint.numbers.has(7):
				found_hint = true
				break
	assert(found_hint, "Test Naked Triple (Column) FAILED")
	print("Test Naked Triple (Column) PASSED")

func test_naked_triple_box():
	var Sudoku = load("res://sudoku_code.gd")
	var SudokuHintGenerator = load("res://hint_generator.gd")
	var Hint = load("res://hint.gd")
	var sudoku = Sudoku.new()
	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku
	var puzzle_str = "000260701680070090190004500820102900004602910098000063050090020070000036902010000"
	sudoku.load_puzzle_from_string(puzzle_str)
	var hints = hint_generator.get_hints()
	var found_hint = false
	for hint in hints:
		if hint.technique == Hint.HintTechnique.NAKED_TRIPLE_BOX:
			if hint.cells.has(Vector2i(0, 0)) and hint.cells.has(Vector2i(0, 1)) and hint.cells.has(Vector2i(0, 2)) and hint.numbers.has(3) and hint.numbers.has(4) and hint.numbers.has(5):
				found_hint = true
				break
	assert(found_hint, "Test Naked Triple (Box) FAILED")
	print("Test Naked Triple (Box) PASSED")

func test_x_wing_row():
	var Sudoku = load("res://sudoku_code.gd")
	var SudokuHintGenerator = load("res://hint_generator.gd")
	var Hint = load("res://hint.gd")
	var sudoku = Sudoku.new()
	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku
	var puzzle_str = "000260701680070090190004500820102900004602910098000063050090020070000036902010000"
	sudoku.load_puzzle_from_string(puzzle_str)
	var hints = hint_generator.get_hints()
	var found_hint = false
	for hint in hints:
		if hint.technique == Hint.HintTechnique.X_WING_ROW:
			if hint.numbers.has(1) and hint.cells.has(Vector2i(6,2)) and hint.cells.has(Vector2i(7,6)):
				found_hint = true
				break
	assert(found_hint, "Test X-Wing (Row) FAILED")
	print("Test X-Wing (Row) PASSED")

func test_x_wing_column():
	var Sudoku = load("res://sudoku_code.gd")
	var SudokuHintGenerator = load("res://hint_generator.gd")
	var Hint = load("res://hint.gd")
	var sudoku = Sudoku.new()
	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku
	var puzzle_str = "000260701680070090190004500820102900004602910098000063050090020070000036902010000"
	sudoku.load_puzzle_from_string(puzzle_str)
	var hints = hint_generator.get_hints()
	var found_hint = false
	for hint in hints:
		if hint.technique == Hint.HintTechnique.X_WING_COL:
			if hint.numbers.has(1) and hint.cells.has(Vector2i(6,2)) and hint.cells.has(Vector2i(7,6)):
				found_hint = true
				break
	assert(found_hint, "Test X-Wing (Column) FAILED")
	print("Test X-Wing (Column) PASSED")

func test_backtracking_solver():
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "000000000000000000000000000000000000000000000000000000000000000000000001"
	sudoku.load_puzzle_from_string(puzzle_str)
	var solutions = sudoku.solve_with_backtracking(1)
	assert(solutions.size() == 1, "Backtracking solver failed to find a solution.")
	var solved_grid = solutions[0]
	var temp_sudoku = Sudoku.new()
	temp_sudoku.load_puzzle_from_dictionary({"grid": solved_grid, "difficulty": "solved"})
	assert(temp_sudoku.sbrc_grid.is_complete(), "Solver returned an incomplete grid.")
	print("Test Backtracking Solver PASSED") 