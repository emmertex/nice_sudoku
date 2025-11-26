extends RefCounted
class_name NishioSolver

func name() -> String:
	return "Nishio Solver"

var sudoku: Sudoku
var generator_ref: SudokuHintGenerator

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	generator_ref = generator
	sudoku = generator.sudoku
	_find_nishio_eliminations(hints)


func _find_nishio_eliminations(hints: Array[Hint]):
	# For each digit, find placements that lead to contradictions
	for d in range(9):
		var solved_cells = _get_solved_cells_for_digit(d)

		var rows = BitSet.new(9)
		var cols = BitSet.new(9)
		var boxes = BitSet.new(9)

		# Initialize BitSets to track occupied rows/cols/boxes for this digit
		for r in range(9):
			var c = solved_cells[r]
			if c >= 0:
				# Digit d is already placed at (r,c), so mark row r, column c, and box as occupied
				rows.set_bit(r)
				cols.set_bit(c)
				boxes.set_bit(Cardinals.Bxy[r * 9 + c])

		var digit_cells = _get_digit_cells(d)
		var always_off = digit_cells.clone()
		var always_on = digit_cells.clone()

		_placements(BitSet.new(81), digit_cells, rows, cols, boxes, always_off, always_on)

		if not always_off.is_empty() or not always_on.is_empty():
			var elims = {}
			elims[d] = always_off.clone()

			# For always_on cells, eliminate other digits from those cells
			for cell_idx in _get_set_bits(always_on):
				var r = cell_idx / 9
				var c = cell_idx % 9
				var candidates = _get_candidates(r, c)
				for other_d in range(9):
					if other_d != d and candidates.get_bit(other_d):
						if not elims.has(other_d):
							elims[other_d] = BitSet.new(81)
						elims[other_d].set_bit(cell_idx)

			# Create hints for eliminations
			for elim_digit in elims:
				var elim_cells = elims[elim_digit]
				for cell_idx in _get_set_bits(elim_cells):
					var r = cell_idx / 9
					var c = cell_idx % 9
					var hint = Hint.new(Hint.HintTechnique.NISHIO, "")
					hint.numbers.append(elim_digit + 1)
					hint.cells.append(Vector2i(r, c))
					hint.elim_cells.append(Vector2i(r, c))
					hint.elim_numbers.append(elim_digit + 1)

					var s1 = "Consider all possible placements of digit %d." % [elim_digit + 1]
					var s2 = "Some cells must never contain %d, others must always contain it." % [elim_digit + 1]
					var s3 = "Therefore, eliminate %d from %s." % [elim_digit + 1, _format_cell_list([Vector2i(r, c)])]
					hint.add_step(s1)
					hint.add_step(s2)
					hint.add_step(s3, [], [], [], [Vector2i(r, c)], [elim_digit + 1])
					hint.description = s1 + "\n\n" + s2 + "\n\n" + s3
					hints.append(hint)
func _get_candidates(r: int, c: int) -> BitSet:
	return generator_ref._get_candidates(r, c)

func _format_cell_list(cells: Array[Vector2i]) -> String:
	return generator_ref._format_cell_list(cells)

func _next_clear_bit(bitset: BitSet, from_index: int) -> int:
	for i in range(from_index, 9):
		if not bitset.get_bit(i):
			return i
	return 9  # Return size when no more clear bits

func _and_not(target: BitSet, other: BitSet) -> void:
	# Modify target to keep only bits that are not set in other
	for i in range(81):
		if other.get_bit(i):
			target.clear_bit(i)

func _and(target: BitSet, other: BitSet) -> void:
	# Modify target to keep only bits that are set in both target and other
	for i in range(81):
		if not other.get_bit(i):
			target.clear_bit(i)

func _get_set_bits(bitset: BitSet) -> Array:
	var result = []
	var bit = bitset.next_set_bit(0)
	while bit != -1:
		result.append(bit)
		bit = bitset.next_set_bit(bit + 1)
	return result

func _get_solved_cells_for_digit(d: int) -> Array:
	# Return array where index r contains column c if digit d+1 is solved at (r,c), else -1
	var solved = []
	solved.resize(9)
	for i in range(9):
		solved[i] = -1

	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] == d + 1:
				solved[r] = c
				break
	return solved

func _get_digit_cells(d: int) -> BitSet:
	# Return BitSet of cells that can potentially contain digit d+1
	var cells = BitSet.new(81)
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] == 0 and _get_candidates(r, c).get_bit(d):
				cells.set_bit(r * 9 + c)
	return cells

func _placements(pattern: BitSet, open_cells: BitSet, rows: BitSet, cols: BitSet, boxes: BitSet, always_off: BitSet, always_on: BitSet) -> void:
	# Find next row that needs to be filled
	var row = _next_clear_bit(rows, 0)
	if row == 9:
		# All rows filled, update always_off and always_on
		_and_not(always_off, pattern)
		_and(always_on, pattern)
		return

	# Try placing digit in each available column/box combination
	for col in range(9):
		if cols.get_bit(col):
			continue
		var cell = row * 9 + col
		var box = Cardinals.Bxy[cell]
		if open_cells.get_bit(cell) and not boxes.get_bit(box):
			# Place the digit here
			rows.set_bit(row)
			cols.set_bit(col)
			boxes.set_bit(box)
			pattern.set_bit(cell)

			_placements(pattern, open_cells, rows, cols, boxes, always_off, always_on)

			# Backtrack
			pattern.clear_bit(cell)
			boxes.clear_bit(box)
			cols.clear_bit(col)
			rows.clear_bit(row)
