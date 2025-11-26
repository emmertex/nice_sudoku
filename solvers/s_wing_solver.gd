extends RefCounted
class_name SWingSolver

func name() -> String:
	return "S-Wing Solver"

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	var sudoku = generator.sudoku
	var linkset = generator.linkset

	# Simplified SplitWings implementation based on the Java version
	# This focuses on the core logic while being more maintainable

	for g in range(9):  # g represents digit (0-8)
		# Look for BIVALUE cells for this digit
		for gLink in linkset[g][StrongLink.BIVALVE]:
			# Find cells that see both ends of the bivalue cell
			var bivalue_cell_idx = gLink.activeCells.next_set_bit()
			if bivalue_cell_idx == -1:
				continue
			var bivalue_r = bivalue_cell_idx / 9
			var bivalue_c = bivalue_cell_idx % 9

			# Get the two candidates for this bivalue cell
			var cand = generator._get_candidates(bivalue_r, bivalue_c)
			var digit1 = g  # This is digit g
			var digit2 = cand.next_set_bit(0)
			if digit2 == digit1:
				digit2 = cand.next_set_bit(digit1 + 1)

			# Look for strong links in digit2
			for hLink in linkset[digit2][StrongLink.BILOCAL]:
				var cell1_idx = hLink.activeCells.next_set_bit()
				var cell2_idx = hLink.linkedCells.next_set_bit()
				if cell1_idx == -1 or cell2_idx == -1:
					continue

				# Check if the bivalue cell sees one of the endpoints
				var sees_cell1 = generator._are_peers(Vector2i(bivalue_r, bivalue_c), Vector2i(cell1_idx / 9, cell1_idx % 9))
				var sees_cell2 = generator._are_peers(Vector2i(bivalue_r, bivalue_c), Vector2i(cell2_idx / 9, cell2_idx % 9))

				if not (sees_cell1 or sees_cell2):
					continue

				var endpoint = Vector2i(cell1_idx / 9, cell1_idx % 9) if sees_cell1 else Vector2i(cell2_idx / 9, cell2_idx % 9)
				var other_end = Vector2i(cell2_idx / 9, cell2_idx % 9) if sees_cell1 else Vector2i(cell1_idx / 9, cell1_idx % 9)

				# Find cells that see both endpoints of the strong link
				var elim_cells = []
				for r in range(9):
					for c in range(9):
						if sudoku.grid[r][c] != 0:
							continue
						var cell = Vector2i(r, c)
						if cell == endpoint or cell == Vector2i(bivalue_r, bivalue_c) or cell == other_end:
							continue
						if not generator._get_candidates(r, c).get_bit(digit2):
							continue
						if generator._are_peers(cell, other_end) and generator._are_peers(cell, endpoint):
							elim_cells.append(cell)

				if elim_cells.size() > 0:
					# Create the hint
					var hint = Hint.new(Hint.HintTechnique.S_WING, "")
					hint.cells.append(Vector2i(bivalue_r, bivalue_c))
					hint.cells.append(endpoint)
					hint.numbers.append(digit1 + 1)
					hint.numbers.append(digit2 + 1)
					hint.elim_cells.append_array(elim_cells)
					hint.elim_numbers.append(digit2 + 1)

					var desc = "Split-Wing: Bivalue cell %s {%d,%d} sees endpoint %s of strong link %s-%s on %d.\n\n" % [
						generator._format_cell_list([Vector2i(bivalue_r, bivalue_c)]), digit1 + 1, digit2 + 1,
						generator._format_cell_list([endpoint]),
						generator._format_cell_list([Vector2i(cell1_idx / 9, cell1_idx % 9)]),
						generator._format_cell_list([Vector2i(cell2_idx / 9, cell2_idx % 9)]), digit2 + 1
					]
					desc += "Eliminate %d from cells seeing both endpoints: %s." % [digit2 + 1, generator._format_cell_list(elim_cells)]
					hint.description = desc

					# Check for duplicates
					var exists = false
					for existing in hints:
						if existing.technique == Hint.HintTechnique.S_WING and existing.cells.has(Vector2i(bivalue_r, bivalue_c)) and existing.cells.has(endpoint):
							exists = true
							break
					if not exists:
						hints.append(hint)

# Helper function to check if two BitSets intersect
func _intersects(bitset1: BitSet, bitset2: BitSet) -> bool:
	return bitset1.intersection(bitset2).cardinality() > 0

# Helper function to format a link for description
func _format_link(link: StrongLink) -> String:
	match link.type:
		StrongLink.LinkType.BIVALUE_CELL:
			var cell_idx = link.activeCells.next_set_bit()
			var r = cell_idx / 9
			var c = cell_idx % 9
			var d1 = link.digit1 + 1
			var d2 = link.digit2 + 1
			return "(%d,%d){%d,%d}" % [r+1, c+1, d1, d2]
		StrongLink.LinkType.BILOCAL_UNIT:
			var c1_idx = link.activeCells.next_set_bit()
			var c2_idx = link.linkedCells.next_set_bit()
			var r1 = c1_idx / 9
			var c1 = c1_idx % 9
			var r2 = c2_idx / 9
			var c2 = c2_idx % 9
			var d = link.digit1 + 1
			return "(%d,%d)=(%d,%d)[%d]" % [r1+1, c1+1, r2+1, c2+1, d]
		StrongLink.LinkType.CELL_TO_GROUP:
			var cell_idx = link.activeCells.next_set_bit()
			var r = cell_idx / 9
			var c = cell_idx % 9
			var d = link.digit1 + 1
			return "(%d,%d)-group[%d]" % [r+1, c+1, d]
		StrongLink.LinkType.GROUP_TO_CELL:
			var cell_idx = link.linkedCells.next_set_bit()
			var r = cell_idx / 9
			var c = cell_idx % 9
			var d = link.digit1 + 1
			return "group-(%d,%d)[%d]" % [r+1, c+1, d]
		StrongLink.LinkType.GROUP_TO_GROUP:
			return "group-group"
		StrongLink.LinkType.ERI_MAX:
			return "ERI-MAX"
		StrongLink.LinkType.ERI_ALL:
			return "ERI-ALL"
		StrongLink.LinkType.ALS:
			return "ALS"
		_:
			return "Unknown"




