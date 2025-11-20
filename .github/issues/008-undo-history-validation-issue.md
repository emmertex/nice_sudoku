# Bug: Undo history validation may not catch all invalid states

## Description
In `sudoku_code.gd` line 326, the undo operation validates the grid state using `_validate_grid_state()`, which only checks for conflicts. However, it doesn't validate that the history arrays (`number_history`, `pencil_history`, `exclude_history`) are in sync with the `history` array. If they become desynchronized, undo operations could fail silently or produce incorrect states.

## Location
`sudoku_code.gd:307-328`

## Code
```gdscript
func undo_history() -> void:
	if history.size() == 0:
		return
	
	var snapshot = _create_snapshot()
	var operation = history.pop_back()
	var success = false
	
	match operation:
		0: success = _undo_number_safe()
		1: success = _undo_pencil_safe()
		2: success = _undo_exclude_safe()
		3: success = _undo_pencil_safe()
		4: success = _undo_exclude_safe()
	
	if not success or not _validate_grid_state():
		_restore_snapshot(snapshot)
		print("Warning: Invalid undo operation, state restored")
```

## Impact
- **Severity**: Medium
- **Likelihood**: Low (only if history arrays become desynchronized)
- **User Impact**: Undo operations may fail or produce incorrect game states

## Steps to Reproduce
1. Manually corrupt the history arrays (e.g., remove items from number_history but not from history)
2. Try to undo
3. Undo may fail or produce incorrect state

## Expected Behavior
The undo function should validate that the corresponding history array has items before attempting to undo, and ensure all history arrays stay in sync.

## Suggested Fix
Add validation before popping from history:
```gdscript
func undo_history() -> void:
	if history.size() == 0:
		return
	
	var snapshot = _create_snapshot()
	var operation = history.pop_back()
	var success = false
	
	match operation:
		0: 
			if number_history.size() > 0:
				success = _undo_number_safe()
		1, 3: 
			if pencil_history.size() > 0:
				success = _undo_pencil_safe()
		2, 4: 
			if exclude_history.size() > 0:
				success = _undo_exclude_safe()
	
	if not success or not _validate_grid_state():
		history.append(operation)  # Restore the operation
		_restore_snapshot(snapshot)
		print("Warning: Invalid undo operation, state restored")
```
