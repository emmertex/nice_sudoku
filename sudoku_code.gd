extends RefCounted
class_name Sudoku

# Properties
var grid: Array = []
var original_grid: Array = []
var pencil_bits: Array = []  # 9x9 array of integers
var exclude_bits: Array = [] # 9x9 array of integers
var history: Array = []
var number_history: Array = []
var pencil_history: Array = []
var exclude_history: Array = []
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

func load_puzzle(puzzle_file: String, puzzle_index: int) -> bool:
	var file = FileAccess.open(puzzle_file, FileAccess.READ)
	if file == null:
		print("Failed to open Puzzle File")
		return false
	var line_count = 0
	while not file.eof_reached():
		var line = file.get_line()
		if line_count == puzzle_index:
			var puzzle_data = parse_puzzle_line(line)
			return load_puzzle_from_dictionary(puzzle_data, puzzle_index)
	   
		line_count += 1
   
	print("Puzzle index out of range")
	return false

func load_puzzle_from_dictionary(puzzle_data: Dictionary, puzzle_index: int = 0) -> bool:
	if puzzle_data.is_empty():
		print("Invalid puzzle data")
		return false
	_init()
	grid = puzzle_data["grid"]
	original_grid = grid.duplicate(true)
	current_puzzle_name = puzzle_data.get("name", "Puzzle " + str(puzzle_index + 1))
	current_puzzle_difficulty = puzzle_data["difficulty"]
	current_puzzle_index = puzzle_index
	sbrc_grid.update_grid(grid)
	_clear_history()
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
		# Iterate over every character from 162 to 891
		for i in range(162, 891):
			var row = (i - 162) / 81
			var col = ((i - 162) % 81) / 9
			var num = (i - 162) % 9
			if line[i] == "1":
				pencil_bits[row][col] |= (1 << (num - 1))
				exclude_bits[row][col] &= ~(1 << (num - 1))
			elif line[i] == "2":
				exclude_bits[row][col] |= (1 << (num - 1))
				pencil_bits[row][col] &= ~(1 << (num - 1))
			else:
				pencil_bits[row][col] &= ~(1 << (num - 1))
				exclude_bits[row][col] &= ~(1 << (num - 1))
	else:
		return false

	sbrc_grid.update_grid(grid)
	_clear_history()
	current_puzzle_index = 0
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
			var char = puzzle_string[index]
			var value = 0
			if char != ".":
				value = int(char)
			row.append(value)
		_grid.append(row)
	return _grid

func _set_grid(puzzle: Array):
	assert(len(puzzle) == 9 and len(puzzle[0]) == 9, "Invalid puzzle dimensions")
	grid = puzzle.duplicate(true)
	original_grid = grid.duplicate(true)

func is_valid_move(row: int, col: int, num: int) -> bool:
	return sbrc_grid.is_valid_placement(row, col, num)

func get_candidates_for_cell(row: int, col: int) -> BitSet:
	return sbrc_grid.get_candidates_for_cell(row, col)
	
func set_number(row: int, col: int, num: int) -> bool:
	if is_valid_move(row, col, num) && !is_given_number(row, col):
		store_number_history(row, col, grid[row][col])
		grid[row][col] = num
		
		sbrc_grid.set_cell_value(row, col, num)
	   
		# Clear all pencil marks from the cell
		for i in range(9):
			if has_pencil_mark(row, col, i+1):
				set_pencil_mark(row, col, i+1, false)
			if has_exclude_mark(row, col, i+1):
				set_exclude_mark(row, col, i+1, false)
	   
		# Clear pencil marks of the number from the block
		var block_row = (row / 3) * 3
		var block_col = (col / 3) * 3
		for r in range(block_row, block_row + 3):
			for c in range(block_col, block_col + 3):
				if has_pencil_mark(r, c, num):
					set_pencil_mark(r, c, num, false)
				if has_exclude_mark(r, c, num):
					set_exclude_mark(r, c, num, false)
		# Clear pencil marks of the number from the row
		for c in range(9):
			if has_pencil_mark(row, c, num):
				set_pencil_mark(row, c, num, false)
			if has_exclude_mark(row, c, num):
				set_exclude_mark(row, c, num, false)
		# Clear pencil marks of the number from the column
		for r in range(9):
			if has_pencil_mark(r, col, num):
				set_pencil_mark(r, col, num, false)
			if has_exclude_mark(r, col, num):
				set_exclude_mark(r, col, num, false)
		return true
	return false

func clear_number(row: int, col: int):
	store_number_history(row, col, grid[row][col])
	grid[row][col] = 0
	
	sbrc_grid.set_cell_value(row, col, 0)
	

func is_completed() -> bool:
		return sbrc_grid.is_complete()
	

# Pencil Marks and Exclude
func auto_fill_pencil_marks():
	sbrc_grid.update_grid(grid)
	clear_all_pencil_marks()
	for row in range(9):
		for col in range(9):
			if grid[row][col] == 0:
				var candidates = sbrc_grid.get_candidates_for_cell(row, col)
				var mask = 0
				for i in range(9):
					if candidates.get_bit(i):
						mask |= (1 << i)
				
				if pencil_bits[row][col] != mask:
					pencil_history.append([row, col, pencil_bits[row][col]])
					history.append(1) # Pencil mark history
					pencil_bits[row][col] = mask
					exclude_bits[row][col] = 0

func clear_all_pencil_marks():
	for row in range(9):
		for col in range(9):
			if pencil_bits[row][col] != 0:
				pencil_history.append([row, col, pencil_bits[row][col]])
				history.append(1)
				pencil_bits[row][col] = 0
			if exclude_bits[row][col] != 0:
				exclude_history.append([row, col, exclude_bits[row][col]])
				history.append(2)
				exclude_bits[row][col] = 0

func swap_pencil(row: int, col: int, num: int) -> void:
	pencil_history.append([row, col, pencil_bits[row][col]])
	history.append(3)
	if has_pencil_mark(row, col, num):
		set_pencil_mark(row, col, num, false)
	else:
		set_pencil_mark(row, col, num, true)
		set_exclude_mark(row, col, num, false) # Always clear exclude

func swap_exclude(row: int, col: int, num: int) -> void:
	exclude_history.append([row, col, exclude_bits[row][col]])
	history.append(4)
	if has_exclude_mark(row, col, num):
		set_exclude_mark(row, col, num, false)
	else:
		set_exclude_mark(row, col, num, true)
		set_pencil_mark(row, col, num, false) # Always clear pencil

# History Management
func store_number_history(row: int, col:int, num:int) -> void:
	number_history.append([row, col, num])
	history.append(0)

func _clear_history() -> void:
	history = []
	number_history = []
	pencil_history = []
	exclude_history = []

func undo_history() -> void:
	if history.size() == 0:
		return
	
	# Create snapshot for safety
	var snapshot = _create_snapshot()
	
	# Perform undo operation
	var operation = history.pop_back()
	var success = false
	
	match operation:
		0: success = _undo_number_safe()
		1: success = _undo_pencil_safe()
		2: success = _undo_exclude_safe()
		3: success = _undo_pencil_safe()
		4: success = _undo_exclude_safe()
	
	# Validate and restore if needed
	if not success or not _validate_grid_state():
		_restore_snapshot(snapshot)
		print("Warning: Invalid undo operation, state restored")

func _create_snapshot() -> Dictionary:
	return {
		"grid": grid.duplicate(true),
		"pencil_bits": pencil_bits.duplicate(true),
		"exclude_bits": exclude_bits.duplicate(true),
		"history": history.duplicate(true),
		"number_history": number_history.duplicate(true),
		"pencil_history": pencil_history.duplicate(true),
		"exclude_history": exclude_history.duplicate(true)
	}

func _restore_snapshot(snapshot: Dictionary):
	grid = snapshot.grid
	pencil_bits = snapshot.pencil_bits
	exclude_bits = snapshot.exclude_bits
	history = snapshot.history
	number_history = snapshot.number_history
	pencil_history = snapshot.pencil_history
	exclude_history = snapshot.exclude_history
	sbrc_grid = SBRCGrid.new(grid)

func _validate_grid_state() -> bool:
	return sbrc_grid.get_conflicts().size() == 0
	
func _undo_number_safe() -> bool:
	if number_history.size() > 0:
		var last = number_history.pop_back()
		grid[last[0]][last[1]] = last[2]
		sbrc_grid.set_cell_value(last[0], last[1], last[2])
		return true
	return false

func _undo_pencil_safe() -> bool:
	if pencil_history.size() > 0:
		var last = pencil_history.pop_back()
		pencil_bits[last[0]][last[1]] = last[2]
		return true
	return false

func _undo_exclude_safe() -> bool:
	if exclude_history.size() > 0:
		var last = exclude_history.pop_back()
		exclude_bits[last[0]][last[1]] = last[2]
		return true
	return false

func find_naked_singles() -> Array:
	var singles = []
	for row in range(9):
		for col in range(9):
			if grid[row][col] == 0:
				var candidates = sbrc_grid.get_candidates_for_cell(row, col)
				if candidates.cardinality() == 1:
					var digit = candidates.next_set_bit(0) + 1
					singles.append({
						"row": row,
						"col": col,
						"digit": digit
					})
	return singles

func find_hidden_singles() -> Array:
	var singles = []
	var found_cells = BitSet.new(81)

	# Check rows
	for r in range(9):
		for d in range(9):  # digit-1
			var possible_cols = []
			for c in range(9):
				if grid[r][c] == 0:
					var cell_candidates = sbrc_grid.get_candidates_for_cell(r, c)
					if cell_candidates.get_bit(d):
						possible_cols.append(c)
			
			if possible_cols.size() == 1:
				var c = possible_cols[0]
				var cell_index = r * 9 + c
				if not found_cells.get_bit(cell_index):
					singles.append({
						"row": r,
						"col": c,
						"digit": d + 1,
						"type": "row"
					})
					found_cells.set_bit(cell_index)

	# Check columns
	for c in range(9):
		for d in range(9):  # digit-1
			var possible_rows = []
			for r in range(9):
				if grid[r][c] == 0:
					var cell_candidates = sbrc_grid.get_candidates_for_cell(r, c)
					if cell_candidates.get_bit(d):
						possible_rows.append(r)

			if possible_rows.size() == 1:
				var r = possible_rows[0]
				var cell_index = r * 9 + c
				if not found_cells.get_bit(cell_index):
					singles.append({
						"row": r,
						"col": c,
						"digit": d + 1,
						"type": "column"
					})
					found_cells.set_bit(cell_index)

	# Check boxes
	for b in range(9):
		for d in range(9):  # digit-1
			var possible_cells = []
			for i in range(9):
				var cell_pos = Cardinals.box_to_rc(b, i)
				var r = cell_pos.x
				var c = cell_pos.y
				if grid[r][c] == 0:
					var cell_candidates = sbrc_grid.get_candidates_for_cell(r, c)
					if cell_candidates.get_bit(d):
						possible_cells.append(cell_pos)

			if possible_cells.size() == 1:
				var cell_pos = possible_cells[0]
				var r = cell_pos.x
				var c = cell_pos.y
				var cell_index = r * 9 + c
				if not found_cells.get_bit(cell_index):
					singles.append({
						"row": r,
						"col": c,
						"digit": d + 1,
						"type": "box"
					})
					found_cells.set_bit(cell_index)
	
	return singles

func get_conflicts() -> Array:
	return sbrc_grid.get_conflicts()


func get_empty_cells() -> Array:
	return sbrc_grid.get_empty_cells()

# Utility Functions
func int_to_binary_string(value: int) -> String:
	var binary = ""
	var temp = value
	while temp > 0:
		binary = str(temp % 2) + binary
		temp = temp / 2
	return binary if binary != "" else "0"

func is_given_number(row: int, col: int) -> bool:
	return original_grid[row][col] != 0

# Puzzle Information
func get_puzzle_index() -> int:
	return current_puzzle_index

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
		"history": history,
		"number_history": number_history,
		"pencil_history": pencil_history,
		"exclude_history": exclude_history,
		"current_puzzle_name": current_puzzle_name,
		"current_puzzle_difficulty": current_puzzle_difficulty,
		"current_puzzle_index": current_puzzle_index,
		"puzzle_selected": puzzle_selected,
		"puzzle_time": puzzle_time
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
			print("Save to load: " + str(save.puzzle_selected) + " " + str(save.current_puzzle_index))
			if save.puzzle_selected == difficulty and save.current_puzzle_index == index:
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
	
	history = save_to_load.history
	number_history = save_to_load.number_history
	pencil_history = save_to_load.pencil_history
	exclude_history = save_to_load.exclude_history
	current_puzzle_name = save_to_load.current_puzzle_name
	current_puzzle_difficulty = save_to_load.current_puzzle_difficulty
	current_puzzle_index = save_to_load.current_puzzle_index
	puzzle_selected = save_to_load.puzzle_selected
	puzzle_time = save_to_load.puzzle_time
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
	var line_count = 0
	while not file.eof_reached():
		puzzle_data.append(fast_parse_puzzle_line(file.get_line()))
	
func get_puzzle_data(index: int) -> Dictionary:
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
		if save.puzzle_selected == difficulty and save.current_puzzle_index == puzzle_index:
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

func set_pencil_mark(row: int, col: int, num: int, value: bool):
	if value:
		pencil_bits[row][col] |= (1 << (num - 1))
	else:
		pencil_bits[row][col] &= ~(1 << (num - 1))

func has_exclude_mark(row: int, col: int, num: int) -> bool:
	return (exclude_bits[row][col] & (1 << (num - 1))) != 0

func set_exclude_mark(row: int, col: int, num: int, value: bool):
	if value:
		exclude_bits[row][col] |= (1 << (num - 1))
	else:
		exclude_bits[row][col] &= ~(1 << (num - 1))

func get_grid_value(row: int, col: int) -> int:
	return grid[row][col]

func get_grid_given(row: int, col: int) -> bool:
	return original_grid[row][col] != 0

func solve_with_backtracking(max_solutions: int = 1) -> Array:
	var solutions = []
	_solve_recursive(grid.duplicate(true), solutions, max_solutions)
	return solutions

func _solve_recursive(current_grid: Array, solutions: Array, max_solutions: int):
	if solutions.size() >= max_solutions:
		return

	# Find empty cell with fewest candidates
	var best_cell = Vector2i(-1, -1)
	var min_candidates = 10
	
	var temp_sudoku = Sudoku.new()
	temp_sudoku.load_puzzle_from_dictionary({"grid": current_grid, "difficulty": "temp"})
	
	for r in range(9):
		for c in range(9):
			if current_grid[r][c] == 0:
				var candidates = temp_sudoku.sbrc_grid.get_candidates_for_cell(r, c)
				var num_candidates = candidates.cardinality()
				if num_candidates < min_candidates:
					min_candidates = num_candidates
					best_cell = Vector2i(r, c)

	if best_cell == Vector2i(-1, -1):
		# No empty cells, solution found
		solutions.append(current_grid)
		return

	# Try candidates for the best cell
	var candidates = temp_sudoku.sbrc_grid.get_candidates_for_cell(best_cell.x, best_cell.y)
	for i in range(9):
		if candidates.get_bit(i):
			var num = i + 1
			var next_grid = current_grid.duplicate(true)
			next_grid[best_cell.x][best_cell.y] = num
			_solve_recursive(next_grid, solutions, max_solutions)
			if solutions.size() >= max_solutions:
				return
