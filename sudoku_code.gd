extends RefCounted
class_name Sudoku

const Hint = preload("res://hint.gd")

# Properties
var grid: Array = []
var original_grid: Array = []
var pencil_bits: Array = []  # 9x9 array of integers
var exclude_bits: Array = [] # 9x9 array of integers
# Action-based undo system
# Each action represents a single user action and can contain multiple changes
# Actions are stored as dictionaries with type and changes array
var action_history: Array = []  # Array of action dictionaries
var current_puzzle_name: String = ""
var current_puzzle_difficulty: String = ""
var current_puzzle_index: int = -1
var save_states: Array = []
var puzzle_data: Array = []
var puzzle_time: int = 0
var puzzle_selected: String = "easy"
var puzzles: Dictionary = {
	"easy": "res://puzzles/easy.txt",
	"medium": "res://puzzles/medium.txt", 
	"hard": "res://puzzles/hard.txt",
	"expert": "res://puzzles/diabolical.txt"
}
var difficulty_index: Dictionary = {
	"easy": 0,
	"medium": 1,
	"hard": 2,
	"expert": 3
}

var sbrc_grid: SBRCGrid

# Solution and mistake tracking
var solution_grid: Array = []
var has_solution: bool = false
var mistake_count: int = 0

# Initialization
func _init():
	_generate_empty_grid()
	_generate_pencil_grid()
	_initialize_sbrc_grid()

func _initialize_sbrc_grid():
	if grid == null or grid.is_empty():
		_generate_empty_grid()
	sbrc_grid = SBRCGrid.new(grid)

# Grid Generation
func _generate_empty_grid():
	grid = []
	for _i in range(9):
		var row = []
		for _j in range(9):
			row.append(0)
		grid.append(row)
	original_grid = grid.duplicate(true)

func _generate_pencil_grid():
	pencil_bits = []
	exclude_bits = []
	for _i in range(9):
		var pencil_row = []
		var exclude_row = []
		for _j in range(9):
			pencil_row.append(0)
			exclude_row.append(0)
		pencil_bits.append(pencil_row)
		exclude_bits.append(exclude_row)

func load_puzzle(_puzzle_file: String, puzzle_index: int) -> bool:
	var file = FileAccess.open(_puzzle_file, FileAccess.READ)
	if file == null:
		print("Failed to open Puzzle File")
		return false
	var line_count = 0
	while not file.eof_reached():
		var line = file.get_line()
		if line_count == puzzle_index:
			var _puzzle_data = parse_puzzle_line(line)
			file.close()
			return load_puzzle_from_dictionary(_puzzle_data, puzzle_index)
	   
		line_count += 1
   
	file.close()
	print("Puzzle index out of range")
	return false

func load_puzzle_from_dictionary(_puzzle_data: Dictionary, puzzle_index: int = 0) -> bool:
	if _puzzle_data == null or not _puzzle_data.has("grid"):
		print("Invalid puzzle data")
		return false
	_init()
	grid = _puzzle_data["grid"]
	original_grid = grid.duplicate(true)
	current_puzzle_name = _puzzle_data.get("name", "Puzzle " + str(puzzle_index + 1))
	current_puzzle_difficulty = _puzzle_data["difficulty"]
	current_puzzle_index = puzzle_index
	sbrc_grid.update_grid(grid)
	_clear_history()
	
	# Reset mistake tracking
	mistake_count = 0
	solution_grid = []
	has_solution = false
	
	# Note: Solver will be called from game_screen after UI loads
	# to avoid blocking initialization
	
	return true


func fast_parse_puzzle_line(line: String) -> Dictionary:
	var result = {}
	var difficulty = line.substr(95, 4).strip_edges()
   
	result["difficulty"] = difficulty
	
	if line.length() > 99:
		result["name"] = line.substr(99).strip_edges()
   
	return result

func load_puzzle_from_string(line: String) -> bool:
	if line.length() == 81:
		_init()
		grid = string_to_grid(line.substr(0, 81))
		original_grid = grid.duplicate(true)
		current_puzzle_difficulty = "Unknown"
		current_puzzle_name = "Custom Puzzle"
	elif line.length() == 99:
		_init()
		current_puzzle_difficulty = line.substr(95, 4).strip_edges()
		grid = string_to_grid(line.substr(13, 81))
		original_grid = grid.duplicate(true)
		current_puzzle_name = "Custom Puzzle"
	elif line.length() == 891:
		_init()
		original_grid = string_to_grid(line.substr(0, 81))
		grid = string_to_grid(line.substr(81, 81))
		current_puzzle_name = "Custom Resume"
		# Iterate over every character from 162 to 891 (729 chars for 81 cells × 9 digits)
		for i in range(162, 891):
			@warning_ignore("integer_division")
			var row = (i - 162) / 81
			@warning_ignore("integer_division")
			var col = ((i - 162) % 81) / 9
			var digit_index := (i - 162) % 9 # 0..8 corresponds to digits 1..9
			var bit := 1 << digit_index
			if line[i] == "1":
				pencil_bits[row][col] |= bit
				exclude_bits[row][col] &= ~bit
			elif line[i] == "2":
				exclude_bits[row][col] |= bit
				pencil_bits[row][col] &= ~bit
			else:
				pencil_bits[row][col] &= ~bit
				exclude_bits[row][col] &= ~bit
	else:
		return false

	sbrc_grid.update_grid(grid)
	_clear_history()
	current_puzzle_index = 0
	
	# Reset mistake tracking
	mistake_count = 0
	solution_grid = []
	has_solution = false
	
	# Try to solve the puzzle
	solve_puzzle()
	
	return true

func parse_puzzle_line(line: String) -> Dictionary:
	var result = {}
   
	print(line)
	print(line.length())

	if line.length() == 81:
		result["difficulty"] = "Unknown"
		result["hashstr"] = "Unknown"
		result["grid"] = string_to_grid(line.substr(0, 81))
		result["name"] = "Custom Puzzle"
	else:
		var hashstr = line.substr(0, 12)
		var puzzle_string = line.substr(13, 81)
		var difficulty = line.substr(95, 4).strip_edges()
		result["hashstr"] = hashstr
		result["difficulty"] = difficulty
		result["grid"] = string_to_grid(puzzle_string)
   
	print(result)
	return result

func string_to_grid(puzzle_string: String) -> Array:
	var _grid = []
	for i in range(9):
		var row = []
		for j in range(9):
			var index = i * 9 + j
			var cell = puzzle_string[index]
			var value = 0
			if cell != ".":
				value = int(cell)
			row.append(value)
		_grid.append(row)
	return _grid

func is_valid_move(row: int, col: int, num: int) -> bool:
	return sbrc_grid.is_valid_placement(row, col, num)

func get_candidates_for_cell(row: int, col: int) -> BitSet:
	return sbrc_grid.get_candidates_for_cell(row, col)
	
func set_number(row: int, col: int, num: int) -> Dictionary:
	# Return value: {"success": bool, "is_mistake": bool}
	var result = {"success": false, "is_mistake": false}
	
	if is_valid_move(row, col, num) && !is_given_number(row, col):
		# Create action to track all changes from this number placement
		var action = {
			"type": "place_number",
			"changes": []
		}
		
		# Store the number change (use bracket notation for consistency)
		action["changes"].append({
			"type": "number",
			"row": row,
			"col": col,
			"old_value": grid[row][col],
			"new_value": num
		})
		
		# Collect all cells that will have pencil/exclude marks changed BEFORE clearing them
		# Use dictionaries keyed by cell position to avoid duplicates
		var pencil_changes = {}  # Key: "row_col", Value: old_bits
		var exclude_changes = {}  # Key: "row_col", Value: old_bits
		
		# Collect pencil/exclude marks from the cell itself
		var cell_key = str(row) + "_" + str(col)
		if pencil_bits[row][col] != 0:
			pencil_changes[cell_key] = pencil_bits[row][col]
		if exclude_bits[row][col] != 0:
			exclude_changes[cell_key] = exclude_bits[row][col]
		
		# Collect pencil marks of the number from the block
		@warning_ignore("integer_division")
		var block_row = (row / 3) * 3
		@warning_ignore("integer_division")
		var block_col = (col / 3) * 3
		for r in range(block_row, block_row + 3):
			for c in range(block_col, block_col + 3):
				if has_pencil_mark(r, c, num):
					var key = str(r) + "_" + str(c)
					if not pencil_changes.has(key):
						pencil_changes[key] = pencil_bits[r][c]
		
		# Collect pencil marks of the number from the row
		for c in range(9):
			if has_pencil_mark(row, c, num):
				var key = str(row) + "_" + str(c)
				if not pencil_changes.has(key):
					pencil_changes[key] = pencil_bits[row][c]
		
		# Collect pencil marks of the number from the column
		for r in range(9):
			if has_pencil_mark(r, col, num):
				var key = str(r) + "_" + str(col)
				if not pencil_changes.has(key):
					pencil_changes[key] = pencil_bits[r][col]
		
		# Now actually perform the changes
		grid[row][col] = num
		sbrc_grid.set_cell_value(row, col, num)
		
		# Clear all pencil marks from the cell (without storing history)
		for i in range(9):
			if has_pencil_mark(row, col, i+1):
				set_pencil_mark_internal(row, col, i+1, false)
			if has_exclude_mark(row, col, i+1):
				set_exclude_mark_internal(row, col, i+1, false)
		
		# Clear pencil marks of the number from the block
		for r in range(block_row, block_row + 3):
			for c in range(block_col, block_col + 3):
				if has_pencil_mark(r, c, num):
					set_pencil_mark_internal(r, c, num, false)
		
		# Clear pencil marks of the number from the row
		for c in range(9):
			if has_pencil_mark(row, c, num):
				set_pencil_mark_internal(row, c, num, false)
		
		# Clear pencil marks of the number from the column
		for r in range(9):
			if has_pencil_mark(r, col, num):
				set_pencil_mark_internal(r, col, num, false)
		
		# Store pencil changes in action (using old_bits from before clearing)
		for key in pencil_changes:
			var parts = key.split("_")
			var r = int(parts[0])
			var c = int(parts[1])
			action["changes"].append({
				"type": "pencil",
				"row": r,
				"col": c,
				"num": 0,  # 0 means all bits
				"old_bits": pencil_changes[key],
				"new_bits": pencil_bits[r][c]  # Current state after clearing
			})
		
		# Store exclude changes in action
		for key in exclude_changes:
			var parts = key.split("_")
			var r = int(parts[0])
			var c = int(parts[1])
			action["changes"].append({
				"type": "exclude",
				"row": r,
				"col": c,
				"num": 0,  # 0 means all bits
				"old_bits": exclude_changes[key],
				"new_bits": exclude_bits[r][c]
			})
		
		# Store the action in history (always store, even if no pencil changes)
		# Deep duplicate the action to avoid reference issues
		# Use bracket notation consistently
		var changes_array = action["changes"]
		var action_copy = {
			"type": action["type"],
			"changes": []
		}
		for change in changes_array:
			# Deep duplicate each change dictionary
			action_copy["changes"].append(change.duplicate(true))
		
		action_history.append(action_copy)
		
		result["success"] = true
		
		# Check for mistake if solution is available
		if has_solution and solution_grid.size() == 9 and solution_grid[0].size() == 9:
			if solution_grid[row][col] != num:
				mistake_count += 1
				result["is_mistake"] = true
		
		return result
	
	return result

func clear_number(row: int, col: int):
	# Create action for clearing number
	var action = {
		"type": "clear_number",
		"changes": [{
			"type": "number",
			"row": row,
			"col": col,
			"old_value": grid[row][col],
			"new_value": 0
		}]
	}
	
	grid[row][col] = 0
	sbrc_grid.set_cell_value(row, col, 0)
	
	action_history.append(action)

	

func is_completed() -> bool:
		return sbrc_grid.is_complete()
	

# Pencil Marks and Exclude
func auto_fill_pencil_marks():
	sbrc_grid.update_grid(grid)
	
	# Create action for auto-fill
	var action = {
		"type": "auto_fill_pencil",
		"changes": []
	}
	
	# Collect all changes before applying them
	for row in range(9):
		for col in range(9):
			if pencil_bits[row][col] != 0:
				action.changes.append({
					"type": "pencil",
					"row": row,
					"col": col,
					"num": 0,  # 0 means all bits
					"old_bits": pencil_bits[row][col],
					"new_bits": 0
				})
			if exclude_bits[row][col] != 0:
				action.changes.append({
					"type": "exclude",
					"row": row,
					"col": col,
					"num": 0,  # 0 means all bits
					"old_bits": exclude_bits[row][col],
					"new_bits": 0
				})
	
	# Clear all pencil marks
	for row in range(9):
		for col in range(9):
			pencil_bits[row][col] = 0
			exclude_bits[row][col] = 0
	
	# Now fill with candidates
	for row in range(9):
		for col in range(9):
			if grid[row][col] == 0:
				var candidates = sbrc_grid.get_candidates_for_cell(row, col)
				var mask = 0
				for i in range(9):
					if candidates.get_bit(i):
						mask |= (1 << i)
				
				if pencil_bits[row][col] != mask:
					action.changes.append({
						"type": "pencil",
						"row": row,
						"col": col,
						"num": 0,  # 0 means all bits
						"old_bits": pencil_bits[row][col],
						"new_bits": mask
					})
					pencil_bits[row][col] = mask
					exclude_bits[row][col] = 0
	
	# Store action if there were any changes
	if action.changes.size() > 0:
		action_history.append(action)

func clear_all_pencil_marks():
	# Create action for clearing all pencil marks
	var action = {
		"type": "clear_all_pencil",
		"changes": []
	}
	
	for row in range(9):
		for col in range(9):
			if pencil_bits[row][col] != 0:
				action.changes.append({
					"type": "pencil",
					"row": row,
					"col": col,
					"num": 0,  # 0 means all bits
					"old_bits": pencil_bits[row][col],
					"new_bits": 0
				})
				pencil_bits[row][col] = 0
			if exclude_bits[row][col] != 0:
				action.changes.append({
					"type": "exclude",
					"row": row,
					"col": col,
					"num": 0,  # 0 means all bits
					"old_bits": exclude_bits[row][col],
					"new_bits": 0
				})
				exclude_bits[row][col] = 0
	
	# Store action if there were any changes
	if action.changes.size() > 0:
		action_history.append(action)

func swap_pencil(row: int, col: int, num: int) -> void:
	# Create action for manual pencil change
	var action = {
		"type": "swap_pencil",
		"changes": []
	}
	
	var old_pencil_bits = pencil_bits[row][col]
	var old_exclude_bits = exclude_bits[row][col]
	
	if has_pencil_mark(row, col, num):
		set_pencil_mark_internal(row, col, num, false)
	else:
		set_pencil_mark_internal(row, col, num, true)
		set_exclude_mark_internal(row, col, num, false) # Always clear exclude
	
	action.changes.append({
		"type": "pencil",
		"row": row,
		"col": col,
		"num": num,
		"old_bits": old_pencil_bits,
		"new_bits": pencil_bits[row][col]
	})
	
	# If exclude was cleared, track that too
	if old_exclude_bits != exclude_bits[row][col]:
		action.changes.append({
			"type": "exclude",
			"row": row,
			"col": col,
			"num": num,
			"old_bits": old_exclude_bits,
			"new_bits": exclude_bits[row][col]
		})
	
	action_history.append(action)

func swap_exclude(row: int, col: int, num: int) -> void:
	# Create action for manual exclude change
	var action = {
		"type": "swap_exclude",
		"changes": []
	}
	
	var old_pencil_bits = pencil_bits[row][col]
	var old_exclude_bits = exclude_bits[row][col]
	
	if has_exclude_mark(row, col, num):
		set_exclude_mark_internal(row, col, num, false)
	else:
		set_exclude_mark_internal(row, col, num, true)
		set_pencil_mark_internal(row, col, num, false) # Always clear pencil
	
	action.changes.append({
		"type": "exclude",
		"row": row,
		"col": col,
		"num": num,
		"old_bits": old_exclude_bits,
		"new_bits": exclude_bits[row][col]
	})
	
	# If pencil was cleared, track that too
	if old_pencil_bits != pencil_bits[row][col]:
		action.changes.append({
			"type": "pencil",
			"row": row,
			"col": col,
			"num": num,
			"old_bits": old_pencil_bits,
			"new_bits": pencil_bits[row][col]
		})
	
	action_history.append(action)

# History Management
func _clear_history() -> void:
	action_history = []

func undo_history() -> void:
	if action_history.size() == 0:
		return
	
	# Create snapshot for safety
	var snapshot = _create_snapshot()
	
	# Get the last action and undo all its changes
	var action = action_history.pop_back()
	
	# Access changes array - try both dot notation and bracket notation
	var changes = null
	if action.has("changes"):
		changes = action["changes"]
	elif "changes" in action:
		changes = action.changes
	else:
		print("Warning: Action missing 'changes' key. Action keys: ", action.keys())
		action_history.append(action)  # Restore the action
		return
	
	if changes == null or changes.is_empty():
		print("Warning: Action has no changes to undo. Action: ", action)
		action_history.append(action)  # Restore the action
		return
	
	# Undo all changes in reverse order (so number is undone last, after pencils)
	for i in range(changes.size() - 1, -1, -1):
		var change = changes[i]
		
		# Use bracket notation for dictionary access to be safe
		var change_type = change.get("type", "")
		var change_row = change.get("row", -1)
		var change_col = change.get("col", -1)
		
		if change_row < 0 or change_col < 0 or change_row >= 9 or change_col >= 9:
			print("Warning: Invalid change coordinates: [", change_row, ",", change_col, "]")
			continue
		
		match change_type:
			"number":
				var old_value = change.get("old_value", 0)
				grid[change_row][change_col] = old_value
				sbrc_grid.set_cell_value(change_row, change_col, old_value)
			"pencil":
				var old_bits = change.get("old_bits", 0)
				pencil_bits[change_row][change_col] = old_bits
			"exclude":
				var old_bits = change.get("old_bits", 0)
				exclude_bits[change_row][change_col] = old_bits
	
	# Validate and restore if needed
	if not _validate_grid_state():
		action_history.append(action)  # Restore the action
		_restore_snapshot(snapshot)
		print("Warning: Invalid undo operation, state restored")

func _create_snapshot() -> Dictionary:
	return {
		"grid": grid.duplicate(true),
		"pencil_bits": pencil_bits.duplicate(true),
		"exclude_bits": exclude_bits.duplicate(true),
		"action_history": action_history.duplicate(true)
	}

func _restore_snapshot(snapshot: Dictionary):
	grid = snapshot.grid
	pencil_bits = snapshot.pencil_bits
	exclude_bits = snapshot.exclude_bits
	action_history = snapshot.action_history
	sbrc_grid = SBRCGrid.new(grid)

func _validate_grid_state() -> bool:
	return sbrc_grid.get_conflicts().size() == 0

func find_hidden_singles() -> Array:
	var singles = []

	# We need to respect the exclude_bits here
	var temp_candidates = []
	for r in range(9):
		var row_cands = []
		for c in range(9):
			var cands = sbrc_grid.get_candidates_for_cell(r, c).clone()
			var bits_to_exclude = exclude_bits[r][c]
			if bits_to_exclude > 0:
				cands.data[0] &= ~bits_to_exclude
			row_cands.append(cands)
		temp_candidates.append(row_cands)

	# Rows
	for r in range(9):
		for d in range(9):  # digit-1
			var count = 0
			var found_c = -1
			for c in range(9):
				if grid[r][c] == 0:
					var cell_candidates = temp_candidates[r][c]
					if cell_candidates.get_bit(d):
						count += 1
						found_c = c
			if count == 1:
				singles.append({"row": r, "col": found_c, "digit": d + 1, "type": "row"})

	# Columns
	for c in range(9):
		for d in range(9):  # digit-1
			var count = 0
			var found_r = -1
			for r in range(9):
				if grid[r][c] == 0:
					var cell_candidates = temp_candidates[r][c]
					if cell_candidates.get_bit(d):
						count += 1
						found_r = r
			if count == 1:
				singles.append({"row": found_r, "col": c, "digit": d + 1, "type": "column"})

	# Boxes
	for b in range(9):
		for d in range(9):  # digit-1
			var count = 0
			var found_i = -1
			for i in range(9):
				var cell = Cardinals.box_to_rc(b, i)
				if grid[cell.x][cell.y] == 0:
					var cell_candidates = temp_candidates[cell.x][cell.y]
					if cell_candidates.get_bit(d):
						count += 1
						found_i = i
			if count == 1:
				var cell = Cardinals.box_to_rc(b, found_i)
				singles.append({"row": cell.x, "col": cell.y, "digit": d + 1, "type": "box"})
	
	return singles

func get_conflicts() -> Array:
	return sbrc_grid.get_conflicts()


func get_empty_cells() -> Array:
	return sbrc_grid.get_empty_cells()

# Utility Functions
func is_given_number(row: int, col: int) -> bool:
	return original_grid[row][col] != 0

func is_wrong_number(row: int, col: int) -> bool:
	# Check if the number in this cell is wrong (doesn't match solution)
	if not has_solution:
		return false
	if solution_grid.is_empty():
		return false
	if grid[row][col] == 0:
		return false
	if solution_grid.size() != 9:
		return false
	if solution_grid[0].size() != 9:
		return false
	# Compare with solution
	var is_wrong = solution_grid[row][col] != grid[row][col]
	return is_wrong

# Puzzle Information
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

func get_puzzle_info() -> Dictionary:
	return {
		"name": current_puzzle_name,
		"difficulty": current_puzzle_difficulty,
		"index": current_puzzle_index
	}

func get_needed_numbers() -> Array:
	var needed = [true, true, true, true, true, true, true, true, true]
	var count = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	for row in range(9):
		for col in range(9):
			var num = grid[row][col]
			if num != 0:
				count[num - 1] += 1
   
	for i in range(9):
		if count[i] == 9:
			needed[i] = false
   
	return needed

# Add these functions at the end of the file

func save_state(file_path: String) -> bool:
	var config = ConfigFile.new()
	if config.load(file_path) != OK:
		config = ConfigFile.new()

	var puzzle_saves = config.get_value("puzzle_saves", "puzzles", [])
	var save_data = {
		"grid": grid,
		"original_grid": original_grid,
		"pencil_bits": pencil_bits,
		"exclude_bits": exclude_bits,
		"action_history": action_history,
		"current_puzzle_name": current_puzzle_name,
		"current_puzzle_difficulty": current_puzzle_difficulty,
		"current_puzzle_index": current_puzzle_index,
		"puzzle_selected": puzzle_selected,
		"puzzle_time": puzzle_time,
		"mistake_count": mistake_count,
		"has_solution": has_solution
	}
	
	# Check if a save for this puzzle already exists
	var existing_save_index = -1
	for i in range(puzzle_saves.size()):
		if puzzle_saves[i].current_puzzle_difficulty == current_puzzle_difficulty and \
		   puzzle_saves[i].current_puzzle_index == current_puzzle_index:
			existing_save_index = i
			break
	
	if existing_save_index != -1:
		# Update existing save
		puzzle_saves[existing_save_index] = save_data
	else:
		# Add new save
		puzzle_saves.append(save_data)
	
	config.set_value("puzzle_saves", "puzzles", puzzle_saves)
	return config.save(file_path) == OK

func load_state(file_path: String, difficulty: String = "", index: int = -1) -> bool:
	var config = ConfigFile.new()
	if config.load(file_path) != OK:
		return false
	
	var puzzle_saves = config.get_value("puzzle_saves", "puzzles", [])
	var save_to_load = null
	
	if difficulty == "" and index == -1:
		if puzzle_saves.size() > 0:
			save_to_load = puzzle_saves[-1]
	else:
		for save in puzzle_saves:
			var save_puzzle_selected = save.get("puzzle_selected", difficulty)
			print("Save to load: " + str(save_puzzle_selected) + " " + str(save.current_puzzle_index))
			if save_puzzle_selected == difficulty and save.current_puzzle_index == index:
				save_to_load = save
				break
	
	if save_to_load == null:
		return false
	
	grid = save_to_load.grid
	original_grid = save_to_load.original_grid
	
	# Handle backward compatibility for old save files
	if save_to_load.has("pencil_bits") and save_to_load.has("exclude_bits"):
		pencil_bits = save_to_load.pencil_bits
		exclude_bits = save_to_load.exclude_bits
	else:
		# Initialize empty pencil/exclude arrays for old save files
		_generate_pencil_grid()
	
	# Handle backward compatibility for old history format
	if save_to_load.has("action_history"):
		action_history = save_to_load.action_history
	else:
		# Old save format - clear history (can't convert old format to new)
		action_history = []
	current_puzzle_name = save_to_load.current_puzzle_name
	current_puzzle_difficulty = save_to_load.current_puzzle_difficulty
	current_puzzle_index = save_to_load.current_puzzle_index
	# Handle backward compatibility for puzzle_selected
	if save_to_load.has("puzzle_selected"):
		puzzle_selected = save_to_load.puzzle_selected
	else:
		# Default to current puzzle_selected or "easy" if missing
		puzzle_selected = puzzle_selected if puzzle_selected != "" else "easy"
	puzzle_time = save_to_load.puzzle_time
	
	# Handle mistake tracking (backward compatible)
	if save_to_load.has("mistake_count"):
		mistake_count = save_to_load.mistake_count
	else:
		mistake_count = 0
	
	if save_to_load.has("has_solution"):
		has_solution = save_to_load.has_solution
		# If solution was saved, try to regenerate it
		# DISABLED: Don't solve during load_state to avoid blocking UI
		# Solution will be regenerated later if needed
		# if has_solution and solution_grid.size() == 0:
		#	solve_puzzle()
	else:
		has_solution = false
		solution_grid = []
	
	sbrc_grid.update_grid(grid)
	
	return true

func save_completed_puzzle() -> bool:
	var config = ConfigFile.new()
	var full_file_path =  "user://" + puzzle_selected + ".cfg"
	
	if config.load(full_file_path) != OK:
		config = ConfigFile.new()
	
	# Save completed puzzle
	var completed_puzzles = config.get_value("completed", "puzzles", [])
	var completed_puzzle = {
		"grid": grid,
		"original_grid": original_grid,
		"current_puzzle_index": current_puzzle_index,
		"puzzle_time": puzzle_time
	}
	completed_puzzles.append(completed_puzzle)
	config.set_value("completed", "puzzles", completed_puzzles)

	# Remove the save state for this puzzle
	var puzzle_saves = config.get_value("puzzle_saves", "puzzles", [])
	var updated_puzzle_saves = []
	for save in puzzle_saves:
		if save.current_puzzle_difficulty != current_puzzle_difficulty or \
		   save.current_puzzle_index != current_puzzle_index:
			updated_puzzle_saves.append(save)
	config.set_value("puzzle_saves", "puzzles", updated_puzzle_saves)

	# Save the updated config
	return config.save(full_file_path) == OK

func load_puzzle_data(difficulty: String):
	var file = FileAccess.open(puzzles[difficulty], FileAccess.READ)
	if file == null:
		print("Failed to open Puzzle File")
		return {}
	puzzle_data = []
	while not file.eof_reached():
		puzzle_data.append(fast_parse_puzzle_line(file.get_line()))
	file.close()
	
func get_puzzle_data(index: int) -> Dictionary:
	if puzzle_data.is_empty():
		# Try to load puzzle data if not already loaded
		load_puzzle_data(puzzle_selected)
	if index < 0 || index >= puzzle_data.size():
		return {}
	return puzzle_data[index]

func fast_load_save_states(file_path: String):
	var config = ConfigFile.new()
	if config.load(file_path) != OK:
		print("Failed to open save file")
		return
	
	save_states = config.get_value("puzzle_saves", "puzzles", [])

func has_save_state(difficulty: String, puzzle_index: int) -> bool:
	if save_states.is_empty():
		fast_load_save_states("user://sudoku_saves.cfg")  # Adjust the file path as needed
	
	for save in save_states:
		var save_puzzle_selected = save.get("puzzle_selected", difficulty)
		if save_puzzle_selected == difficulty and save.current_puzzle_index == puzzle_index:
			return true
	
	return false

func puzzle_file(path: String) -> bool:
	# This method is called from game_screen.gd but was missing
	# For now, we'll implement a basic file loading functionality
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	
	var content = file.get_as_text()
	file.close()
	
	# Try to load as a puzzle string
	return load_puzzle_from_string(content)

func has_pencil_mark(row: int, col: int, num: int) -> bool:
	return (pencil_bits[row][col] & (1 << (num - 1))) != 0

# Internal functions that modify pencil/exclude marks without storing history
# These are used when changes are part of a larger action
func set_pencil_mark_internal(row: int, col: int, num: int, value: bool):
	if value:
		pencil_bits[row][col] |= (1 << (num - 1))
	else:
		pencil_bits[row][col] &= ~(1 << (num - 1))

func set_exclude_mark_internal(row: int, col: int, num: int, value: bool):
	if value:
		exclude_bits[row][col] |= (1 << (num - 1))
	else:
		exclude_bits[row][col] &= ~(1 << (num - 1))

# Public functions for setting pencil/exclude marks
# These create their own actions (for programmatic use)
func set_pencil_mark(row: int, col: int, num: int, value: bool):
	var action = {
		"type": "set_pencil",
		"changes": [{
			"type": "pencil",
			"row": row,
			"col": col,
			"num": num,
			"old_bits": pencil_bits[row][col],
			"new_bits": pencil_bits[row][col]  # Will be updated below
		}]
	}
	
	set_pencil_mark_internal(row, col, num, value)
	action.changes[0].new_bits = pencil_bits[row][col]
	action_history.append(action)

func has_exclude_mark(row: int, col: int, num: int) -> bool:
	return (exclude_bits[row][col] & (1 << (num - 1))) != 0

func set_exclude_mark(row: int, col: int, num: int, value: bool):
	var action = {
		"type": "set_exclude",
		"changes": [{
			"type": "exclude",
			"row": row,
			"col": col,
			"num": num,
			"old_bits": exclude_bits[row][col],
			"new_bits": exclude_bits[row][col]  # Will be updated below
		}]
	}
	
	set_exclude_mark_internal(row, col, num, value)
	action.changes[0].new_bits = exclude_bits[row][col]
	action_history.append(action)

func solve_with_backtracking(num_solutions_to_find: int = 1) -> Array:
	var solutions = []
	var empty_cells = sbrc_grid.get_empty_cells()

	_solve_recursive(0, empty_cells, solutions, num_solutions_to_find)

	return solutions

func solve_puzzle() -> bool:
	#print("solve_puzzle() called")
	# First try hint-based solving
	var hint_generator = load("res://hint_generator.gd").new()
	hint_generator.sudoku = self
	
	# Save current grid state
	var original_state = grid.duplicate(true)
	
	# Try hint-based solving
	var applied_hint = true
	var iteration_limit = 100
	var iterations = 0
	
	#print("Starting hint-based solving...")
	while applied_hint and iterations < iteration_limit:
		iterations += 1
		applied_hint = false
		if sbrc_grid.is_complete():
			break
		
		var hints = hint_generator.get_hints()
		if hints.is_empty():
			break
		
		# Prioritize placement hints
		var best_hint = _find_best_hint_for_solving(hints)
		
		if best_hint == null:
			break
		
		# Check if hint will actually make progress
		var will_make_progress = false
		if best_hint.cells.size() == 1 and best_hint.numbers.size() == 1:
			# Placement hint - check if cell is empty
			var cell = best_hint.cells[0]
			if grid[cell.x][cell.y] == 0:
				will_make_progress = true
		elif not best_hint.elim_cells.is_empty():
			# Elimination hint - check if any eliminations haven't been applied yet
			for cell in best_hint.elim_cells:
				for num in best_hint.elim_numbers:
					if not has_exclude_mark(cell.x, cell.y, num):
						will_make_progress = true
						break
				if will_make_progress:
					break
		
		if not will_make_progress:
			break
		
		if apply_hint(best_hint):
			applied_hint = true
		else:
			break
	
	# If hint-based solving succeeded, store solution
	if sbrc_grid.is_complete():
		solution_grid = grid.duplicate(true)
		has_solution = true
		# Restore original state
		grid = original_state
		sbrc_grid.update_grid(grid)
		return true
	
	# Fall back to backtracking solver
	print("Hint-based solving incomplete, trying backtracking...")
	grid = original_state
	sbrc_grid.update_grid(grid)
	var solutions = solve_with_backtracking(1)
	print("Backtracking solver returned %d solutions" % solutions.size())
	
	if solutions.size() > 0:
		solution_grid = solutions[0]
		has_solution = true
		# Restore original state
		grid = original_state
		sbrc_grid.update_grid(grid)
		return true
	
	# No solution found
	solution_grid = []
	has_solution = false
	return false

func _find_best_hint_for_solving(hints: Array) -> Variant:
	# Priority 1: Single Candidate / Hidden Single (direct placement)
	for hint in hints:
		if hint.technique == Hint.HintTechnique.SINGLE_CANDIDATE or hint.technique == Hint.HintTechnique.HIDDEN_SINGLE:
			if hint.cells.size() == 1 and hint.numbers.size() == 1:
				return hint
	
	# Priority 2: Any other hint that provides eliminations
	for hint in hints:
		if not hint.elim_cells.is_empty():
			return hint
	
	return null

func _solve_recursive(cell_index: int, empty_cells: Array, solutions: Array, num_solutions_to_find: int):
	if solutions.size() >= num_solutions_to_find:
		return

	if cell_index >= empty_cells.size():
		solutions.append(grid.duplicate(true))
		return

	var cell = empty_cells[cell_index]
	var r = cell.x
	var c = cell.y

	for num in range(1, 10):
		if sbrc_grid.is_valid_placement(r, c, num):
			grid[r][c] = num
			_solve_recursive(cell_index + 1, empty_cells, solutions, num_solutions_to_find)
			grid[r][c] = 0 # backtrack

			if solutions.size() >= num_solutions_to_find:
				return

func get_grid_as_string() -> String:
	var s = ""
	for r in range(9):
		for c in range(9):
			s += str(grid[r][c])
	return s

func apply_hint(hint: Hint) -> bool:
	# Placement hints
	if hint.cells.size() == 1 and hint.numbers.size() == 1 and hint.elim_cells.is_empty():
		var cell = hint.cells[0]
		var num = hint.numbers[0]
		if grid[cell.x][cell.y] == 0:
			var result = set_number(cell.x, cell.y, num)
			return result["success"]

	# Elimination hints
	if not hint.elim_cells.is_empty() and not hint.elim_numbers.is_empty():
		var changed = false
		for cell in hint.elim_cells:
			for num in hint.elim_numbers:
				if not has_exclude_mark(cell.x, cell.y, num):
					set_exclude_mark(cell.x, cell.y, num, true)
					changed = true
		if changed:
			sbrc_grid.update_grid(grid) # Re-evaluate candidates
			# After updating, also apply current exclude_bits to candidate masks
			for r in range(9):
				for c in range(9):
					var bits_to_exclude = exclude_bits[r][c]
					if bits_to_exclude > 0:
						sbrc_grid.candidates[r][c].data[0] &= ~bits_to_exclude

			# After eliminations, check if any cells became singles (naked singles)
			# This prevents infinite loops where eliminations don't lead to placements
			for r in range(9):
				for c in range(9):
					if grid[r][c] == 0:
						var cands = sbrc_grid.get_candidates_for_cell(r, c)
						var bits_to_exclude = exclude_bits[r][c]
						if bits_to_exclude > 0:
							cands = cands.clone()
							cands.data[0] &= ~bits_to_exclude
						if cands.cardinality() == 1:
							# Found a naked single - this should be detected in next iteration
							# but we return true to indicate progress was made
							pass
			
			return true
			
	return false
