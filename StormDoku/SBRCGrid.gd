extends RefCounted
class_name SBRCGrid

const Cardinals = preload("res://cardinals.gd")
const BasicGrid = preload("res://StormDoku/BasicGrid.gd")
const SetOps = preload("res://StormDoku/SetOps.gd")
const BitSet = preload("res://StormDoku/Tools.gd").BitSet
const Tools = preload("res://StormDoku/Tools.gd")

var basic_grid: BasicGrid
var Ocell: BitSet
var tools: Tools
var countpm: int
var count: int
var scount: int
var sec: Array
var pm: Array
var nm: Array
var RnSector: Array
var BnR: Array
var BnC: Array
var RnB: Array
var CnB: Array
var sectorRC: Array
var DigitRCB: Array
var sectorN: Array
var digitcell: Array
var sSector: Array
var solvedCells: Array
var ComboCell: Array
var ComboSubset: Array
var ComboNum: Array
var HComboNum: Array
var ERi: Array

const Length = Cardinals.Length
const secs = Cardinals.secs
const rcbs = Cardinals.rcbs

func _init(grid: BasicGrid) -> void:
    if grid == null:
        push_error("BasicGrid is null in SBRCGrid _init")
        return

    self.basic_grid = grid
    self.tools = Tools.new()  # Initialize the tools variable
    var result = sbrc_check(grid)
    Ocell = result.Ocell
    countpm = result.countpm
    count = result.count
    scount = result.scount
    sec = result.sec
    pm = result.pm
    nm = result.nm
    RnSector = result.RnSector
    BnR = result.BnR
    BnC = result.BnC
    RnB = result.RnB
    CnB = result.CnB
    sectorRC = result.sectorRC
    DigitRCB = result.DigitRCB
    sectorN = result.sectorN
    digitcell = result.digitcell
    sSector = result.sSector
    solvedCells = result.solved_cells

    var cell_combo = initiate_cell_combo(result.Ocell, result.pm, result.sectorRC, result.RnSector, self.tools)
    ComboCell = cell_combo.ComboCell
    ComboSubset = cell_combo.ComboSubset
    ComboNum = cell_combo.ComboNum
    HComboNum = cell_combo.HComboNum

    ERi = er_intersection(result.sec, result.DigitRCB)

func sbrc_check(basic_grid: BasicGrid) -> Dictionary:
    if basic_grid == null:
        push_error("BasicGrid is null in sbrc_check")
        return {}

    var Ocell = BitSet.new()

    var countpm = 0
    var count = 0
    var scount = 0

    var sec = []
    for i in range(secs):
        sec.append([])
        for j in range(rcbs):
            sec[i].append(0)

    var nm = []
    for i in range(Length):
        nm.append(0)

    var pm = SetOps.create_array(Length)
    var RnSector = SetOps.create_2d_array(secs, rcbs)
    var BnR = SetOps.create_2d_array(rcbs, rcbs)
    var BnC = SetOps.create_2d_array(rcbs, rcbs)
    var RnB = SetOps.create_2d_array(rcbs, rcbs)
    var CnB = SetOps.create_2d_array(rcbs, rcbs)
    var sectorRC = SetOps.create_2d_array(secs, rcbs)
    var DigitRCB = SetOps.create_2d_array(secs, rcbs)
    var sectorN = SetOps.create_array(secs)
    var digitcell = SetOps.create_array(rcbs)
    var sSector = SetOps.create_array(secs)
    var solved_cells = []
    for i in range(secs):
        solved_cells.append([])
        for j in range(rcbs):
            solved_cells[i].append(-1)

    for cell in range(Length):
        var rSec = Cardinals.Rx[cell]
        var cSec = Cardinals.Cy[cell] + 9
        var bSec = Cardinals.Bxy[cell] + 18
        var solved = basic_grid.get_solved(cell)
        if solved != -1:
            scount += 1
            sSector[rSec].set_bit(cell)
            sSector[cSec].set_bit(cell)
            sSector[bSec].set_bit(cell)

            var digit = solved
            solved_cells[rSec][digit] = cell
            solved_cells[cSec][digit] = cell
            solved_cells[bSec][digit] = cell
        else:
            count += 1
            Ocell.set_bit(cell)

            for n in range(9):
                if basic_grid.has_candidate(cell, n):
                    countpm += 1

                    sec[rSec][n] += 1
                    sec[cSec][n] += 1
                    sec[bSec][n] += 1

                    RnSector[rSec][n].set_bit(Cardinals.Cy[cell])
                    RnSector[cSec][n].set_bit(Cardinals.Rx[cell])
                    RnSector[bSec][n].set_bit(Cardinals.BxyN[cell])

                    BnR[Cardinals.Bxy[cell]][n].set_bit(Cardinals.Rx[cell])
                    BnC[Cardinals.Bxy[cell]][n].set_bit(Cardinals.Cy[cell])

                    RnB[rSec][n].set_bit(Cardinals.BxyN[cell])
                    CnB[Cardinals.Cy[cell]][n].set_bit(Cardinals.Bxy[cell])

                    sectorRC[rSec][Cardinals.Cy[cell]].set_bit(n)
                    sectorRC[cSec][Cardinals.Rx[cell]].set_bit(n)
                    sectorRC[bSec][Cardinals.BxyN[cell]].set_bit(n)

                    DigitRCB[rSec][n].set_bit(cell)
                    DigitRCB[cSec][n].set_bit(cell)
                    DigitRCB[bSec][n].set_bit(cell)

                    sectorN[rSec].set_bit(n)
                    sectorN[cSec].set_bit(n)
                    sectorN[bSec].set_bit(n)

                    digitcell[n].set_bit(cell)
                    pm[cell].set_bit(n)

                    nm[cell] += 1

    return {
        "Ocell": Ocell,
        "countpm": countpm,
        "count": count,
        "scount": scount,
        "sec": sec,
        "pm": pm,
        "nm": nm,
        "RnSector": RnSector,
        "BnR": BnR,
        "BnC": BnC,
        "RnB": RnB,
        "CnB": CnB,
        "sectorRC": sectorRC,
        "DigitRCB": DigitRCB,
        "sectorN": sectorN,
        "digitcell": digitcell,
        "sSector": sSector,
        "solved_cells": solved_cells
    }


class CellCombo:
    var ComboCell
    var ComboSubset
    var ComboNum
    var HComboNum

    func _init(ComboCell, ComboSubset, ComboNum, HComboNum) -> void:
        self.ComboCell = ComboCell
        self.ComboSubset = ComboSubset
        self.ComboNum = ComboNum
        self.HComboNum = HComboNum

func initiate_cell_combo(Ocell: BitSet, pm: Array, sectorRC: Array, RnSector: Array, tools: Tools) -> CellCombo:
    var ComboCell = SetOps.create_array(Cardinals.numb)
    var ComboSubset = SetOps.create_array(Cardinals.numb)
    var ComboNum = SetOps.create_2d_array(Cardinals.numb, Cardinals.secs)
    var HComboNum = SetOps.create_2d_array(Cardinals.numb, Cardinals.secs)
    
    for i in range(510):
        ComboCell[i] = BitSet.new()
        ComboSubset[i] = BitSet.new()
        
        for j in range(27):
            ComboNum[i][j] = BitSet.new()
            HComboNum[i][j] = BitSet.new()
    
    for r in range(Cardinals.numb):
        var i = Ocell.next_set_bit(0)
        while i >= 0:
            if SetOps.intersection(tools.comboset2[r], pm[i]) == pm[i]:
                ComboCell[r].set(i)
            if SetOps.is_subset_of(pm[i], tools.comboset2[r]):
                ComboSubset[r].set(i)
            i = Ocell.next_set_bit(i + 1)
        
        for j in range(27):
            var k = tools.comboset2[r].next_set_bit(0)
            while k >= 0:
                ComboNum[r][j] = SetOps.union(ComboNum[r][j], sectorRC[j][k])
                HComboNum[r][j] = SetOps.union(HComboNum[r][j], RnSector[j][k])
                k = tools.comboset2[r].next_set_bit(k + 1)
    
    return CellCombo.new(ComboCell, ComboSubset, ComboNum, HComboNum)

func er_intersection(sec: Array, DigitRCB: Array) -> Array:
    var eri = []
    for i in range(rcbs):
        var row = []
        for j in range(rcbs):
            row.append(BitSet.new())
        eri.append(row)
    
    # populate the eri
    for digit in range(9):
        for band in range(3):
            for stack in range(3):
                var b = 3 * band + stack
                var occInBox = sec[b + 18][digit]
                if occInBox < 6 and occInBox > 1:
                    for rowInBand in range(3):
                        for colInStack in range(3):
                            var r = 3 * band + rowInBand
                            var c = 3 * stack + colInStack
                            var inRow = DigitRCB[r][digit]
                            var inCol = DigitRCB[c + 9][digit]
                            var inBox = DigitRCB[b + 18][digit]
                            var inMiniCol = SetOps.intersection(inCol, inBox)
                            var inMiniRow = SetOps.intersection(inRow, inBox)
                            if not inBox.is_empty() and inBox == SetOps.union(inMiniCol, inMiniRow) and \
                            not SetOps.is_subset_of(inMiniCol, inRow) and not SetOps.is_subset_of(inMiniRow, inCol):
                                eri[b][digit].set(Cardinals.BxyN[r * 3 + c])
    return eri