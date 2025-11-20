# Bug: Missing check for empty puzzle_data array

## Description
In `sudoku_code.gd` function `get_puzzle_data()` (line 609), the function checks if the index is out of bounds, but doesn't verify that `puzzle_data` itself is initialized or non-empty. If `load_puzzle_data()` hasn't been called or failed, `puzzle_data` could be an empty array, and the function would return an empty dictionary without any indication of the problem.

## Location
`sudoku_code.gd:609-612`

## Code
```gdscript
func get_puzzle_data(index: int) -> Dictionary:
	if index < 0 || index >= puzzle_data.size():
		return {}
	return puzzle_data[index]
```

## Impact
- **Severity**: Low
- **Likelihood**: Medium (if load_puzzle_data() fails or isn't called)
- **User Impact**: Puzzles may not load correctly, with no clear error message

## Steps to Reproduce
1. Call `get_puzzle_data()` before calling `load_puzzle_data()`
2. Function returns empty dictionary without error indication
3. UI may show empty puzzle data

## Expected Behavior
The function should check if `puzzle_data` is initialized, or `load_puzzle_data()` should be called automatically if needed.

## Suggested Fix
```gdscript
func get_puzzle_data(index: int) -> Dictionary:
	if puzzle_data.is_empty():
		# Try to load puzzle data if not already loaded
		load_puzzle_data(puzzle_selected)
	if index < 0 || index >= puzzle_data.size():
		return {}
	return puzzle_data[index]
```

## Additional Notes
The calling code in `game_screen.gd:609` checks `if puzzle_data:` which would catch empty dictionaries, but not uninitialized arrays.
