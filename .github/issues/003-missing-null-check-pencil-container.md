# Bug: Missing null check for pencil container child

## Description
In `game_screen.gd` line 544, the code calls `button.get_child(0)` without checking if the button has any children. If the button structure is incorrect or hasn't been initialized properly, this will cause a crash.

## Location
`game_screen.gd:544`

## Code
```gdscript
var pencil_container = button.get_child(0)
```

## Impact
- **Severity**: High
- **Likelihood**: Low (only if UI structure is malformed)
- **User Impact**: Application crash when highlighting hints

## Steps to Reproduce
1. Modify the UI structure so buttons don't have pencil containers
2. Try to highlight a hint
3. Application crashes

## Expected Behavior
The code should check if `button.get_child_count() > 0` before accessing `get_child(0)`.

## Suggested Fix
```gdscript
if button.get_child_count() > 0:
    var pencil_container = button.get_child(0)
    # ... rest of code
else:
    push_error("Button missing pencil container child")
```
