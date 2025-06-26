extends Node

# Test script for Phase 2 implementation
# This can be run to verify BitSet and SBRCGrid functionality

func _ready():
    print("Testing Phase 2 Implementation...")
    test_bitset()
    test_sbrc_grid()
    print("Phase 2 tests completed!")

func test_bitset():
    print("\n=== Testing BitSet ===")
    
    # Test basic operations
    var bs = BitSet.new(9)
    print("Empty BitSet cardinality: ", bs.cardinality())
    
    bs.set(3)
    bs.set(5)
    bs.set(7)
    print("After setting bits 3,5,7: ", bs.to_string())
    print("Cardinality: ", bs.cardinality())
    
    print("Bit 3 is set: ", bs.get(3))
    print("Bit 4 is set: ", bs.get(4))
    
    # Test operations
    var bs2 = BitSet.new(9)
    bs2.set(1)
    bs2.set(3)
    bs2.set(5)
    
    print("BitSet 1: ", bs.to_string())
    print("BitSet 2: ", bs2.to_string())
    print("Intersection: ", bs.intersection(bs2).to_string())
    print("Union: ", bs.union(bs2).to_string())
    print("Difference: ", bs.difference(bs2).to_string())
    
    # Test next_set_bit
    print("Next set bit from 0: ", bs.next_set_bit(0))
    print("Next set bit from 4: ", bs.next_set_bit(4))

func test_sbrc_grid():
    print("\n=== Testing SBRCGrid ===")
    
    # Create a simple test grid
    var test_grid = []
    for i in range(9):
        var row = []
        for j in range(9):
            row.append(0)
        test_grid.append(row)
    
    # Add some test values
    test_grid[0][0] = 1
    test_grid[0][1] = 2
    test_grid[1][0] = 3
    test_grid[8][8] = 9
    
    var grid = SBRCGrid.new(test_grid)
    print("Grid:\n", grid.to_string())
    
    # Test candidate generation
    var candidates = grid.get_candidates_for_cell(0, 2)
    print("Candidates for cell (0,2): ", candidates.to_string())
    
    # Test valid placement
    print("Can place 4 at (0,2): ", grid.is_valid_placement(0, 2, 4))
    print("Can place 1 at (0,2): ", grid.is_valid_placement(0, 2, 1))
    
    # Test setting values
    grid.set_cell_value(0, 2, 4)
    print("After setting 4 at (0,2):\n", grid.to_string())
    
    # Test conflicts
    var conflicts = grid.get_conflicts()
    print("Conflicts: ", conflicts.size())
    
    # Test empty cells
    var empty = grid.get_empty_cells()
    print("Empty cells count: ", empty.size())
    
    # Test sector data
    var row_candidates = grid.get_row_candidates(0, 0)  # digit 1 in row 0
    print("Row 0, digit 1 candidates: ", row_candidates.to_string())
    
    var col_candidates = grid.get_col_candidates(0, 0)  # digit 1 in col 0
    print("Col 0, digit 1 candidates: ", col_candidates.to_string())
    
    var box_candidates = grid.get_box_candidates(0, 0)  # digit 1 in box 0
    print("Box 0, digit 1 candidates: ", box_candidates.to_string())

# Run tests when script is executed
func _input(event):
    if event is InputEventKey and event.pressed and event.keycode == KEY_T:
        test_bitset()
        test_sbrc_grid() 