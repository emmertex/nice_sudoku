# Bug: Potential crash when puzzle list is empty

## Description
In `game_screen.gd` line 608, there's a loop that iterates from `0` to `get_puzzle_count()-1`. If `get_puzzle_count()` returns `0`, the range becomes `range(-1)`, which could cause unexpected behavior or crashes.

## Location
`game_screen.gd:608`

## Code
```gdscript
for i in range(sudoku.get_puzzle_count()-1):
```

## Impact
- **Severity**: Medium
- **Likelihood**: Low (only occurs when puzzle file is empty or missing)
- **User Impact**: Application crash or no puzzles displayed

## Steps to Reproduce
1. Create or modify a puzzle file to be empty
2. Try to open the puzzle selection popup
3. Application may crash or show no puzzles

## Expected Behavior
The code should check if `get_puzzle_count() > 0` before iterating, or handle the empty case gracefully.

## Suggested Fix
```gdscript
var puzzle_count = sudoku.get_puzzle_count()
if puzzle_count > 0:
    for i in range(puzzle_count):
        # ... rest of code
```

## Additional Notes
The loop also uses `range(count-1)` which seems incorrect - it should be `range(count)` to include all puzzles (0-indexed).
