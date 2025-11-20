# Bug: File handle may not be closed in error cases

## Description
In `sudoku_code.gd` function `get_puzzle_count()` (line 449), if the function returns early due to a null file check, the file is never opened so there's no issue. However, if `file.eof_reached()` throws an exception or if there's an early return after opening the file, the file handle might not be properly closed. While Godot's FileAccess should handle cleanup automatically, explicit closing is a best practice.

## Location
`sudoku_code.gd:449-459`

## Code
```gdscript
func get_puzzle_count() -> int:
	var file = FileAccess.open(puzzles[puzzle_selected], FileAccess.READ)
	if file == null:
		print("Failed to open Puzzle File")
		return 0
   
	var count = 0
	while not file.eof_reached():
		file.get_line()
		count += 1
	return count
```

## Impact
- **Severity**: Low
- **Likelihood**: Very Low (Godot handles cleanup automatically)
- **User Impact**: Potential resource leak (unlikely)

## Expected Behavior
Explicitly close the file after use:
```gdscript
func get_puzzle_count() -> int:
	var file = FileAccess.open(puzzles[puzzle_selected], FileAccess.READ)
	if file == null:
		print("Failed to open Puzzle File")
		return 0
   
	var count = 0
	while not file.eof_reached():
		file.get_line()
		count += 1
	file.close()
	return count
```

## Additional Notes
Similar patterns exist in `load_puzzle()` and `load_puzzle_data()` functions. While Godot's garbage collection should handle this, explicit file closing is a best practice for resource management.
