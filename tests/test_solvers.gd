extends SceneTree

var _failed: int = 0

func _init():
    var exit_code := 0
    var args = OS.get_cmdline_args()
    if args.has("--test_func"):
        var func_name = args[args.find("--test_func") + 1]
        if has_method(func_name):
            var passed = call(func_name)
            exit_code = 0 if passed else 1
        else:
            push_error("Test function not found: %s" % func_name)
            exit_code = 1
    else:
        exit_code = run_all_tests()

    quit(exit_code)

func run_all_tests() -> int:
    _failed = 0
    if not test_naked_pair_row(): _failed += 1
    if not test_naked_pair_column(): _failed += 1
    if not test_naked_pair_box(): _failed += 1
    if not test_naked_triple_row(): _failed += 1
    if not test_naked_triple_column(): _failed += 1
    if not test_naked_triple_box(): _failed += 1
    if not test_x_wing_row(): _failed += 1
    if not test_x_wing_column(): _failed += 1
    if not test_backtracking_solver(): _failed += 1
    return _failed

func test_naked_pair_row() -> bool:
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
    if not found_hint:
        print("Test Naked Pair (Row) FAILED")
        return false
    print("Test Naked Pair (Row) PASSED")
    return true

func test_naked_pair_column() -> bool:
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
    if not found_hint:
        print("Test Naked Pair (Column) FAILED")
        return false
    print("Test Naked Pair (Column) PASSED")
    return true

func test_naked_pair_box() -> bool:
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
    if not found_hint:
        print("Test Naked Pair (Box) FAILED")
        return false
    print("Test Naked Pair (Box) PASSED")
    return true

func test_naked_triple_row() -> bool:
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
    if not found_hint:
        print("Test Naked Triple (Row) FAILED")
        return false
    print("Test Naked Triple (Row) PASSED")
    return true

func test_naked_triple_column() -> bool:
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
    if not found_hint:
        print("Test Naked Triple (Column) FAILED")
        return false
    print("Test Naked Triple (Column) PASSED")
    return true

func test_naked_triple_box() -> bool:
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
    if not found_hint:
        print("Test Naked Triple (Box) FAILED")
        return false
    print("Test Naked Triple (Box) PASSED")
    return true

func test_x_wing_row() -> bool:
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
    if not found_hint:
        print("Test X-Wing (Row) FAILED")
        return false
    print("Test X-Wing (Row) PASSED")
    return true

func test_x_wing_column() -> bool:
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
    if not found_hint:
        print("Test X-Wing (Column) FAILED")
        return false
    print("Test X-Wing (Column) PASSED")
    return true

func test_backtracking_solver() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "000000000000000000000000000000000000000000000000000000000000000000000001"
	sudoku.load_puzzle_from_string(puzzle_str)
	var solutions = sudoku.solve_with_backtracking(1)
    var passed = true
    if solutions.size() != 1:
        print("Backtracking solver failed to find a solution.")
        passed = false
    else:
        var solved_grid = solutions[0]
        var temp_sudoku = Sudoku.new()
        temp_sudoku.load_puzzle_from_dictionary({"grid": solved_grid, "difficulty": "solved"})
        if not temp_sudoku.sbrc_grid.is_complete():
            print("Solver returned an incomplete grid.")
            passed = false
    if passed:
        print("Test Backtracking Solver PASSED")
    else:
        print("Test Backtracking Solver FAILED")
    return passed
