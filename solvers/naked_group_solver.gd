extends RefCounted
class_name NakedGroupSolver

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	for r in range(9):
		_find_naked_groups_in_unit(generator, hints, r, "row", 2)
		_find_naked_groups_in_unit(generator, hints, r, "row", 3)
		_find_naked_groups_in_unit(generator, hints, r, "row", 4)

	for c in range(9):
		_find_naked_groups_in_unit(generator, hints, c, "col", 2)
		_find_naked_groups_in_unit(generator, hints, c, "col", 3)
		_find_naked_groups_in_unit(generator, hints, c, "col", 4)

	for b in range(9):
		_find_naked_groups_in_unit(generator, hints, b, "box", 2)
		_find_naked_groups_in_unit(generator, hints, b, "box", 3)
		_find_naked_groups_in_unit(generator, hints, b, "box", 4)

func _find_naked_groups_in_unit(generator: SudokuHintGenerator, hints: Array[Hint], unit_index: int, unit_type: String, group_size: int) -> void:
	var unit_cells: Array[Vector2i] = []
	if unit_type == "row":
		for c in range(9):
			unit_cells.append(Vector2i(unit_index, c))
	elif unit_type == "col":
		for r in range(9):
			unit_cells.append(Vector2i(r, unit_index))
	else:
		for i in range(9):
			unit_cells.append(Cardinals.box_to_rc(unit_index, i))

	var potential_cells = []
	for cell in unit_cells:
		var cand_count = generator._get_candidates(cell.x, cell.y).cardinality()
		if cand_count > 1 and cand_count <= group_size:
			potential_cells.append(cell)

	if potential_cells.size() < group_size:
		return

	for group_indices in generator.combinations(range(potential_cells.size()), group_size):
		var group_cells = []
		for i in group_indices:
			group_cells.append(potential_cells[i])

		var union_cands = BitSet.new(9)
		for cell in group_cells:
			union_cands = union_cands.union(generator._get_candidates(cell.x, cell.y))

		if union_cands.cardinality() == group_size:
			var elim_found = false
			var hint = Hint.new(Hint.HintTechnique.NAKED_TRIPLE_ROW, "")
			hint.cells.append_array(group_cells)
			for i in range(9):
				if union_cands.get_bit(i):
					hint.numbers.append(i + 1)

			for cell_to_check in unit_cells:
				if not cell_to_check in group_cells:
					var cands_to_check = generator._get_candidates(cell_to_check.x, cell_to_check.y)
					var intersection = cands_to_check.intersection(union_cands)

					if intersection.cardinality() > 0:
						elim_found = true
						hint.elim_cells.append(cell_to_check)
						for i in range(9):
							if intersection.get_bit(i) and not (i + 1 in hint.elim_numbers):
								hint.elim_numbers.append(i + 1)

			if elim_found:
				var technique_name = "NAKED_"
				if group_size == 2:
					technique_name += "PAIR_"
				elif group_size == 3:
					technique_name += "TRIPLE_"
				elif group_size == 4:
					technique_name += "QUAD_"
				technique_name += unit_type.to_upper()

				var enum_keys = Hint.HintTechnique.keys()
				var enum_index = enum_keys.find(technique_name)
				if enum_index == -1:
					push_error("Invalid technique name generated: " + technique_name)
					continue

				var technique_enum = enum_index as Hint.HintTechnique
				hint.technique = technique_enum
				hint.description = _generate_naked_group_description(generator, hint, unit_type, unit_index)
				hint.title = hint._get_technique_title_from_enum(technique_enum)
				hints.append(hint)

func _generate_naked_group_description(generator: SudokuHintGenerator, hint: Hint, unit_type: String, unit_index: int) -> String:
	var group_type = ""
	if hint.cells.size() == 2:
		group_type = "Pair"
	elif hint.cells.size() == 3:
		group_type = "Triple"
	elif hint.cells.size() == 4:
		group_type = "Quad"

	var numbers_str = ", ".join(hint.numbers.map(func(n): return str(n)))
	var cells_str = generator._format_cell_list(hint.cells)
	var elim_numbers_str = ", ".join(hint.elim_numbers.map(func(n): return str(n)))
	var elim_cells_str = generator._format_cell_list(hint.elim_cells)
	var unit_str = "%s %d" % [unit_type.capitalize(), unit_index + 1]

	var desc = "In %s, these %d cells (%s) are the only ones that can contain the numbers %s.\n\n" % [unit_str, hint.cells.size(), cells_str, numbers_str]
	desc += "This is a Naked %s. Because these %d numbers must be placed in these %d cells, they cannot appear anywhere else in the same %s.\n\n" % [group_type, hint.cells.size(), hint.cells.size(), unit_type.capitalize()]
	desc += "Therefore, we can eliminate the number(s) %s from the following cell(s): %s." % [elim_numbers_str, elim_cells_str]
	return desc

