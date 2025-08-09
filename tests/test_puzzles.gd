extends SceneTree

var _failed: int = 0
const SudokuHintGenerator = preload("res://hint_generator.gd")

func _init():
	if Engine.is_editor_hint():
		return
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
	if not test_hidden_single(): _failed += 1
	if not test_naked_single(): _failed += 1
	if not test_hidden_pair(): _failed += 1
	if not test_naked_pair(): _failed += 1
	if not test_hidden_triple(): _failed += 1
	if not test_naked_triple(): _failed += 1
	if not test_hidden_quad(): _failed += 1
	if not test_naked_quad(): _failed += 1
	if not test_pointing_candidates(): _failed += 1
	if not test_claiming_candidates(): _failed += 1
	if not test_x_wing(): _failed += 1
	if not test_skyscraper(): _failed += 1
	if not test_string_kite(): _failed += 1
	if not test_remote_pair(): _failed += 1
	if not test_xy_wing(): _failed += 1
	if not test_empty_rectangle(): _failed += 1
	if not test_w_wing(): _failed += 1
	if not test_s_wing(): _failed += 1
	if not test_m2_wing(): _failed += 1
	if not test_m3_wing(): _failed += 1
	if not test_l1_wing(): _failed += 1
	if not test_l2_wing(): _failed += 1
	if not test_l3_wing(): _failed += 1
	if not test_h2_wing(): _failed += 1
	if not test_h3_wing(): _failed += 1
	if not test_shared_cell(): _failed += 1
	if not test_xy_wing_2(): _failed += 1
	if not test_als_xy_rule(): _failed += 1
	if not test_als_chain(): _failed += 1
	if not test_dds(): _failed += 1
	if not test_xyz_wing(): _failed += 1
	if not test_wxyz_wing(): _failed += 1
	if not test_wxyz_wing_double(): _failed += 1
	if not test_xy_ring(): _failed += 1
	if not test_als_xy_rule_2(): _failed += 1
	if not test_als_chain_2(): _failed += 1
	if not test_skyscraper_2_sashimi(): _failed += 1
	if not test_2_sashimi_swordfish(): _failed += 1
	if not test_multi_sashimi_xwing(): _failed += 1
	print("All tests completed. Failed: %d" % _failed)
	return _failed

func _solve_and_report(sudoku, test_name) -> bool:
	var hint_generator = SudokuHintGenerator.new()
	hint_generator.sudoku = sudoku

	var applied_hint = true
	var iteration_limit = 100 # safety break
	var iterations = 0
	while applied_hint and iterations < iteration_limit:
		iterations += 1
		applied_hint = false
		if sudoku.sbrc_grid.is_complete():
			break

		var hints = hint_generator.get_hints()
		if hints.is_empty():
			break

		# Prioritize placement hints
		var best_hint = _find_best_hint(hints)

		if best_hint:
			if _apply_hint(sudoku, best_hint):
				applied_hint = true

	if sudoku.sbrc_grid.is_complete():
		print("%s: Solved in %d iterations" % [test_name, iterations])
	else:
		print("%s: Failed after %d iterations" % [test_name, iterations])

	return sudoku.sbrc_grid.is_complete()

func _find_best_hint(hints: Array[Hint]) -> Hint:
	# Priority 1: Single Candidate / Hidden Single (direct placement)
	for hint in hints:
		if hint.technique == Hint.HintTechnique.SINGLE_CANDIDATE or hint.technique == Hint.HintTechnique.HIDDEN_SINGLE:
			if hint.cells.size() == 1 and hint.numbers.size() == 1:
				return hint

	# Priority 2: Any other hint that provides eliminations
	for hint in hints:
		if not hint.elim_cells.is_empty():
			return hint

	return null

func _apply_hint(sudoku: Sudoku, hint: Hint) -> bool:
	# Case 1: Placement Hint
	if hint.cells.size() == 1 and hint.numbers.size() == 1 and hint.elim_cells.is_empty():
		var cell = hint.cells[0]
		var num = hint.numbers[0]
		if sudoku.grid[cell.x][cell.y] == 0:
			sudoku.set_number(cell.x, cell.y, num)
			return true

	# Case 2: Elimination Hint
	if not hint.elim_cells.is_empty() and not hint.elim_numbers.is_empty():
		var changed = false
		for cell in hint.elim_cells:
			for num in hint.elim_numbers:
				if not sudoku.has_exclude_mark(cell.x, cell.y, num):
					sudoku.set_exclude_mark(cell.x, cell.y, num, true)
					changed = true
		if changed:
			sudoku.sbrc_grid.update_grid(sudoku.grid) # Re-evaluate candidates
			# After updating, we need to manually remove the excluded ones
			# because update_grid doesn't know about exclude_bits
			for r in range(9):
				for c in range(9):
					var bits_to_exclude = sudoku.exclude_bits[r][c]
					if bits_to_exclude > 0:
						sudoku.sbrc_grid.candidates[r][c].data[0] &= ~bits_to_exclude
			return true

	return false

func test_hidden_single() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "............6..49194..8..53..142...6.5.....8.7...963..43..7..25875..3............"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Hidden Single: r6c4 = 5 & r19c4,r4c6 <>5
	return _solve_and_report(sudoku, "Hidden Single")

func test_naked_single() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "............6..49194..8..53..142...6.5.....8.7...963..43..7..25875..3............"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Naked Single: r4c8 = 7 & r5C79,r4c6,r9c8 <> 7
	return _solve_and_report(sudoku, "Naked Single")

func test_hidden_pair() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..94815..5.8...........689.32...4.8.87.132.4..9.8....2.8721........48..1..2679..8"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Hidden Pair: 2,7 in r8c78 => r8c78<>3, r8c78<>6, r8c7<>9, r8c8<>5
	return _solve_and_report(sudoku, "Hidden Pair")

func test_naked_pair() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = ".7....254345927618862...73929....863.56.3..27738..2.45.17...592.832.547152....386"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Naked Pair: 1,4 in r4c36 => r4c45<>1, r4c45<>4
	return _solve_and_report(sudoku, "Naked Pair")

func test_hidden_triple() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "......89.68935.47.9781...6951........43596........95.....9876337.24.89...9..3..."
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Hidden Triple: 6,7,8 in r569c1 => r56c1<>2, r9c1<>1, r9c1<>5
	return _solve_and_report(sudoku, "Hidden Triple")

func test_naked_triple() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = ".98.4.563.328.5914..53..278276.8435..8.5....7.5....82682...3..55634.178...7.58.3."
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Naked Triple: 1,7,9 in r46c4,r6c6 => r56c5<>1, r5c56,r6c5<>9, r6c5<>7
	return _solve_and_report(sudoku, "Naked Triple")

func test_hidden_quad() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "4.587...29286.41.7.....2....53....1...158.2...9....57.5..968321.....57.61..7234.5"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Hidden Quadruple: 4,5,8,9 in r3c5789 => r3c5<>1, r3c589<>3, r3c78<>6
	return _solve_and_report(sudoku, "Hidden Quad")

func test_naked_quad() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "4.587...29286.41.7.....2....53....1...158.2...9....57.5..968321.....57.61..7234.5"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Naked Quadruple: 1,3,6,7 in r3c1234 => r3c5<>1, r3c589<>3, r3c78<>6
	return _solve_and_report(sudoku, "Naked Quad")

func test_pointing_candidates() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "9..74......269.7.......2.9619..265745......8272.4...1365.2..1.9..196.8.5..9513.67"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Locked Candidates Type 1 (Pointing): 3 in b2 => r3c1237<>3
	return _solve_and_report(sudoku, "Pointing Candidates")

func test_claiming_candidates() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "......46.936.415..467.1329951238.6.437169582.6.547931.894.56...75..6.9.6.4.....5"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Locked Candidates Type 2 (Claiming): 3 in r9 => r8c4<>3
	return _solve_and_report(sudoku, "Claiming Candidates")

func test_x_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..47.5...29....15..5891....52.49861....5.1...9.1.3..85..2856931..9...546..51498.."
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: (7) (r2c3 = r2c9) - (r4c9 = r4c3) => r5c3 <> 7
	# Solve: (7) (r2c9 = r2c3) - (r4c3 = r4c9) => r359c9 <> 7
	# Solve: (7) (r4c3 = r4c9) - (r2c9 = r2c3) => r5c3 <> 7
	# Solve: (7) (r4c9 = r4c3) - (r23 = r2c9)  => r359c9 <> 7
	return _solve_and_report(sudoku, "X-Wing")

func test_skyscraper() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..47.5...29....15..5891....52.49861....5.1...9.1.3..85..2856931..9...546..5149872"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: (6) (r5c3 = r2c3) - (r3c4 = r6c4) => r6c2,r5c5 <> 6
	# Solve: (6) (r6c4 = r3c4) - (r2c3 = r5c3) => r6c2,r5c5 <> 6
	return _solve_and_report(sudoku, "Skyscraper")

func test_string_kite() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..47.5...29....15..5891....52.49861....5.1...9.1.3..85..2856931..9...546..5149872"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: (6) (r2c3 = r5c3) - (r6c2 = r6c4) => r2c4 <> 6
	# Solve: (6) (r6c4 = r6c2) - (r5c3 = r2c3 ) => r2c4 <> 6
	return _solve_and_report(sudoku, "String Kite")

func test_remote_pair() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "16.3.825.83.256..152.91.3682567931849714856324836219753958.2.1661253.8..748169523"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Remote Pair: (7=4)(r2c7) - (4=7)(r7c7) - (7=4)(r7c5) -(4=7)(r1c5)  => r1c9 <> 7
	return _solve_and_report(sudoku, "Remote Pair")

func test_xy_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "31...2958629538471..81.9623..3.9781...18.359.89..1536.736981245142356789985724136"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: XY-Wing: (7=6)r5c2 - (6=4)r5c5 - (4=7)r3c5 => r3c2<>7
	return _solve_and_report(sudoku, "XY-Wing")

func test_empty_rectangle() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "5.1..3.....7..415..89.15.6..15..7346.2364157.67435....15643.78..925.......81....5"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Empty Rectangle: (9) (r6c789 = r56c9) - (r7c9 = r7c6) => r6c6 <> 9
	return _solve_and_report(sudoku, "Empty Rectangle")

func test_w_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = ".2...7..6.35641..7.6782...1......7....37.....679412..831.974..5.98.56.7375..839.."
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: W - Wing: (4=2)r8c1 - (2)(r7c3 = r7c78) - (2=4)r9c9 => r9c3,r8c7 <> 4
	return _solve_and_report(sudoku, "W-Wing")

func test_s_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..8.4....2..9..45...9..5..7824519...976382541...47698239265.....85.23.......9.235"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: S-wing: (4)(r9c6 = r7c6) - (4=8)r7c9 - (8)(r2c9 = r2c6) => r9c6 <> 8
	return _solve_and_report(sudoku, "S-Wing")

func test_m2_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "...67..242..4....1..4512..874.3..269..27..485..82.43178579361424..127856.2.845793"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: M(2)-Wing: (1=8)r4c6-(8)r1c6=(8-1)r1c2=(1)r5c2 => r4c3,r5c6 <> 1
	return _solve_and_report(sudoku, "M(2)-Wing")

func test_m3_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = ".5....964467915283928364175.42.........4...27.7...63417.6.534.2...6..7..21.7....."
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: M(3)-Wing: (1)r7c4=(1-2)r8c6=(2)r1c6-(2=8)r1c4 => r7c4 <> 8
	return _solve_and_report(sudoku, "M(3)-Wing")

func test_l1_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "000382000030000080708000523340096050900050006000103000020608095006000400503070061"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: L(1)-Wing: (2)(r46c9=r8c9-r9c7=r9c4-r8c5=r6c5) => r6c7 <> 2
	return _solve_and_report(sudoku, "L(1)-Wing")

func test_l2_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "3.2...4.565.....914...57623..32.41...21.8..4.7465192381.46....2.3.....64.65...317"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: L(2)- Wing:(7)(r8c4 = r5c4) - (3)(r5c4 = r5c6) - (3)(r7c6 = r7c5) => r7c5 <>7
	return _solve_and_report(sudoku, "L(2)-Wing")

func test_l3_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = ".2...7..6.35641..7.6782...1......7....37.....679412..831.974..5.98.56.7375..839.."
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: L(3)-Wing: (1)r8c7=(1-6)r9c8=(6-4)r9c3=(4)r8c1 => r8c7 <> 4
	return _solve_and_report(sudoku, "L(3)-Wing")

func test_h2_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = ".2...7..6.35641..7.6782...1......7....37.....679412..831.974..5.98.56.7375..839.."
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: H(2)-Wing: (3)r3c8=(3)r3c7-(3=5)r6c7-(5=3)r6c8 => r14c8 <> 3
	return _solve_and_report(sudoku, "H(2)-Wing")

func test_h3_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "3.2...4.565.....914...57623..32.41...21.8..4.7465192381.46....2.3.....64.65...317"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: H(3)-Wing: (3)r7c5=(3)r7c6-(3=6)r5c6-(6=7)r4c5 => r7c5 <> 7
	return _solve_and_report(sudoku, "H(3)-Wing")

func test_shared_cell() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "517300629300001478804607351709160040140000067600470190270800936900700584480000712"
	sudoku.load_puzzle_from_string(puzzle_str)
	return _solve_and_report(sudoku, "Shared Cell")

func test_xy_wing_2() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "31...2958629538471..81.9623..3.9781...18.359.89..1536.736981245142356789985724136"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: XY - Wing: A=r5c25 {467}, B=r6c3 {47}, X=7, Z=4 => r5c1,r6c4<>4
	return _solve_and_report(sudoku, "XY-Wing 2")

func test_als_xy_rule() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "317289645569314827248756913.2.9.7...9...2.7.4.7.6..2..4..86237.73249..86....734.2"
	sudoku.load_puzzle_from_string(puzzle_str)
	return _solve_and_report(sudoku, "ALS-XY Rule")

func test_als_chain() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..761.2..263475.........67.3....1789.....7...75.8.....685....271327.64..479.2...."
	sudoku.load_puzzle_from_string(puzzle_str)
	return _solve_and_report(sudoku, "ALS-Chain")

func test_dds() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "7.6..5..43......9.......52......943.1....7..8...8....182..9..7.6.9...........3.."
	sudoku.load_puzzle_from_string(puzzle_str)
	return _solve_and_report(sudoku, "DDS")

func test_xyz_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "957834621412.....7863172459146....75378516942295..71..5347912..681...794729..8513"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: XYZ - Wing: A=r4c46 {239}, B=r8c4 {23}, X=2, Z=3 => r6c4<>3
	return _solve_and_report(sudoku, "XYZ-Wing")

func test_wxyz_wing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "31...2958629538471..81.9623..3.9781...18.359.89..1536.736981245142356789985724136"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: WXYZ Wing: A=r5c125 {2467}, B=r5c1,r6c3 {247}, X=7, Z=2 => r4c1,r5c9<>2
	return _solve_and_report(sudoku, "WXYZ-Wing")

func test_wxyz_wing_double() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..1.5...883.146.57.5798..4.5......8...6..5.....461.7.5..8..15791.35..862.95.6.314"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: WXYZ - Wing: A=r3c1 {26}, B=r79c1,r8c2 {2467}, X=2,6, Z:2,6 => r1c1<>6, r156c1<>2, r7c2<>4
	return _solve_and_report(sudoku, "WXYZ-Wing Double")

func test_xy_ring() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..761.2..263475.........67.3....1789.....7...75.8.....685....271327.64..479.2...."
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: XY - Ring: A=r28c8 {159}, B=r28c9 {158}, X=1,5 z:1,5 => r8c5,r9c789<>5, r2c7<>1, r9c9<>8
	return _solve_and_report(sudoku, "XY-Ring")

func test_als_xy_rule_2() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "317289645569314827248756913.2.9.7...9...2.7.4.7.6..2..4..86237.73249..86....734.2"
	sudoku.load_puzzle_from_string(puzzle_str)
	return _solve_and_report(sudoku, "ALS-XY Rule 2")

func test_als_chain_2() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..761.2..263475.........67.3....1789.....7...75.8.....685....271327.64..479.2...."
	sudoku.load_puzzle_from_string(puzzle_str)
	return _solve_and_report(sudoku, "ALS-Chain 2")

func test_skyscraper_2_sashimi() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..47.5...29....15..5891....52.49861....5.1...9.1.3..85..2856931..9...546..5149872"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Sashimi X-Wing: 6 c34 r25 fr6c4 => r5c5 <>6
	# Solve: Sashimi X-Wing: 6 c34 r26 fr5c3 => r6c2<>6
	# Result: Siamese Sashimi X-Wing: 6 c34 r25/r26 fr6c4 fr5c3 => r5c5,r6c2<>6
	return _solve_and_report(sudoku, "Skyscraper 2 Sashimi")

func test_2_sashimi_swordfish() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = "..47.5...29....15..5891....52.49861....5.1...9.1.3..85..2856931..9...546..5149872"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Sashimi Swordfish: 7 r247 c239 fr7c1 => r8c2<>7
	# Solve: Sashimi Swordfish: 7 r247 c139 fr7c2 => r8c1<>7
	# Result: Siamese Sashimi Swordfish: 7 r247 c139/c239 fr7c2 fr7c1 => r8c12<>7
	return _solve_and_report(sudoku, "2 Sashimi Swordfish")

func test_multi_sashimi_xwing() -> bool:
	var Sudoku = load("res://sudoku_code.gd")
	var sudoku = Sudoku.new()
	var puzzle_str = ".126.4.3543..5.2615.6.1...462.7.154315.43.62.3.45261..865.4.31.2431.5..6..1.6.452"
	sudoku.load_puzzle_from_string(puzzle_str)
	# Solve: Sashimi X-Wing: 8 r24 c35 fr2c4 fr2c6 => r1c5<>8
	# Solve: Sashimi X-Wing: 9 r24 c35 fr2c4 fr2c6 => r1c5<>9
	# Result: Muti Sashimi X-Wing: 8,9 r24 c35 fr2c4 fr2c6 => r1c5<>8,9
	return _solve_and_report(sudoku, "Multi Sashimi X-Wing")