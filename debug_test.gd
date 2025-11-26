extends SceneTree

func _init():
	if Engine.is_editor_hint():
		return

	var Sudoku = load("res://sudoku_code.gd")
	var SudokuHintGenerator = load("res://hint_generator.gd")
	var Hint = load("res://hint.gd")

	var sudoku = Sudoku.new()
	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku

	# Test puzzle from test_naked_pair_row
	var puzzle_str = "003921000900307001001806400008102900700000008006708200002609500800203009005018300"
	sudoku.load_puzzle_from_string(puzzle_str)

	print("Puzzle loaded:")
	print("Row 4 (0-based): ", sudoku.grid[4])

	print("\nCandidates for row 4:")
	for c in range(9):
		var cands = hint_generator._get_candidates(4, c)
		var cand_list = []
		for i in range(9):
			if cands.get_bit(i):
				cand_list.append(i + 1)
		print("Cell (4,%d): %s" % [c, cand_list])

	var hints = hint_generator.get_hints()

	print("\nHints found: ", hints.size())
	for hint in hints:
		print("Technique: ", hint.technique)
		if hint.technique == Hint.HintTechnique.NAKED_PAIR_ROW:
			print("Found naked pair row hint!")
			print("Cells: ", hint.cells)
			print("Numbers: ", hint.numbers)
			break

	quit(0)
