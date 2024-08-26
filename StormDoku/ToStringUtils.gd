extends Object

class_name ToStringUtils
const BitSet = preload("res://StormDoku/Tools.gd").BitSet
const cardinals = preload("res://cardinals.gd")

# Intermediate state of the search for a representation.
class State:
    var prev: State
    var rows: BitSet
    var cols: BitSet
    var remaining: BitSet
    
    func _init(p_prev: State, p_rows: BitSet, p_cols: BitSet, p_remaining: BitSet):
        prev = p_prev
        rows = p_rows
        cols = p_cols
        remaining = p_remaining

# Converts a group of sectors into a list of cell selectors, e.g. "r23,c4,b7".
static func sector_group_to_string(sectors: BitSet) -> String:
    var sb = ""
    var last_type = -1
    var sec = sectors.get_next_set_bit(0)
    while sec >= 0:
        var type = sec / cardinals.rcbs
        if type != last_type:
            last_type = type
            if sb:
                sb += ","
            sb += 'r' if type == 0 else 'c' if type == 1 else 'b'
        sb += str((sec % cardinals.rcbs) + 1)
        sec = sectors.get_next_set_bit(sec + 1)
    return sb

# Converts a group of cells into a list of cell selectors, e.g. "r78c45,r7c68,r9c9".
static func cell_group_to_string(cells: BitSet) -> String:
    if cells == null or cells.is_empty():
        return ""

    # Greedy breadth-first search
    var this_round = []
    var next_round = []

    var to_cover = cells.cardinality()

    this_round.append(State.new(null, null, null, cells))
    while to_cover > 0:
        var next_size = 0
        for current in this_round:
            # find all rows and columns containing remaining cells
            var row_set = BitSet.new()
            var col_set = BitSet.new()
            var box_set = BitSet.new()
            var box_used = BitSet.new()
            for cell in current.remaining.get_set_bits():
                row_set.set_bit(cardinals.Rx[cell])
                col_set.set_bit(cardinals.Cy[cell])
                box_set.set_bit(cardinals.BxyN[cell])
                box_used.set_bit(cardinals.Bxy[cell])

            # triggers box point presentation if the rows/cols are more than 1 and all the
            # cells are in 1 box.
            if box_used.cardinality() == 1 and box_set.cardinality() == to_cover:
                if row_set.cardinality() > 1 and col_set.cardinality() > 1:
                    var sb = ""
                    box_state_to_string(box_set, box_used, sb)
                    return sb

            # go through all subsets of involved rows and find the largest fish
            var row_arr = row_set.get_set_bits()
            for i in range((1 << row_arr.size()) - 1, 0, -1):
                var rows = BitSet.new()
                for r in BitSet.new().from_int64(i).get_set_bits():
                    rows.set_bit(row_arr[r])
                var cols = BitSet.new()
                for c in col_set.get_set_bits():
                    if rows.get_set_bits().all(func(r): return current.remaining.get_bit(9 * r + c)):
                        cols.set_bit(c)

                # only add if no larger ones have been found this round
                var group_size = rows.cardinality() * cols.cardinality()
                if group_size > next_size:
                    next_size = group_size
                    next_round.clear()
                if group_size == next_size:
                    var remaining = current.remaining.duplicate()
                    for r in rows.get_set_bits():
                        for c in cols.get_set_bits():
                            remaining.clear_bit(9 * r + c)
                    next_round.append(State.new(current, rows, cols, remaining))

        # prepare for the next round
        this_round.clear()
        var temp = next_round
        next_round = this_round
        this_round = temp
        to_cover -= next_size

    # all cells have been covered
    var sb = ""
    state_to_string(this_round[-1], sb)
    return sb

# Traverses the chain of intermediate states recursively and adds all
# sub-groups of cells to the output string in the order from smallest to largest.
static func state_to_string(state: State, builder: String) -> void:
    if state.prev != null:
        # recursively add all previous, larger sub-groups
        state_to_string(state.prev, builder)

        # if there are previous sub-groups, add a comma
        if builder:
            builder += ','

        # add the current sub-group
        builder += 'r'
        for r in state.rows.get_set_bits():
            builder += str(r + 1)
        builder += 'c'
        for c in state.cols.get_set_bits():
            builder += str(c + 1)

static func box_state_to_string(box_set: BitSet, box_used: BitSet, builder: String) -> void:
    builder += "b"
    for r in box_used.get_set_bits():
        builder += str(r + 1)
    builder += "p"
    for r in box_set.get_set_bits():
        builder += str(r + 1)