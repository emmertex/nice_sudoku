extends SceneTree

func _init():
    var SudokuCls = load("res://sudoku_code.gd")
    var SudokuHintGeneratorCls = load("res://hint_generator.gd")
    var HintCls = load("res://hint.gd")
    var sudoku = SudokuCls.new()
    var puzzle_str = "706005004300000090000000520000009430100007008000800001820090070609000000000003009"
    sudoku.load_puzzle_from_string(puzzle_str)
    var hg = SudokuHintGeneratorCls.new()
    hg.sudoku = sudoku
    var bivalue_count := 0
    for r in range(9):
        for c in range(9):
            if sudoku.grid[r][c] != 0:
                continue
            var cand = hg._get_candidates(r, c)
            if cand.cardinality() == 2:
                bivalue_count += 1
                var d1 = cand.next_set_bit(0)
                var d2 = cand.next_set_bit(d1 + 1)
                print("bivalue ", Vector2i(r,c), " {", d1+1, "/", d2+1, "}")
    print("bivalue_count=", bivalue_count)
    # Inspect (0,5)
    var cand_05 = hg._get_candidates(0,5)
    var list_05 := []
    for d in range(9):
        if cand_05.get_bit(d): list_05.append(d+1)
    print("cands(1,6)=", list_05)
    # For digit 9, list positions per unit
    var d9 = 8
    for rr in range(9):
        var row_pos := []
        for cc in range(9):
            if sudoku.grid[rr][cc] == 0 and hg._get_candidates(rr,cc).get_bit(d9): row_pos.append(Vector2i(rr,cc))
        if row_pos.size() > 0:
            print("row ", rr, " d9 pos ", row_pos)
    for cc in range(9):
        var col_pos := []
        for rr in range(9):
            if sudoku.grid[rr][cc] == 0 and hg._get_candidates(rr,cc).get_bit(d9): col_pos.append(Vector2i(rr,cc))
        if col_pos.size() > 0:
            print("col ", cc, " d9 pos ", col_pos)
    for b in range(9):
        var box_pos := []
        for i in range(9):
            var p = Cardinals.box_to_rc(b, i)
            if sudoku.grid[p.x][p.y] == 0 and hg._get_candidates(p.x,p.y).get_bit(d9): box_pos.append(p)
        if box_pos.size() > 0:
            print("box ", b, " d9 pos ", box_pos)
    var hints = hg.get_hints()
    for h in hints:
        if h.technique == HintCls.HintTechnique.XY_CHAIN:
            print("XY-CHAIN: elim_nums=", h.elim_numbers, " elim_cells=", h.elim_cells, " cells=", h.cells)
    quit()

