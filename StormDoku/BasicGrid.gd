extends RefCounted
class_name BasicGrid

const CELL_BITS = Cardinals.rcbs + 2
const SOLVED_BIT = Cardinals.rcbs
const GIVEN_BIT = Cardinals.rcbs + 1

var data: Array = []

func _init():
	var num_bits = Cardinals.Length * CELL_BITS
	var num_longs = (num_bits + 63) / 64
	data = []
	for i in range(num_longs):
		data.append(0)
	for cell in range(Cardinals.Length):
		set_cell_bits(cell, ones(Cardinals.rcbs))

func ones(length: int) -> int:
	return (1 << length) - 1

func get_cell_bits(cell: int) -> int:
	var bit_pos = cell * CELL_BITS
	var idx = bit_pos / 64
	var offset = bit_pos % 64
	var bits_low = min(64 - offset, CELL_BITS)
	if bits_low == CELL_BITS:
		return (data[idx] >> offset) & ones(bits_low)
	else:
		return ((data[idx + 1] & ones(CELL_BITS - bits_low)) << bits_low) | (data[idx] >> offset)

func set_cell_bits(cell: int, bits: int) -> void:
	var bit_pos = cell * CELL_BITS
	var idx = bit_pos / 64
	var offset = bit_pos % 64
	var high_offset = offset + CELL_BITS
	if high_offset <= 64:
		data[idx] &= ~(ones(CELL_BITS) << offset)
		data[idx] |= bits << offset
	else:
		var in_lower = 64 - offset
		var in_upper = CELL_BITS - in_lower
		data[idx] &= ones(offset)
		data[idx] |= (bits & ones(in_lower)) << offset
		data[idx + 1] &= (-1 << in_upper)
		data[idx + 1] |= bits >> in_lower

func get_candidate_bits(cell: int) -> int:
	return get_cell_bits(cell) & ones(Cardinals.rcbs)

func set_solved(cell: int, digit: int, given: bool) -> void:
	set_cell_bits(cell, (1 << digit) | (1 << SOLVED_BIT) | (1 << GIVEN_BIT if given else 0))

func clear_candidate(cell: int, digit: int) -> void:
	var bit_pos = cell * CELL_BITS + digit
	data[bit_pos / 64] &= ~(1 << (bit_pos % 64))

func set_candidate(cell: int, digit: int) -> void:
	var bit_pos = cell * CELL_BITS + digit
	data[bit_pos / 64] |= 1 << (bit_pos % 64)

func is_given(cell: int) -> bool:
	var bit_pos = cell * CELL_BITS + GIVEN_BIT
	return (data[bit_pos / 64] & (1 << (bit_pos % 64))) != 0

func is_solved(cell: int) -> bool:
	var bit_pos = cell * CELL_BITS + SOLVED_BIT
	return (data[bit_pos / 64] & (1 << (bit_pos % 64))) != 0

func get_solved(cell: int) -> int:
	if is_solved(cell):
		var bits = get_cell_bits(cell) & ones(Cardinals.rcbs)
		for i in range(Cardinals.rcbs):
			if bits & (1 << i):
				return i
	return -1

func has_candidate(cell: int, digit: int) -> bool:
	var bit_pos = cell * CELL_BITS + digit
	return (data[bit_pos / 64] & (1 << (bit_pos % 64))) != 0

func bit_count(n: int) -> int:
	var count = 0
	while n:
		count += n & 1
		n >>= 1
	return count

func get_num_candidates(cell: int) -> int:
	return bit_count(get_candidate_bits(cell))

func get_num_solved() -> int:
	var count = 0
	for cell in range(Cardinals.Length):
		if is_solved(cell):
			count += 1
	return count

# Add other methods as needed...