extends SceneTree

func _init():
    var Sudoku = load("res://sudoku_code.gd")
    var HintGen = load("res://hint_generator.gd")
    var Hint = load("res://hint.gd")
    var args = OS.get_cmdline_args()
    if args.size() < 2:
        print("Usage: godot --headless --script res://tests/debug_print.gd <puzzle_string>")
        quit(1)
        return
    var puzzle = args[1]
    var s = Sudoku.new()
    puzzle = puzzle.replace(".", "0")
    s.load_puzzle_from_string(puzzle)
    var hg = HintGen.new()
    hg.sudoku = s
    var hints = hg.get_hints()
    var counts = {}
    for h in hints:
        var key = Hint.HintTechnique.keys()[h.technique]
        counts[key] = (counts.get(key, 0) + 1)
    for k in counts.keys():
        print(k, ": ", counts[k])
    quit(0)


