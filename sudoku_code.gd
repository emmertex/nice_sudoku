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
var puzzle_selected: String = "easy"
var puzzles: Dictionary = {
	"easy": "res://puzzles/easy.txt",
	"medium": "res://puzzles/medium.txt", 
	"hard": "res://puzzles/hard.txt",
	"expert": "res://puzzles/diabolical.txt"
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
	for _i in range(9):
		var row = []
		for _j in range(9):
			var col = []
			for _k in range(9):
				col.append(false)
			row.append(col)
		pencil.append(row)
		exclude.append(row)

func _generate_RnCnBn():
	Rn = []
	Cn = []
	Bn = []	
	for i in range(9):
		Rn.append([0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF])
		Cn.append([0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF])
		Bn.append([0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF])
	update_RnCnBn()

func update_RnCnBn():
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
   
	grid = puzzle_data["grid"]
	original_grid = grid.duplicate(true)
	current_puzzle_name = puzzle_data.get("name", "Puzzle " + str(puzzle_index + 1))
	current_puzzle_difficulty = puzzle_data["difficulty"]
	current_puzzle_index = puzzle_index
	_generate_pencil_grid()

	_generate_RnCnBn()
	return true

func parse_puzzle_line(line: String) -> Dictionary:
	var result = {}
   
	print(line)
	print(line.length())

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

	print("Row" + str(Rn[row][col]) + "   " + int_to_binary_string(Rn[row][col]))
	print("Col" + str(Cn[row][col]) + "   " + int_to_binary_string(Cn[row][col]))
	print("Box" + str(Bn[row][col]) + "   " + int_to_binary_string(Bn[row][col]))
   
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
	if is_valid_move(row, col, num) && !_is_given_number(row, col):
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

func is_completed() -> bool:
	for row in range(9):
		for col in range(9):
			if grid[row][col] == 0:
				return false
	print("Puzzle is completed")
	return true

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
		grid[last[0]][last[1]] = last[2]

func undo_pencil_history() -> void:
	if pencil_history.size() > 0:
		var last = pencil_history.pop_back()
		pencil[last[0]][last[1]][last[2]-1] = last[3]

func undo_exclude_history() -> void:
	if exclude_history.size() > 0:
		var last = exclude_history.pop_back()
		exclude[last[0]][last[1]][last[2]-1] = last[3]

func undo_history() -> void:
	if history.size() > 0:
		match history.pop_back():
			0:
				undo_number_history()
			1:
				undo_pencil_history()
			2:
				undo_exclude_history()

# Utility Functions
func int_to_binary_string(value: int) -> String:
	var binary = ""
	var temp = value
	while temp > 0:
		binary = str(temp % 2) + binary
		temp = temp / 2
	return binary if binary != "" else "0"

func _is_given_number(row: int, col: int) -> bool:
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
