extends RefCounted

const cardinals = preload("res://cardinals.gd")
# Constants
const numb = 9
const Length = 81
const secs = 27

# Static variables
var Slist = [0, 9, 45, 129, 255, 381, 465, 501, 510]
var Flist = [8, 44, 128, 254, 380, 464, 500, 509, 510]

var comboset = []
var comboset2 = []

var peer = []
var peer2 = []
var CellSec = []
var RCBnum = []
var peerRCB = []

var SectorRCB = []
var combosetS = []
var secover = []

var pairs = BitSet.new()
var trips = BitSet.new()

var boxpairs = BitSet.new()
var boxtrips = BitSet.new()

func _ready():
    initialize()
    pairs_trips()
    box_pairs_trips()
    peers()
    cell_secs()
    lookup_sector_rbc()
    rcb_peers()

func initialize():
    comboset.resize(numb)
    comboset2.resize(numb)
    
    for i in range(numb):
        comboset[i] = BitSet.new()
        comboset2[i] = BitSet.new()
        
    SectorRCB.resize(secs)
    combosetS.resize(secs)
    for i in range(secs):
        SectorRCB[i] = []
        combosetS[i] = []
        SectorRCB[i].resize(numb)
        combosetS[i].resize(numb)
        for j in range(numb):
            SectorRCB[i][j] = BitSet.new()
            combosetS[i][j] = BitSet.new()

    var vx = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    var count = 0

    for m in range(1, 10):
        while true:
            for l in range(m):
                comboset[count].set_bit(vx[l] + 1)
                comboset2[count].set_bit(vx[l])
                
                for xn in range(9):
                    combosetS[xn][count].set_bit(Cardinals.Rset[xn][vx[l]])
                    combosetS[xn + 9][count].set_bit(Cardinals.Cset[xn][vx[l]])
                    combosetS[xn + 18][count].set_bit(Cardinals.Bset[xn][vx[l]])
            
            count += 1
            if not next_combination(vx, 9, m):
                break

func next_combination(v, n, k):
    if v[0] == (n - k) or k == 0:
        return false

    var i = k - 1
    while i > 0 and v[i] == n - k + i:
        i -= 1

    v[i] += 1

    for j in range(i, k - 1):
        v[j + 1] = v[j] + 1

    return true

func peers():
    peer.resize(Length)
    peer2.resize(Length)
    
    for i in range(Length):
        peer[i] = BitSet.new()
        peer2[i] = []
        
    for i in range(Length):
        var z = 0
        for j in range(Length):
            if i != j and (Cardinals.Rx[i] == Cardinals.Rx[j] or Cardinals.Cy[i] == Cardinals.Cy[j] or Cardinals.Bxy[i] == Cardinals.Bxy[j]):
                peer[i].set_bit(j)
                peer2[i].append(j)
                z += 1

func cell_secs():
    CellSec.resize(Length)
    
    for i in range(Length):
        CellSec[i] = BitSet.new()
        CellSec[i].set_bit(Cardinals.Rsec[Cardinals.Rx[i]])
        CellSec[i].set_bit(Cardinals.Csec[Cardinals.Cy[i]])
        CellSec[i].set_bit(Cardinals.Bsec[Cardinals.Bxy[i]])

func lookup_sector_rbc():
    for i in range(9):
        for r in range(511):
            for n in range(9):
                if comboset2[r].get_bit(n):
                    SectorRCB[i][r].set_bit(Cardinals.Rset[i][n])
                    SectorRCB[i + 9][r].set_bit(Cardinals.Cset[i][n])
                    SectorRCB[i + 18][r].set_bit(Cardinals.Bset[i][n])

func rcb_peers():
    RCBnum.resize(secs)
    peerRCB.resize(secs)
    
    for i in range(secs):
        RCBnum[i] = BitSet.new()
        peerRCB[i] = BitSet.new()
    
    for j in range(Length):
        RCBnum[Cardinals.Rx[j]].set_bit(j)
        RCBnum[Cardinals.Cy[j] + 9].set_bit(j)
        RCBnum[Cardinals.Bxy[j] + 18].set_bit(j)
        
        peerRCB[Cardinals.Rx[j]].set_bit(Cardinals.Cy[j] + 9)
        peerRCB[Cardinals.Rx[j]].set_bit(Cardinals.Bxy[j] + 18)
        
        peerRCB[Cardinals.Cy[j] + 9].set_bit(Cardinals.Rx[j])
        peerRCB[Cardinals.Cy[j] + 9].set_bit(Cardinals.Bxy[j] + 18)
        
        peerRCB[Cardinals.Bxy[j] + 18].set_bit(Cardinals.Cy[j] + 9)
        peerRCB[Cardinals.Bxy[j] + 18].set_bit(Cardinals.Rx[j])

func pairs_trips():
    pairs.from_ints([9, 10, 17, 30, 31, 35, 42, 43, 44])
    trips.from_ints([45, 109, 128])

func box_pairs_trips():
    boxpairs.from_ints([9, 10, 11, 14, 17, 19, 22, 26, 29, 30, 31, 32, 35, 37, 41, 42, 43, 44])
    boxtrips.from_ints([45, 60, 86, 105, 109, 128])

func common_sectors(cells):
    var common_sectors = BitSet.new()
    common_sectors.set_range(0, secs)
    for cell in cells.get_true_bits():
        common_sectors.and_with(CellSec[cell])
    return common_sectors

func get_peers(sbrc, digit, cells):
    var peers = sbrc.digitcell[digit].duplicate()
    peers.subtract(cells)
    for r in cells.get_true_bits():
        peers.and_with(peer[r])
    return peers

func get_peers2(sbrc, a, cells):
    var peers = BitSet.new()
    for r in sbrc.digitcell[a].get_true_bits():
        if intersection(peer[r], cells).equals(cells) and not cells.get_bit(r):
            peers.set_bit(r)
    return peers

func get_location(input):
    return "r%dc%d" % [Cardinals.Rx[input] + 1, Cardinals.Cy[input] + 1]

func get_multi_locals(input):
    return ToStringUtils.cell_group_to_string(input)

func get_digits(input):
    var result = ""
    for r in input.get_true_bits():
        result += str(r + 1)
    return result

func comboset_lookup(N, set):
    var x = BitSet.new()
    for R in range(Slist[N], Flist[N] + 1):
        if comboset2[R].equals(set):
            x.set_bit(R)
    return x

func grabber(sbrc, digit, sector_offset, sectors):
    var sets = BitSet.new()
    for sec in sectors.get_true_bits():
        sets.or_with(sbrc.DigitRCB[sec + sector_offset][digit])
    return sets

func intersection(set1, set2):
    var result = set1.duplicate()
    result.and_with(set2)
    return result

class BitSet:
    var words: Array = []
    const BITS_PER_WORD = 64
    const ADDRESS_BITS_PER_WORD = 6

    func _init(nbits = 64):
        words.resize((nbits - 1) / BITS_PER_WORD + 1)
        for i in range(words.size()):
            words[i] = 0  # Initialize all words to 0

    func set_bit(bitIndex):
        if bitIndex < 0:
            push_error("BitSet: bitIndex < 0")
            return
        var wordIndex = bitIndex >> ADDRESS_BITS_PER_WORD
        if wordIndex >= words.size():
            words.resize(wordIndex + 1)
            for i in range(words.size()):
                if words[i] == null:
                    words[i] = 0
        words[wordIndex] |= (1 << (bitIndex & (BITS_PER_WORD - 1)))

    func clear_bit(bitIndex):
        if bitIndex < 0:
            push_error("BitSet: bitIndex < 0")
            return
        var wordIndex = bitIndex >> ADDRESS_BITS_PER_WORD
        if wordIndex < words.size():
            words[wordIndex] &= ~(1 << (bitIndex & (BITS_PER_WORD - 1)))

    func get_bit(bitIndex):
        if bitIndex < 0:
            push_error("BitSet: bitIndex < 0")
            return false
        var wordIndex = bitIndex >> ADDRESS_BITS_PER_WORD
        return wordIndex < words.size() and (words[wordIndex] & (1 << (bitIndex & (BITS_PER_WORD - 1)))) != 0

    func set_range(fromIndex, toIndex, value = true):
        if fromIndex < 0 or toIndex < 0 or fromIndex > toIndex:
            push_error("BitSet: Invalid range")
            return
        
        var startWordIndex = fromIndex >> ADDRESS_BITS_PER_WORD
        var endWordIndex = toIndex >> ADDRESS_BITS_PER_WORD
        
        if value:
            if endWordIndex >= words.size():
                words.resize(endWordIndex + 1)
            
            var firstWordMask = 0xFFFFFFFFFFFFFFFF << (fromIndex & (BITS_PER_WORD - 1))
            var lastWordMask = 0xFFFFFFFFFFFFFFFF >> (BITS_PER_WORD - (toIndex & (BITS_PER_WORD - 1)) - 1)
            
            if startWordIndex == endWordIndex:
                words[startWordIndex] |= (firstWordMask & lastWordMask)
            else:
                words[startWordIndex] |= firstWordMask
                for i in range(startWordIndex + 1, endWordIndex):
                    words[i] = 0xFFFFFFFFFFFFFFFF
                words[endWordIndex] |= lastWordMask
        else:
            var firstWordMask = ~(0xFFFFFFFFFFFFFFFF << (fromIndex & (BITS_PER_WORD - 1)))
            var lastWordMask = 0xFFFFFFFFFFFFFFFF << (toIndex & (BITS_PER_WORD - 1))
            
            if startWordIndex == endWordIndex:
                words[startWordIndex] &= (firstWordMask | lastWordMask)
            else:
                words[startWordIndex] &= firstWordMask
                for i in range(startWordIndex + 1, endWordIndex):
                    words[i] = 0
                if endWordIndex < words.size():
                    words[endWordIndex] &= lastWordMask

    func and_with(set):
        var wordsInCommon = min(words.size(), set.words.size())
        for i in range(wordsInCommon):
            words[i] &= set.words[i]
        for i in range(wordsInCommon, words.size()):
            words[i] = 0

    func or_with(set):
        if set.words.size() > words.size():
            words.resize(set.words.size())
        for i in range(set.words.size()):
            words[i] |= set.words[i]

    func xor_with(set):
        if set.words.size() > words.size():
            words.resize(set.words.size())
        for i in range(set.words.size()):
            words[i] ^= set.words[i]

    func subtract(set):
        var wordsInCommon = min(words.size(), set.words.size())
        for i in range(wordsInCommon):
            words[i] &= ~set.words[i]

    func duplicate():
        var new_set = get_script().new()
        new_set.words = words.duplicate()
        return new_set

    func equals(set):
        if words.size() != set.words.size():
            return false
        for i in range(words.size()):
            if words[i] != set.words[i]:
                return false
        return true

    func get_true_bits():
        var result = []
        for i in range(words.size() * BITS_PER_WORD):
            if get_bit(i):
                result.append(i)
        return result

    func from_ints(int_list):
        for i in int_list:
            set_bit(i)

    func clear():
        for i in range(words.size()):
            words[i] = 0

    func cardinality():
        var sum = 0
        for word in words:
            sum += word.bit_count()
        return sum

    func bs_to_string() -> String:
        var result = "{"
        var first = true
        for i in range(words.size() * BITS_PER_WORD):
            if get_bit(i):
                if not first:
                    result += ", "
                result += str(i)
                first = false
        result += "}"
        return result

    func next_set_bit(fromIndex):
        var u = fromIndex >> ADDRESS_BITS_PER_WORD
        if u >= words.size():
            return -1

        var word = words[u] & (0xFFFFFFFFFFFFFFFF << (fromIndex & (BITS_PER_WORD - 1)))

        while true:
            if word != 0:
                return (u * BITS_PER_WORD) + find_least_significant_bit(word)
            u += 1
            if u == words.size():
                return -1
            word = words[u]

    func find_least_significant_bit(n):
        if n == 0:
            return -1
        var position = 0
        while (n & 1) == 0:
            n >>= 1
            position += 1
        return position