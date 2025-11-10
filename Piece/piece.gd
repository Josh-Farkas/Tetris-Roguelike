class_name Piece extends Node

@export var data: PieceData
var cells: Array[Cell] = []
var coords: Vector2i:
	set(value):
		# move all cells when this moves
		_update_cell_coords(coords, value)
		coords = value
var rotation: int = 0
var cell_matrix: Array[Array] = []
var shadow_offset: Vector2i = Vector2i(0, coords.y)
var display_offset: bool = false



func move(dir: Vector2i) -> void:
	coords += dir


func _update_cell_coords(old_coords: Vector2i, new_coords: Vector2i) -> void:
	for cell: Cell in cells:
		cell.move(new_coords - old_coords)


func rotate(rot: int = 1) -> void:
	if rot == 0: return
	rotation += rot
	rotation %= 4
	for __: int in range(abs(rot)):
		if rot > 0:
			cell_matrix = _rotate_array(cell_matrix)
		else:
			cell_matrix = _rotate_array_inv(cell_matrix)
	
	for row: int in range(len(cell_matrix)):
		for col: int in range(len(cell_matrix[row])):
			var cell: Cell = cell_matrix[row][col]
			if cell == null: continue
			# move cell coords based on change in offset
			cell.move(-cell.offset + Vector2i(col, row))
			cell.offset = Vector2i(col, row)

func set_rotation(rot: int) -> void:
	rotate(rot - rotation)


func _rotate_array(arr: Array[Array]) -> Array[Array]:
	var new_arr: Array[Array] = []
	if arr == []:
		push_error("Failed to Rotate Array.")
	for i: int in range(len(arr[0])):
		var row: Array[Cell] = []
		for j: int in range(len(arr)):
			row.append(arr[len(arr) - j - 1][i])
		new_arr.append(row)
	return new_arr


func _rotate_array_inv(arr: Array) -> Array[Array]:
	var new_arr: Array[Array] = []
	for i: int in range(len(arr[0]) - 1, -1, -1):
		var row: Array[Cell] = []
		for j: int in range(len(arr)):
			row.append(arr[j][i])
		new_arr.append(row)
	return new_arr
