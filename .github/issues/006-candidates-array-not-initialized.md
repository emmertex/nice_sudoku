# Bug: Candidates array may not be initialized when accessed

## Description
In `sbrc_grid.gd` line 61, the `get_candidates_for_cell` function checks if `candidates` array has the required size, but doesn't verify that `candidates` itself is initialized. If `_build_candidates()` hasn't been called yet, `candidates` could be an empty array, causing the function to return a new empty BitSet instead of the actual candidates.

## Location
`sbrc_grid.gd:60-63`

## Code
```gdscript
func get_candidates_for_cell(row: int, col: int) -> BitSet:
	if candidates.size() > row and candidates[row].size() > col:
		return candidates[row][col]
	return BitSet.new(9)
```

## Impact
- **Severity**: Medium
- **Likelihood**: Low (only if initialization order is wrong)
- **User Impact**: Incorrect candidate information, leading to wrong hints or invalid moves

## Steps to Reproduce
1. Create an SBRCGrid instance without calling `update_grid()` or `_build_candidates()`
2. Call `get_candidates_for_cell()` before initialization
3. Function returns empty BitSet instead of actual candidates

## Expected Behavior
The function should ensure candidates are built, or at least log a warning when returning empty candidates unexpectedly.

## Suggested Fix
```gdscript
func get_candidates_for_cell(row: int, col: int) -> BitSet:
	if candidates.is_empty():
		_build_candidates()
	if candidates.size() > row and candidates[row].size() > col:
		return candidates[row][col]
	return BitSet.new(9)
```

## Additional Notes
The `_init` function calls `update_grid()` which should build candidates, but if the grid is modified externally without calling `update_grid()`, this could be an issue.
