extends RefCounted
class_name Sudoku

# Properties
var grid: Array = []
var original_grid: Array = []
var Rn: Array = []
var Cn: Array = []
var Bn: Array = []
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
var difficulty_index: Dictionary = {
	"easy": 0,
	"medium": 1,
	"hard": 2,
	"expert": 3
}

# Initialization
func _init():
	_generate_empty_grid()
	_generate_pencil_grid()

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
	pencil = []
	exclude = []
	for _i in range(9):
		var row = []
		for _j in range(9):
			var col = []
			for _k in range(9):
				col.append(false)
			row.append(col)
		pencil.append(row)
		exclude.append(row)

func generate_RnCnBn():
	Rn = []
	Cn = []
	Bn = []	
	for i in range(9):
		Rn.append([0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF])
		Cn.append([0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF])
		Bn.append([0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF])
	for cell in range(Cardinals.Length):
		var row = Cardinals.Rx[cell]
		var col = Cardinals.Cy[cell]
		var value = grid[row][col]
	   
		if value != 0:
			var mask = ~(1 << (value - 1))
			var box = Cardinals.Bxy[cell]
			for i in range(9):
				Rn[row][i] &= mask
				Cn[i][col] &= mask
				var rc = Cardinals.box_to_rc(box, i)
				Bn[rc.x][rc.y] &= mask

func load_puzzle(puzzle_file: String, puzzle_index: int) -> bool:
	var file = FileAccess.open(puzzle_file, FileAccess.READ)
	if file == null:
		print("Failed to open Puzzle File")
		return false
	_init()
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
	generate_RnCnBn()
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
				pencil[row][col][num] = true
				exclude[row][col][num] = false
			elif line[i] == "2":
				exclude[row][col][num] = true
				pencil[row][col][num] = false
			else:
				pencil[row][col][num] = false
				exclude[row][col][num] = false
	else:
		return false

	generate_RnCnBn()
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
			var value = int(puzzle_string[index])
			row.append(value)
		_grid.append(row)
	return _grid

func _set_grid(puzzle: Array):
	assert(len(puzzle) == 9 and len(puzzle[0]) == 9, "Invalid puzzle dimensions")
	grid = puzzle.duplicate(true)
	original_grid = grid.duplicate(true)

# Game Logic
func is_valid_move(row: int, col: int, num: int) -> bool:
	if (row < 0 || row > 8 || col < 0 || col > 8 || num < 1 || num > 9):
		return false

	#print("Row" + str(Rn[row][col]) + "   " + int_to_binary_string(Rn[row][col]))
	#print("Col" + str(Cn[row][col]) + "   " + int_to_binary_string(Cn[row][col]))
	#print("Box" + str(Bn[row][col]) + "   " + int_to_binary_string(Bn[row][col]))
   
	var mask:int = 1 << (num - 1)


	var row_mask:int = Rn[row][col] & mask
	var col_mask:int = Cn[row][col] & mask
	var box_mask:int = Bn[row][col] & mask
	return row_mask == mask && col_mask == mask && box_mask == mask

func _get_valid_numbers(row: int, col: int) -> Array:
	var valid_numbers = []
	if grid[row][col] != 0:
		return valid_numbers  # Cell is already filled

	var intersection = Rn[row][col] & Cn[row][col] & Bn[row][col]
	for num in range(1, 10):
		if intersection & (1 << (num - 1)) != 0:
			valid_numbers.append(num)

	return valid_numbers

func set_number(row: int, col: int, num: int) -> bool:
	if is_valid_move(row, col, num) && !is_given_number(row, col):
		store_number_history(row, col, grid[row][col])
		grid[row][col] = num
	   
		# Clear all pencil marks from the cell
		for i in range(9):
			if pencil[row][col][i]:
				store_pencil(row, col, i+1, false)
			if exclude[row][col][i]:
				store_exclude(row, col, i+1, false)
	   
		# Clear pencil marks of the number from the block
		var block_row = (row / 3) * 3
		var block_col = (col / 3) * 3
		for r in range(block_row, block_row + 3):
			for c in range(block_col, block_col + 3):
				if pencil[r][c][num-1]:
					store_pencil(r, c, num, false)
				if exclude[r][c][num-1]:
					store_exclude(r, c, num, false)
		# Clear pencil marks of the number from the row
		for c in range(9):
			if pencil[row][c][num-1]:
				store_pencil(row, c, num, false)
			if exclude[row][c][num-1]:
				store_exclude(row, c, num, false)
		# Clear pencil marks of the number from the column
		for r in range(9):
			if pencil[r][col][num-1]:
				store_pencil(r, col, num, false)
			if exclude[r][col][num-1]:
				store_exclude(r, col, num, false)
		return true
	return false

func clear_number(row: int, col: int):
	store_number_history(row, col, grid[row][col])
	grid[row][col] = 0
	generate_RnCnBn()

func is_completed() -> bool:
	for row in range(9):
		for col in range(9):
			if grid[row][col] == 0:
				return false
	print("Puzzle is completed")
	return true

# Pencil Marks and Exclude
func auto_fill_pencil_marks():
	generate_RnCnBn()
	for row in range(9):
		for col in range(9):
			var valid_numbers = _get_valid_numbers(row, col)
			for i in range(9):
				if i+1 in valid_numbers:
					pencil[row][col][i] = true
				else:
					pencil[row][col][i] = false


func swap_pencil(row: int, col:int, num:int) -> void:
	store_pencil(row, col, num, !pencil[row][col][num-1], true)

func store_pencil(row: int, col:int, num:int, state:bool, keep_history:bool = true, noreturn:bool = false) -> void:
	pencil_history.append([row, col, num, pencil[row][col][num-1]])
	pencil[row][col][num-1] = state
	if keep_history:
		history.append(3)
	else:
		history.append(1)
	if exclude[row][col][num-1] == true && noreturn == false:
		store_exclude(row, col, num, false, keep_history, true)

func swap_exclude(row: int, col:int, num:int) -> void:
	store_exclude(row, col, num, !exclude[row][col][num-1], true)

func store_exclude(row: int, col:int, num:int, state:bool, keep_history:bool = true, noreturn:bool = false) -> void:
	exclude_history.append([row, col, num, exclude[row][col][num-1]])
	exclude[row][col][num-1] = state
	if keep_history:
		history.append(4)
	else:
		history.append(2)
	if pencil[row][col][num-1] == true && noreturn == false:
		store_pencil(row, col, num, false, keep_history, true)

# History Management
func store_number_history(row: int, col:int, num:int) -> void:
	number_history.append([row, col, num])
	history.append(0)

func _clear_history() -> void:
	history = []
	number_history = []
	pencil_history = []
	exclude_history = []

func undo_number_history() -> void:
	if number_history.size() > 0:
		var last = number_history.pop_back()
		grid[last[0]][last[1]] = last[2]
		generate_RnCnBn()

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
					keep_undoing = false
				2:
					undo_exclude_history()
					keep_undoing = false
				3:
					undo_pencil_history()
				4:
					undo_exclude_history()
		else:
			keep_undoing = false

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
	pencil = save_to_load.pencil
	exclude = save_to_load.exclude
	history = save_to_load.history
	number_history = save_to_load.number_history
	pencil_history = save_to_load.pencil_history
	exclude_history = save_to_load.exclude_history
	current_puzzle_name = save_to_load.current_puzzle_name
	current_puzzle_difficulty = save_to_load.current_puzzle_difficulty
	current_puzzle_index = save_to_load.current_puzzle_index
	puzzle_selected = save_to_load.puzzle_selected
	puzzle_time = save_to_load.puzzle_time
	generate_RnCnBn()
	
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