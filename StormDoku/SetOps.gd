extends Object
class_name SetOps
const BitSet = preload("res://StormDoku/Tools.gd").BitSet


static func union(a: BitSet, bs: Array) -> BitSet:
    var unionv = copy_set(a)
    for b in bs:
        unionv.or_with(b)
    return unionv

static func difference(a: BitSet, b: BitSet) -> BitSet:
    var diff = copy_set(a)
    diff.and_not(b)
    return diff

static func intersection(a: BitSet, bs: Array) -> BitSet:
    var isect = copy_set(a)
    for b in bs:
        isect.and_with(b)
    return isect

static func symmetric_difference(a: BitSet, b: BitSet) -> BitSet:
    var symm_diff = copy_set(a)
    symm_diff.xor_with(b)
    return symm_diff

static func include(item: int, a: BitSet) -> BitSet:
    var copy = copy_set(a)
    copy.BitSet.set_bit(item, true)
    return copy

static func exclude(item: int, a: BitSet) -> BitSet:
    var copy = copy_set(a)
    copy.BitSet.set_bit(item, false)
    return copy

static func is_subset_of(subset: BitSet, superset: BitSet) -> bool:
    var copy = copy_set(subset)
    copy.and_not(superset)
    return copy.is_empty()

static func copy_set(a: BitSet) -> BitSet:
    return a.duplicate()

static func from_ints(arr: Array) -> BitSet:
    var out = BitSet.new()
    for i in arr:
        out.BitSet.set_bit(i, true)
    return out

static func to_ints(set: BitSet) -> Array:
    return set.get_true_bits()

static func unions(s: Array, pm: Array) -> Array:
    var copy = BitSet.new()
    var ret = []
    ret.resize(81)

    for i in range(81):
        copy = union(s[i], [pm[i]])
        ret[i] = BitSet.new()
        ret[i] = copy
    return ret

static func create_array(n: int) -> Array:
    var out = []
    out.resize(n)
    for i in range(out.size()):
        out[i] = BitSet.new()
    return out

static func create_2d_array(m: int, n: int) -> Array:
    var out = []
    out.resize(m)
    for i in range(out.size()):
        out[i] = create_array(n)
    return out

static func get_rcc_difference(list1: Array, list2: Array) -> Array:
    var difference = list1.duplicate()
    for item in list2:
        difference.erase(item)
    return difference