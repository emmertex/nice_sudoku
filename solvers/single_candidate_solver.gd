extends RefCounted
class_name SingleCandidateSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	for row in range(9):
		for col in range(9):
			if sudoku.grid[row][col] == 0:
				var possible_numbers = []
				var candidates = generator._get_candidates(row, col)
				for i in range(9):
					if candidates.get_bit(i):
						possible_numbers.append(i + 1)
				if possible_numbers.size() == 1:
					var num = possible_numbers[0]
					var desc = "This cell can only be %d. All other numbers from 1 to 9 are present in this cell's row, column, or box." % num
					var hint = Hint.new(Hint.HintTechnique.SINGLE_CANDIDATE, desc)
					hint.cells.append(Vector2i(row, col))
					hint.numbers.append(num)

					var peers = generator._get_peer_cells(row, col)
					hint.secondary_cells.append_array(peers)
					for peer in peers:
						if sudoku.grid[peer.x][peer.y] != 0:
							hint.cause_cells.append(peer)

					var coord = "(%d,%d)" % [row + 1, col + 1]
					var step1 = "Check cell %s: current candidates are {%s}." % [coord, ", ".join(possible_numbers.map(func(n): return str(n)))]
					hint.add_step(step1, [Vector2i(row, col)], peers, [], [], [])
					var step2 = "In its row/column/box, all numbers except %d already appear, leaving only %d." % [num, num]
					hint.add_step(step2, [Vector2i(row, col)], [], hint.cause_cells)
					var step3 = "Therefore set %d at %s." % [num, coord]
					hint.add_step(step3, [Vector2i(row, col)])

					hints.append(hint)
					return




