class_name Piece extends Node

@export var data: PieceData
var cells: Array[Cell] = []
var coords: Vector2i:
	set(value):
		# move all cells when this moves
		for cell: Cell in cells:
			cell.coords += value - coords
		coords = value
var rotation: int = 0
var cell_matrix: Array = []
var shadow_offset: Vector2i = Vector2i(0, coords.y)
var display_offset: bool = false
var active := false



func _ready() -> void:
	display_offset = data.shape in [PieceData.Shape.T, PieceData.Shape.L, PieceData.Shape.J, PieceData.Shape.S, PieceData.Shape.Z]


func move(dir: Vector2i) -> void:
	coords += dir

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
			cell.coords -= cell.offset
			cell.offset = Vector2i(col, row)
			cell.coords += cell.offset


func set_rotation(rot: int) -> void:
	rotate(rot - rotation)


func _rotate_array(arr: Array) -> Array:
	var new_arr: Array = []
	for i: int in range(len(arr[0])):
		var row: Array = []
		for j: int in range(len(arr)):
			row.append(arr[len(arr) - j - 1][i])
		new_arr.append(row)
	return new_arr


func _rotate_array_inv(arr: Array) -> Array:
	var new_arr: Array = []
	for i: int in range(len(arr[0]) - 1, -1, -1):
		var row: Array = []
		for j: int in range(len(arr)):
			row.append(arr[j][i])
		new_arr.append(row)
	return new_arr
