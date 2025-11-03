class_name PieceData extends Resource

const piece_scn = preload("res://Piece/piece.tscn")

enum Shape {
	I, O, T, J, L, S, Z
}

enum PieceColor {
	GREEN, BLUE, LIGHT_BLUE, RED, ORANGE, PURPLE, YELLOW
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

const color_map: Dictionary[PieceColor, Vector2i] = {
	PieceColor.GREEN: Vector2i(0, 0),
	PieceColor.PURPLE: Vector2i(1, 0),
	PieceColor.BLUE: Vector2i(2, 0),
	PieceColor.ORANGE: Vector2i(0, 1),
	PieceColor.LIGHT_BLUE: Vector2i(1, 1),
	PieceColor.RED: Vector2i(2, 1),
	PieceColor.YELLOW: Vector2i(3, 0)
}

const shape_colors: Dictionary[Shape, PieceColor] = {
	Shape.I: PieceColor.LIGHT_BLUE,
	Shape.O: PieceColor.YELLOW,
	Shape.T: PieceColor.PURPLE,
	Shape.J: PieceColor.BLUE,
	Shape.L: PieceColor.ORANGE,
	Shape.S: PieceColor.GREEN,
	Shape.Z: PieceColor.RED,
}


@export var shape: Shape:
	set(value):
		shape = value
		color = shape_colors[shape]
@export var color: PieceColor
@export var cells: Array[CellData]
@export var matrix: Array[Array] = []
@export var spawn_coords: Vector2i = Vector2i(4, 0)


func _ready() -> void:
	_create_cells()


func _create_cells() -> void:
	var shape_arr: Array = shape_map[shape]
	for row: int in range(len(shape_arr)):
		matrix.append([])
		matrix[-1].resize(len(shape_arr[row]))
		matrix[-1].fill(null)
		for col: int in range(len(shape_arr[row])):
			if shape_arr[row][col] == 0: continue
			var cell_data: CellData = preload("res://Piece/Cell/cell_data.gd").new()
			cell_data.piece = self
			cell_data.offset = Vector2i(col, row)
			cell_data.base_atlas_coords = color_map[color]
			cells.append(cell_data)
			matrix[row][col] = cell_data


func create_piece() -> void:
	var piece: Piece = piece_scn.instantiate()
	piece.data = self
	piece.cell_matrix = matrix.map(func(row: Array) -> void: row.duplicate().fill(null))
	for i in len(matrix):
		for j in len(matrix[i]):
			if matrix[i][j] == null: continue
			var cell: Cell = matrix[i][j].create_cell(piece)
			piece.cell_matrix[i][j] = cell
			piece.cells.append(cell)
