# Bug: Potential KeyError when loading old save states

## Description
In `sudoku_code.gd` line 539, the code accesses `save.puzzle_selected` without checking if the key exists. While there's backward compatibility handling for `pencil_bits` and `exclude_bits` (lines 550-555), there's no check for `puzzle_selected`, which might not exist in very old save files.

## Location
`sudoku_code.gd:539` and `sudoku_code.gd:564`

## Code
```gdscript
if save.puzzle_selected == difficulty and save.current_puzzle_index == index:
```

and later:

```gdscript
puzzle_selected = save_to_load.puzzle_selected
```

## Impact
- **Severity**: Medium
- **Likelihood**: Low (only affects very old save files)
- **User Impact**: Application crash when loading old save files

## Steps to Reproduce
1. Create a save file without the `puzzle_selected` key (old format)
2. Try to load the save state
3. Application crashes with "Invalid get index" error

## Expected Behavior
The code should check if `save_to_load.has("puzzle_selected")` before accessing it, and provide a default value if missing.

## Suggested Fix
```gdscript
# In load_state function, around line 564
if save_to_load.has("puzzle_selected"):
    puzzle_selected = save_to_load.puzzle_selected
else:
    # Default to current puzzle_selected or "easy"
    puzzle_selected = puzzle_selected  # Keep current, or set to "easy"
```

## Additional Notes
Similar checks should be added for other potentially missing keys in old save files to ensure full backward compatibility.
