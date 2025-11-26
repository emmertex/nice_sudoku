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

	print("\nGrid state:")
	for r in range(9):
		print("Row %d: %s" % [r, sudoku.grid[r]])

	print("\nCandidates for some cells:")
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] == 0:  # Only show candidates for empty cells
				var cands = hint_generator._get_candidates(r, c)
				var cand_list = []
				for i in range(9):
					if cands.get_bit(i):
						cand_list.append(i + 1)
				if cand_list.size() > 0:
					print("Cell (%d,%d): %s" % [r, c, cand_list])

	var hints = hint_generator.get_hints()

	print("All hints found: ", hints.size())
	var s_wing_count = 0
	for hint in hints:
		print("Technique: ", hint.technique)
		if hint.technique == Hint.HintTechnique.S_WING:
			s_wing_count += 1
			print("Found S-Wing hint!")
			print("Description: ", hint.description)
			print("Cells: ", hint.cells)
			print("Numbers: ", hint.numbers)
			print("Elim cells: ", hint.elim_cells)
			print("Elim numbers: ", hint.elim_numbers)
			break
	print("Total S-Wing hints in full solve: ", s_wing_count)

	quit(0)
