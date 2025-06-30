## Attribution: https://github.com/StrmCkr/StormDoku/blob/main/src/main/java/sudoku/BasicGrid.java

class_name Cardinals

# cell to Box, cell -> rcb.
const Bxy: Array[int] = [
	0, 0, 0, 1, 1, 1, 2, 2, 2,
	0, 0, 0, 1, 1, 1, 2, 2, 2,
	0, 0, 0, 1, 1, 1, 2, 2, 2,
	3, 3, 3, 4, 4, 4, 5, 5, 5,
	3, 3, 3, 4, 4, 4, 5, 5, 5,
	3, 3, 3, 4, 4, 4, 5, 5, 5,
	6, 6, 6, 7, 7, 7, 8, 8, 8,
	6, 6, 6, 7, 7, 7, 8, 8, 8,
	6, 6, 6, 7, 7, 7, 8, 8, 8
]

# Square call, cell -> idx.
const BxyN: Array[int] = [
	0, 1, 2, 0, 1, 2, 0, 1, 2,
	3, 4, 5, 3, 4, 5, 3, 4, 5,
	6, 7, 8, 6, 7, 8, 6, 7, 8,
	0, 1, 2, 0, 1, 2, 0, 1, 2,
	3, 4, 5, 3, 4, 5, 3, 4, 5,
	6, 7, 8, 6, 7, 8, 6, 7, 8,
	0, 1, 2, 0, 1, 2, 0, 1, 2,
	3, 4, 5, 3, 4, 5, 3, 4, 5,
	6, 7, 8, 6, 7, 8, 6, 7, 8
]

# Pencil Numbers
const PencilN: Array[int] = [1,2,3,4,5,6,7,8,9]

static func box_to_rc(box: int, index: int) -> Vector2i:
	var box_row = box / 3
	var box_col = box % 3
	var cell_row = index / 3
	var cell_col = index % 3
	return Vector2i(
		box_row * 3 + cell_row,
		box_col * 3 + cell_col
	)

static func rc_to_vec(rc_idx: int) -> Vector2i:
	return Vector2i(rc_idx / 9, rc_idx % 9)

static func vec_to_rc(vec: Vector2i) -> int:
	return vec.x * 9 + vec.y
