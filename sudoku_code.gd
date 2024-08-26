extends RefCounted
class_name Sudoku

const BasicGrid = preload("res://StormDoku/BasicGrid.gd")
const Tools = preload("res://StormDoku/Tools.gd")


# Properties
var grid: BasicGrid
var original_grid: BasicGrid
var sbrcgrid: SBRCGrid = SBRCGrid.new(grid)
var pencil: Array = []
var exclude: Array = []
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

# Initialization
func _init():
	grid = BasicGrid.new()
	original_grid = BasicGrid.new()
	_generate_pencil_grid()
	sbrcgrid = SBRCGrid.new(grid)

func _generate_pencil_grid():
	pencil = []
	for _i in range(9):
		var row = []
		for _j in range(9):
			var col = []
			for _k in range(9):
				col.append(false)
			row.append(col)
		pencil.append(row)
		exclude.append(row.duplicate(true))

# Puzzle Loading
func puzzle_file(path: String) -> bool:
	return load_puzzle(path, 0)

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
			return load_puzzle_from_string(puzzle_data, puzzle_index)
	   
		line_count += 1
   
	print("Puzzle index out of range")
	return false

func load_puzzle_from_string(puzzle_data: Dictionary, puzzle_index: int = 0) -> bool:
	if puzzle_data.is_empty():
		print("Invalid puzzle data")
		return false
   
	grid = BasicGrid.new()
	for row in range(9):
		for col in range(9):
			var value = puzzle_data["grid"][row][col]
			if value != 0:
				grid.set_solved(row * 9 + col, value - 1, true)
	
	original_grid = BasicGrid.new()
	original_grid.data = grid.data.duplicate()
	current_puzzle_name = puzzle_data.get("name", "Puzzle " + str(puzzle_index + 1))
	current_puzzle_difficulty = puzzle_data["difficulty"]
	current_puzzle_index = puzzle_index
	_generate_pencil_grid()

	return true

func fast_parse_puzzle_line(line: String) -> Dictionary:
	var result = {}
	var difficulty = line.substr(95, 4).strip_edges()
   
	result["difficulty"] = difficulty
	
	if line.length() > 99:
		result["name"] = line.substr(99).strip_edges()
   
	return result

func parse_puzzle_line(line: String) -> Dictionary:
	var result = {}
   
	if line.length() < 99:
		result["difficulty"] = "Unknown"
		result["hashstr"] = "Unknown"
		result["grid"] = string_to_grid(line.substr(0, 81))
		result["name"] = puzzle_selected
		return result
   
	var hashstr = line.substr(0, 12)
	var puzzle_string = line.substr(13, 81)
	var difficulty = line.substr(95, 4).strip_edges()
   
	result["hashstr"] = hashstr
	result["difficulty"] = difficulty
	result["grid"] = string_to_grid(puzzle_string)
   
	if line.length() > 99:
		result["name"] = line.substr(99).strip_edges()
   
	return result

func string_to_grid(puzzle_string: String) -> Array:
	var _grid = []
	for i in range(9):
		var row = []
		for j in range(9):
			var index = i * 9 + j
			var value = int(puzzle_string[index])
			row.append(value)
		_grid.append(row)
	return _grid

func is_valid_move(cell: int, num: int) -> bool:
	return grid.has_candidate(cell, num-1)

func is_solved_number(cell: int, num: int) -> bool:
	return !grid.has_candidate(cell, num-1)

func _get_valid_numbers(row: int, col: int) -> Array:
	var valid_numbers = []
	var cell = row * 9 + col
	if grid.is_solved(cell):
		return valid_numbers

	for num in range(1, 10):
		if grid.has_candidate(cell, num - 1):
			valid_numbers.append(num)

	return valid_numbers

func set_number(row: int, col: int, num: int) -> bool:
	if is_valid_move(((row*9)+col), num) && !_is_given_number(row, col):
		store_number_history(row, col, grid.get_solved(row * 9 + col))
		grid.set_solved(row * 9 + col, num - 1, false)
	   
		# Clear all pencil marks from the cell
		for i in range(9):
			if pencil[row][col][i]:
				store_pencil(row, col, i+1, false)
			if exclude[row][col][i]:
				store_exclude(row, col, i+1, false)
	   
		# Clear pencil marks of the number from the block, row, and column
		var block_row = (row / 3) * 3
		var block_col = (col / 3) * 3
		for r in range(9):
			for c in range(9):
				if (r >= block_row and r < block_row + 3 and c >= block_col and c < block_col + 3) or r == row or c == col:
					if pencil[r][c][num-1]:
						store_pencil(r, c, num, false)
					if exclude[r][c][num-1]:
						store_exclude(r, c, num, false)
		return true
	return false

func clear_number(row: int, col: int):
	store_number_history(row, col, grid.get_solved(row * 9 + col))
	grid.set_cell_bits(row * 9 + col, grid.ones(Cardinals.rcbs))

func is_completed() -> bool:
	return grid.get_num_solved() == Cardinals.Length

# Pencil Marks and Exclude
func auto_fill_pencil_marks():
	for row in range(9):
		for col in range(9):
			var valid_numbers = _get_valid_numbers(row, col)
			if valid_numbers.size() > 0:
				for num in valid_numbers:
					store_pencil(row, col, num, true)

func swap_pencil(row: int, col:int, num:int) -> void:
	store_pencil(row, col, num, !pencil[row][col][num-1])

func store_pencil(row: int, col:int, num:int, state:bool, keep_history:bool = true) -> void:
	if exclude[row][col][num-1] == true:
		store_exclude(row, col, num, false, keep_history)
		return
	pencil_history.append([row, col, num, pencil[row][col][num-1]])
	pencil[row][col][num-1] = state
	history.append(1)

func swap_exclude(row: int, col:int, num:int) -> void:
	store_exclude(row, col, num, !exclude[row][col][num-1])

func store_exclude(row: int, col:int, num:int, state:bool, keep_history:bool = true) -> void:
	if pencil[row][col][num-1] == true:
		store_pencil(row, col, num, false, keep_history)
		return
	exclude_history.append([row, col, num, exclude[row][col][num-1]])
	exclude[row][col][num-1] = state
	history.append(2)

# History Management
func store_number_history(row: int, col:int, num:int) -> void:
	number_history.append([row, col, num])
	history.append(0)

func clear_history() -> void:
	history = []
	number_history = []
	pencil_history = []
	exclude_history = []

func undo_number_history() -> void:
	if number_history.size() > 0:
		var last = number_history.pop_back()
		if last[2] == -1:
			grid.set_cell_bits(last[0] * 9 + last[1], grid.ones(Cardinals.rcbs))
		else:
			grid.set_solved(last[0] * 9 + last[1], last[2], false)

func undo_pencil_history() -> void:
	if pencil_history.size() > 0:
		var last = pencil_history.pop_back()
		pencil[last[0]][last[1]][last[2]-1] = last[3]

func undo_exclude_history() -> void:
	if exclude_history.size() > 0:
		var last = exclude_history.pop_back()
		exclude[last[0]][last[1]][last[2]-1] = last[3]

func undo_history() -> void:
	var keep_undoing = true
	while keep_undoing:
		if history.size() > 0:
			match history.pop_back():
				0:
					undo_number_history()
					keep_undoing = false
				1:
					undo_pencil_history()
				2:
					undo_exclude_history()
		else:
			keep_undoing = false

# Utility Functions
func _is_given_number(row: int, col: int) -> bool:
	return grid.is_given(row * 9 + col)

func get_cell_value(cell: int) -> int:
	var solved = grid.get_solved(cell)
	return solved + 1 if solved != -1 else 0

func is_given_number(cell: int) -> bool:
	return grid.is_given(cell)

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
	var count = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	var needed = [true, true, true, true, true, true, true, true, true]

	for cell in range(Cardinals.Length):
		if grid.is_solved(cell):
			var cell_bits = grid.get_cell_bits(cell)
			for bit in range(9):
				if cell_bits & (1 << bit):
					count[bit] += 1

	for i in range(9):
		if count[i] == 9:
			needed[i] = false

	return needed

# Save and Load functions
func save_state(file_path: String) -> bool:
	var config = ConfigFile.new()
	if config.load(file_path) != OK:
		config = ConfigFile.new()

	var puzzle_saves = config.get_value("puzzle_saves", "puzzles", [])
	var save_data = {
		"grid_data": grid.data,
		"original_grid_data": original_grid.data,
		"pencil": pencil,
		"exclude": exclude,
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
	
	var existing_save_index = -1
	for i in range(puzzle_saves.size()):
		if puzzle_saves[i].get("current_puzzle_difficulty") == current_puzzle_difficulty and \
		   puzzle_saves[i].get("current_puzzle_index") == current_puzzle_index:
			existing_save_index = i
			break
	
	if existing_save_index != -1:
		puzzle_saves[existing_save_index] = save_data
	else:
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
			if save.get("current_puzzle_difficulty") == difficulty and save.get("current_puzzle_index") == index:
				save_to_load = save
				break
	
	if save_to_load == null:
		return false
	
	grid = BasicGrid.new()
	grid.data = save_to_load.get("grid_data", [])
	original_grid = BasicGrid.new()
	original_grid.data = save_to_load.get("original_grid_data", [])
	pencil = save_to_load.get("pencil", [])
	exclude = save_to_load.get("exclude", [])
	history = save_to_load.get("history", [])
	number_history = save_to_load.get("number_history", [])
	pencil_history = save_to_load.get("pencil_history", [])
	exclude_history = save_to_load.get("exclude_history", [])
	current_puzzle_name = save_to_load.get("current_puzzle_name", "")
	current_puzzle_difficulty = save_to_load.get("current_puzzle_difficulty", "")
	current_puzzle_index = save_to_load.get("current_puzzle_index", -1)
	puzzle_selected = save_to_load.get("puzzle_selected", "")
	puzzle_time = save_to_load.get("puzzle_time", 0)
	
	return true

func save_completed_puzzle() -> bool:
	var config = ConfigFile.new()
	var full_file_path =  "user://" + puzzle_selected + ".cfg"
	
	if config.load(full_file_path) != OK:
		config = ConfigFile.new()
	
	var completed_puzzles = config.get_value("completed", "puzzles", [])
	var completed_puzzle = {
		"grid_data": grid.data,
		"original_grid_data": original_grid.data,
		"current_puzzle_index": current_puzzle_index,
		"puzzle_time": puzzle_time
	}
	completed_puzzles.append(completed_puzzle)
	config.set_value("completed", "puzzles", completed_puzzles)

	var puzzle_saves = config.get_value("puzzle_saves", "puzzles", [])
	var updated_puzzle_saves = []
	for save in puzzle_saves:
		if save.get("current_puzzle_difficulty") != current_puzzle_difficulty or \
		   save.get("current_puzzle_index") != current_puzzle_index:
			updated_puzzle_saves.append(save)
	config.set_value("puzzle_saves", "puzzles", updated_puzzle_saves)

	return config.save(full_file_path) == OK

func load_puzzle_data(difficulty: String):
	var file = FileAccess.open(puzzles[difficulty], FileAccess.READ)
	if file == null:
		print("Failed to open Puzzle File")
		return {}
	puzzle_data = []
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
		if save.get("puzzle_selected") == difficulty and save.get("current_puzzle_index") == puzzle_index:
			return true
	
	return false

func get_pencil(cell: int, num: int) -> bool:
	return pencil[cell / 9][cell % 9][num]

func get_exclude(cell: int, num: int) -> bool:
	return exclude[cell / 9][cell % 9][num]
