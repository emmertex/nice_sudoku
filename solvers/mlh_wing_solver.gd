extends RefCounted
class_name MLHWingSolver

var sudoku: Sudoku
var generator_ref: SudokuHintGenerator

func name() -> String:
	return "MLH Wing Solver"

func solve(generator: SudokuHintGenerator, hints: Array[Hint]) -> void:
	generator_ref = generator
	sudoku = generator.sudoku
	_find_mlh_wings(hints)

func _find_mlh_wings(hints: Array[Hint]):
	# H(3)-Wing: Pattern (a=b) - (b=c) - c = c => -a (last cell)
	# Or: Strong link on a -> Bivalue {a,b} -> Bivalue {b,c} -> Strong link on c
	# Pattern from test: (3)r7c5=(3)r7c6-(3=6)r5c6-(6=7)r4c5 => r7c5 <> 7
	
	# Collect bivalue cells
	var bivalue_cells: Array = [] # {pos: Vector2i, pair: PackedInt32Array}
	for r in range(9):
		for c in range(9):
			if sudoku.grid[r][c] != 0:
				continue
			var cand = _get_candidates(r, c)
			if cand.cardinality() == 2:
				var d1 = cand.next_set_bit(0)
				var d2 = cand.next_set_bit(d1 + 1)
				bivalue_cells.append({"pos": Vector2i(r, c), "pair": PackedInt32Array([d1, d2])})
	
	if bivalue_cells.size() < 2:
		return
	
	# Build strong links per digit
	var strong_links_per_digit: Array = [] # Array[Array] of {cell1: Vector2i, cell2: Vector2i}
	for d in range(9):
		strong_links_per_digit.append([])
		# Check rows
		for rr in range(9):
			var cells: Array[Vector2i] = []
			for cc in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr, cc).get_bit(d):
					cells.append(Vector2i(rr, cc))
			if cells.size() == 2:
				strong_links_per_digit[d].append({"cell1": cells[0], "cell2": cells[1]})
		# Check columns
		for cc in range(9):
			var cells: Array[Vector2i] = []
			for rr in range(9):
				if sudoku.grid[rr][cc] == 0 and _get_candidates(rr, cc).get_bit(d):
					cells.append(Vector2i(rr, cc))
			if cells.size() == 2:
				strong_links_per_digit[d].append({"cell1": cells[0], "cell2": cells[1]})
		# Check boxes
		for box_idx in range(9):
			var cells: Array[Vector2i] = []
			for i in range(9):
				var p = Cardinals.box_to_rc(box_idx, i)
				if sudoku.grid[p.x][p.y] == 0 and _get_candidates(p.x, p.y).get_bit(d):
					cells.append(p)
			if cells.size() == 2:
				strong_links_per_digit[d].append({"cell1": cells[0], "cell2": cells[1]})
	
	# Find H(3)-Wing patterns
	# Pattern: Strong link on digit a -> Bivalue {a,b} -> Bivalue {b,c} -> (elimination on a from cells seeing start of strong link)
	for bv1_idx in range(bivalue_cells.size()):
		var bv1 = bivalue_cells[bv1_idx]
		var a = bv1["pair"][0]
		var b = bv1["pair"][1]
		
		# Check strong links on digit a
		for link_a in strong_links_per_digit[a]:
			var start_a = link_a["cell1"]
			var end_a = link_a["cell2"]
			
			# bv1 should be connected to the strong link (be one of the endpoints or see one endpoint)
			var bv1_connects = false
			var link_end_to_use = null
			if bv1["pos"] == start_a or bv1["pos"] == end_a:
				bv1_connects = true
				link_end_to_use = end_a if bv1["pos"] == start_a else start_a
			elif _are_peers(bv1["pos"], start_a) or _are_peers(bv1["pos"], end_a):
				bv1_connects = true
				link_end_to_use = end_a if _are_peers(bv1["pos"], start_a) else start_a
			
			if not bv1_connects:
				continue
			
			# Find second bivalue cell with {b, c} where c != a
			for bv2_idx in range(bivalue_cells.size()):
				if bv2_idx == bv1_idx:
					continue
				var bv2 = bivalue_cells[bv2_idx]
				var pair2 = bv2["pair"]
				
				# Check if bv2 has b and another digit c
				if pair2.find(b) == -1:
					continue
				var c = pair2[0] if pair2[1] == b else pair2[1]
				if c == a:
					continue
				
				# bv2 should see bv1 (weak link on b)
				if not _are_peers(bv1["pos"], bv2["pos"]):
					continue
				
				# Check strong link on digit c that connects to bv2
				for link_c in strong_links_per_digit[c]:
					var start_c = link_c["cell1"]
					var end_c = link_c["cell2"]
					
					# bv2 should be connected to the strong link
					var bv2_connects = false
					if bv2["pos"] == start_c or bv2["pos"] == end_c:
						bv2_connects = true
					elif _are_peers(bv2["pos"], start_c) or _are_peers(bv2["pos"], end_c):
						bv2_connects = true
					
					if not bv2_connects:
						continue
					
					# Found H(3)-Wing! 
					# Pattern: Strong link on a -> Bivalue {a,b} -> Bivalue {b,c}
					# Elimination: If start_a is a, then chain forces c at bv2. If start_a is not a, then chain forces something else.
					# Actually, the elimination is typically on digit c from start_a, or digit a from cells seeing the chain endpoints
					# Based on test: eliminate digit c (or a) from start_a
					
					# Check if we can eliminate digit c from start_a
					var elim_digit = c
					if _get_candidates(start_a.x, start_a.y).get_bit(elim_digit):
						var elim_cells: Array[Vector2i] = [start_a]
						
						var hint = Hint.new(Hint.HintTechnique.H3_WING, "")
						hint.cells.append(start_a)
						if link_end_to_use != null:
							hint.cells.append(link_end_to_use)
						hint.cells.append(bv1["pos"])
						hint.cells.append(bv2["pos"])
						hint.numbers.append(a + 1)
						hint.numbers.append(b + 1)
						hint.numbers.append(c + 1)
						hint.elim_cells.append_array(elim_cells)
						hint.elim_numbers.append(elim_digit + 1)
						
						var desc = "H(3)-Wing: (%d)(%s = %s) - (%d=%d)(%s) - (%d=%d)(%s) => eliminate %d from %s." % [
							a + 1, _format_cell_list([start_a]), _format_cell_list([link_end_to_use]),
							a + 1, b + 1, _format_cell_list([bv1["pos"]]),
							b + 1, c + 1, _format_cell_list([bv2["pos"]]),
							elim_digit + 1, _format_cell_list([start_a])
						]
						hint.description = desc
						
						var s1 = "H(3)-Wing: Strong link on %d (%s = %s), bivalue %s {%d/%d}, bivalue %s {%d/%d}." % [
							a + 1, _format_cell_list([start_a]), _format_cell_list([link_end_to_use]),
							_format_cell_list([bv1["pos"]]), a + 1, b + 1,
							_format_cell_list([bv2["pos"]]), b + 1, c + 1
						]
						hint.add_step(s1, [start_a, bv1["pos"], bv2["pos"]])
						var s2 = "Eliminate %d from %s." % [elim_digit + 1, _format_cell_list([start_a])]
						hint.add_step(s2, [start_a], [], [], elim_cells.duplicate(), [elim_digit + 1])
						
						hints.append(hint)
						return  # Found one, can return or continue for more
					
					# Alternative: eliminate digit a from cells seeing both start_a and bv2 (if they don't share a unit)
					if not _are_peers(start_a, bv2["pos"]):
						var elim_cells2: Array[Vector2i] = []
						for r in range(9):
							for cc in range(9):
								if sudoku.grid[r][cc] != 0:
									continue
								if not _get_candidates(r, cc).get_bit(a):
									continue
								var v = Vector2i(r, cc)
								if v == start_a or v == bv2["pos"]:
									continue
								if _are_peers(v, start_a) and _are_peers(v, bv2["pos"]):
									elim_cells2.append(v)
						
						if elim_cells2.size() > 0:
							var hint = Hint.new(Hint.HintTechnique.H3_WING, "")
							hint.cells.append(start_a)
							if link_end_to_use != null:
								hint.cells.append(link_end_to_use)
							hint.cells.append(bv1["pos"])
							hint.cells.append(bv2["pos"])
							hint.numbers.append(a + 1)
							hint.numbers.append(b + 1)
							hint.numbers.append(c + 1)
							hint.elim_cells.append_array(elim_cells2)
							hint.elim_numbers.append(a + 1)
							
							var desc = "H(3)-Wing: (%d)(%s = %s) - (%d=%d)(%s) - (%d=%d)(%s) => eliminate %d from cells seeing both endpoints." % [
								a + 1, _format_cell_list([start_a]), _format_cell_list([link_end_to_use]),
								a + 1, b + 1, _format_cell_list([bv1["pos"]]),
								b + 1, c + 1, _format_cell_list([bv2["pos"]]),
								a + 1
							]
							hint.description = desc
							
							var s1 = "H(3)-Wing: Strong link on %d (%s = %s), bivalue %s {%d/%d}, bivalue %s {%d/%d}." % [
								a + 1, _format_cell_list([start_a]), _format_cell_list([link_end_to_use]),
								_format_cell_list([bv1["pos"]]), a + 1, b + 1,
								_format_cell_list([bv2["pos"]]), b + 1, c + 1
							]
							hint.add_step(s1, [start_a, bv1["pos"], bv2["pos"]])
							var s2 = "Eliminate %d from cells seeing both endpoints: %s." % [a + 1, _format_cell_list(elim_cells2)]
							hint.add_step(s2, [start_a, bv2["pos"]], [], [], elim_cells2.duplicate(), [a + 1])
							
							hints.append(hint)

func _get_candidates(r: int, c: int) -> BitSet:
	return generator_ref._get_candidates(r, c)

func _are_peers(c1: Vector2i, c2: Vector2i) -> bool:
	return generator_ref._are_peers(c1, c2)

func _format_cell_list(cells: Array[Vector2i]) -> String:
	return generator_ref._format_cell_list(cells)
