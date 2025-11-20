# Bug: Potential index out of bounds when accessing pencil labels

## Description
In `game_screen.gd` line 548, the code accesses `pencil_container.get_child(num - 1)` where `num` comes from `elim_numbers` array. The pencil container has 9 children (indices 0-8), but `num` can be 1-9. While `num - 1` should work for valid numbers, there's no bounds checking to ensure `num` is within the valid range (1-9) or that the child exists.

## Location
`game_screen.gd:548`

## Code
```gdscript
var pencil_container = button.get_child(0)
for num in elim_numbers:
    if sudoku.has_pencil_mark(cell.x, cell.y, num):
        var pencil_label = pencil_container.get_child(num - 1)
        pencil_label.add_theme_color_override("font_color", CLR_HINT_CAUSE)
```

## Impact
- **Severity**: Medium
- **Likelihood**: Medium (could occur if elim_numbers contains invalid values)
- **User Impact**: Application crash when highlighting hints

## Steps to Reproduce
1. Generate a hint that has elim_numbers with values outside 1-9 range
2. Select the hint to highlight
3. Application crashes with index out of bounds error

## Expected Behavior
The code should validate that `num` is between 1 and 9, and that `pencil_container.get_child_count() > num - 1` before accessing the child.

## Suggested Fix
```gdscript
var pencil_container = button.get_child(0)
if pencil_container.get_child_count() >= 9:
    for num in elim_numbers:
        if num >= 1 and num <= 9 and sudoku.has_pencil_mark(cell.x, cell.y, num):
            var pencil_label = pencil_container.get_child(num - 1)
            if pencil_label:
                pencil_label.add_theme_color_override("font_color", CLR_HINT_CAUSE)
```
