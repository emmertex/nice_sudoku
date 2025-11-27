extends RefCounted
class_name HiddenSubsetSolverBase

const UNIT_TYPES := ["row", "column", "box"]
const UNIT_SUFFIX_MAP := {
	"row": "ROW",
	"column": "COL",
	"box": "BOX"
}
const UNIT_LABEL_MAP := {
	"row": "Row",
	"column": "Column",
	"box": "Box"
}
const SUBSET_DISPLAY_MAP := {
	2: "Pair",
	3: "Triple",
	4: "Quadruple"
}
const SUBSET_TECHNIQUE_PREFIX_MAP := {
	2: "PAIR",
	3: "TRIPLE",
	4: "QUAD"
}

func name() -> String:
	return "Hidden Subset Solver"

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	for subset_size in range(2, 5):
		for unit_type in UNIT_TYPES:
			for unit_index in range(9):
				_find_hidden_subset(generator, hints, unit_type, unit_index, subset_size)

func _find_hidden_subset(generator: SudokuHintGenerator, hints: Array[Hint], unit_type: String, unit_index: int, subset_size: int) -> void:
	var sudoku = generator.sudoku
	var subset_display = _get_subset_display(subset_size)
	var unit_cells = _get_unit_cells(unit_type, unit_index)
	var candidate_map = {}
	for cell in unit_cells:
		if sudoku.grid[cell.x][cell.y] != 0:
			continue
		candidate_map[_cell_to_index(cell)] = generator._get_candidates(cell.x, cell.y)

	if candidate_map.size() < subset_size:
		return

	var digits = range(9)
	for digits_combo in generator.combinations(digits, subset_size):
		var subset_cells = []
		var subset_cell_indices = {}
		var combo_valid = true
		for digit in digits_combo:
			var digit_has_candidate = false
			for cell in unit_cells:
				var idx = _cell_to_index(cell)
				if not candidate_map.has(idx):
					continue
				if not candidate_map[idx].get_bit(digit):
					continue
				digit_has_candidate = true
				if not subset_cell_indices.has(idx):
					subset_cell_indices[idx] = cell
					subset_cells.append(cell)
			if not digit_has_candidate:
				combo_valid = false
				break
		if not combo_valid:
			continue
		if subset_cell_indices.size() != subset_size:
			continue

		var subset_digit_bits = BitSet.new(9)
		for digit in digits_combo:
			subset_digit_bits.set_bit(digit)

		var elimination_cells_map = {}
		var elimination_numbers = []
		var elimination_found = false
		for cell in subset_cells:
			var idx = _cell_to_index(cell)
			var candidates = candidate_map[idx]
			var extras = candidates.difference(subset_digit_bits)
			if extras.is_empty():
				continue
			elimination_found = true
			if not elimination_cells_map.has(idx):
				elimination_cells_map[idx] = cell
			for elim_digit in range(9):
				if extras.get_bit(elim_digit):
					var elimination_number = elim_digit + 1
					if not elimination_number in elimination_numbers:
						elimination_numbers.append(elimination_number)
		if not elimination_found:
			continue

		var subset_cells_sorted = subset_cells.duplicate()
		subset_cells_sorted.sort_custom(func(a, b):
			return _cell_to_index(a) - _cell_to_index(b))

		var elimination_cells = []
		for cell in elimination_cells_map.values():
			elimination_cells.append(cell)
		elimination_cells.sort_custom(func(a, b):
			return _cell_to_index(a) - _cell_to_index(b))

		var secondary_cells = []
		for cell in unit_cells:
			var idx = _cell_to_index(cell)
			if subset_cell_indices.has(idx):
				continue
			secondary_cells.append(cell)

		var technique_enum = _get_technique_enum(unit_type, subset_size)
		if technique_enum == null:
			return

		var hint = Hint.new(technique_enum, "")
		hint.cells.append_array(subset_cells_sorted)
		for digit in digits_combo:
			hint.numbers.append(digit + 1)
		hint.secondary_cells.append_array(secondary_cells)
		hint.elim_cells.append_array(elimination_cells)
		hint.elim_numbers.append_array(elimination_numbers)

		var digits_str = ", ".join(hint.numbers.map(func(n): return str(n)))
		var cells_str = generator._format_cell_list(hint.cells)
		var elim_numbers_str = ", ".join(hint.elim_numbers.map(func(n): return str(n)))
		var elim_cells_str = generator._format_cell_list(hint.elim_cells)
		var unit_label = _get_unit_label(unit_type)
		var description = "Hidden %s in %s %d: digits %s are confined to these cells: %s.\n\n" % [subset_display, unit_label, unit_index + 1, digits_str, cells_str]
		description += "Therefore we can remove the candidates %s from those cells: %s." % [elim_numbers_str, elim_cells_str]
		hint.description = description

		var step1 = "In %s %d, the digits %s can only go in %s." % [unit_label, unit_index + 1, digits_str, cells_str]
		hint.add_step(step1, hint.cells.duplicate(), [], [], [], [])
		var step2 = "These cells cannot contain %s, so remove those candidates from them." % [elim_numbers_str]
		hint.add_step(step2, hint.cells.duplicate(), hint.secondary_cells.duplicate(), [], hint.elim_cells.duplicate(), hint.elim_numbers.duplicate())

		hints.append(hint)

func _get_unit_cells(unit_type: String, unit_index: int) -> Array:
	var cells = []
	match unit_type:
		"row":
			for c in range(9):
				cells.append(Vector2i(unit_index, c))
		"column":
			for r in range(9):
				cells.append(Vector2i(r, unit_index))
		"box":
			for i in range(9):
				cells.append(Cardinals.box_to_rc(unit_index, i))
	return cells

func _cell_to_index(cell: Vector2i) -> int:
	return cell.x * 9 + cell.y

func _get_unit_suffix(unit_type: String) -> String:
	if UNIT_SUFFIX_MAP.has(unit_type):
		return UNIT_SUFFIX_MAP[unit_type]
	return ""

func _get_unit_label(unit_type: String) -> String:
	if UNIT_LABEL_MAP.has(unit_type):
		return UNIT_LABEL_MAP[unit_type]
	return unit_type.capitalize()

func _get_subset_display(subset_size: int) -> String:
	if SUBSET_DISPLAY_MAP.has(subset_size):
		return SUBSET_DISPLAY_MAP[subset_size]
	return "Subset"

func _get_subset_prefix(subset_size: int) -> String:
	if SUBSET_TECHNIQUE_PREFIX_MAP.has(subset_size):
		return SUBSET_TECHNIQUE_PREFIX_MAP[subset_size]
	return ""

func _get_technique_enum(unit_type: String, subset_size: int):
	var suffix = _get_unit_suffix(unit_type)
	var prefix = _get_subset_prefix(subset_size)
	if prefix == "" or suffix == "":
		return null
	var technique_key = "HIDDEN_%s_%s" % [prefix, suffix]
	var enum_keys = Hint.HintTechnique.keys()
	var enum_index = enum_keys.find(technique_key)
	if enum_index == -1:
		return null
	return enum_index as Hint.HintTechnique
