class_name BitSet
extends RefCounted

var data: Array[int] = []
var size: int

func _init(bit_size: int = 81):
    size = bit_size
    var array_size = (size + 31) / 32
    data.resize(array_size)
    for i in range(array_size):
        data[i] = 0

func set(bit: int):
    if bit < 0 or bit >= size:
        return
    var index = bit / 32
    var offset = bit % 32
    data[index] |= (1 << offset)

func clear(bit: int):
    if bit < 0 or bit >= size:
        return
    var index = bit / 32
    var offset = bit % 32
    data[index] &= ~(1 << offset)

func get(bit: int) -> bool:
    if bit < 0 or bit >= size:
        return false
    var index = bit / 32
    var offset = bit % 32
    return (data[index] & (1 << offset)) != 0

func cardinality() -> int:
    var count = 0
    for i in range(data.size()):
        count += _bit_count(data[i])
    return count

func _bit_count(value: int) -> int:
    var count = 0
    while value != 0:
        count += value & 1
        value = value >> 1
    return count

func clear_all():
    for i in range(data.size()):
        data[i] = 0

func set_all():
    for i in range(data.size()):
        data[i] = 0xFFFFFFFF
    # Clear bits beyond size
    var last_index = size / 32
    var last_offset = size % 32
    if last_offset > 0:
        data[last_index] &= (1 << last_offset) - 1

func intersects(other: BitSet) -> bool:
    for i in range(min(data.size(), other.data.size())):
        if (data[i] & other.data[i]) != 0:
            return true
    return false

func union(other: BitSet) -> BitSet:
    var result = BitSet.new(size)
    for i in range(data.size()):
        result.data[i] = data[i] | other.data[i]
    return result

func intersection(other: BitSet) -> BitSet:
    var result = BitSet.new(size)
    for i in range(data.size()):
        result.data[i] = data[i] & other.data[i]
    return result

func difference(other: BitSet) -> BitSet:
    var result = BitSet.new(size)
    for i in range(data.size()):
        result.data[i] = data[i] & ~other.data[i]
    return result

func is_empty() -> bool:
    for i in range(data.size()):
        if data[i] != 0:
            return false
    return true

func next_set_bit(from_index: int = 0) -> int:
    for i in range(from_index, size):
        if get(i):
            return i
    return -1

func to_string() -> String:
    var result = "BitSet["
    for i in range(size):
        if get(i):
            result += str(i) + ","
    if result.ends_with(","):
        result = result.substr(0, result.length() - 1)
    result += "]"
    return result

func clone() -> BitSet:
    var result = BitSet.new(size)
    for i in range(data.size()):
        result.data[i] = data[i]
    return result 