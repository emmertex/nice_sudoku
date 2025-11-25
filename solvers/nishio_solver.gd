extends RefCounted
class_name NishioSolver

var sudoku: Sudoku
var generator_ref: SudokuHintGenerator

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	generator_ref = generator
	sudoku = generator.sudoku
	_find_nishio_eliminations(hints)


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
func _get_candidates(r: int, c: int) -> BitSet:
	return generator_ref._get_candidates(r, c)

func _format_cell_list(cells: Array[Vector2i]) -> String:
	return generator_ref._format_cell_list(cells)
