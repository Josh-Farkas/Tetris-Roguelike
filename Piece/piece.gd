class_name Piece extends Node

enum Shape {
	I, O, T, J, L, S, Z
}

enum COLOR {
	GREEN, BLUE, LIGHT_BLUE, RED, ORANGE, PURPLE
}

var shape_map: Dictionary = {
	Shape.I: Shapes.I,
	Shape.O: Shapes.O,
	Shape.T: Shapes.T,
	Shape.J: Shapes.J,
	Shape.L: Shapes.L,
	Shape.S: Shapes.S,
	Shape.Z: Shapes.Z,
}

const color_map: Dictionary = {
	COLOR.GREEN: Vector2i(0, 0),
	COLOR.PURPLE: Vector2i(1, 0),
	COLOR.BLUE: Vector2i(2, 0),
	COLOR.ORANGE: Vector2i(0, 1),
	COLOR.LIGHT_BLUE: Vector2i(1, 1),
	COLOR.RED: Vector2i(2, 1),
}

const shape_colors: Dictionary = {
	Shape.I: COLOR.GREEN,
	Shape.O: COLOR.BLUE,
	Shape.T: COLOR.RED,
	Shape.J: COLOR.LIGHT_BLUE,
	Shape.L: COLOR.ORANGE,
	Shape.S: COLOR.PURPLE,
	Shape.Z: COLOR.GREEN,
}

enum EffectType {
	BUILDING,
	MELEE,
	SHIELD,
	SPELL,
	ECONOMY,
	SCIENCE,
}

@export var shape: Shape
@export var color: COLOR
@export var coords: Vector2i
@export var rotation: int = 0
@export var cells: Array[Cell] = []

var cell_matrix: Array = []
var shadow_y: int = coords.y
var display_offset: bool = false

func _ready() -> void:
	display_offset = shape in [Piece.Shape.T, Piece.Shape.L, Piece.Shape.J, Piece.Shape.S, Piece.Shape.Z]
	_create_cells()


func _create_cells() -> void:
	var shape_arr: Array = shape_map[shape]
	for row: int in range(len(shape_arr)):
		cell_matrix.append([])
		cell_matrix[-1].resize(len(shape_arr[row]))
		cell_matrix[-1].fill(null)
		for col: int in range(len(shape_arr[row])):
			if shape_arr[row][col] == 0: continue
			var cell: Cell = preload("res://Piece/Cell/cell.tscn").instantiate()
			cell.piece = self
			cell.offset = Vector2i(col, row)
			cell.base_atlas_coords = color_map[color]
			cell.effect_atlas_coords = Vector2i.ZERO
			cells.append(cell)
			$Cells.add_child(cell)
			cell_matrix[row][col] = cell


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
			if cell_matrix[row][col] == null: continue
			cell_matrix[row][col].offset = Vector2i(col, row)

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
