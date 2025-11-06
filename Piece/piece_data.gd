class_name PieceData extends Resource

const piece_scn := preload("res://Piece/piece.tscn")

enum Shape {
	I, O, T, J, L, S, Z
}

enum PieceColor {
	GREEN, BLUE, LIGHT_BLUE, RED, ORANGE, PURPLE, YELLOW
}

const shape_map: Dictionary = {
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
		display_offset = shape in [PieceData.Shape.T, PieceData.Shape.L, PieceData.Shape.J, PieceData.Shape.S, PieceData.Shape.Z]
@export var cells: Array[CellData]
@export var matrix: Array[Array] = [] # Array[Array[CellData]]
var color: PieceColor
var display_offset: bool = false


func create_cells() -> void:
	var shape_arr: Array = shape_map[shape]
	for row: int in range(len(shape_arr)):
		matrix.append([])
		matrix[-1].resize(len(shape_arr[row]))
		matrix[-1].fill(null)
		for col: int in range(len(shape_arr[row])):
			if shape_arr[row][col] == 0: continue
			var cell_data: CellData = CellData.new()
			cell_data.effect_data = EffectData.none
			cell_data.piece_data = self
			cell_data.offset = Vector2i(col, row)
			cell_data.base_atlas_coords = color_map[color]
			cells.append(cell_data)
			matrix[row][col] = cell_data


func create_piece() -> Piece:
	var piece: Piece = piece_scn.instantiate()
	piece.data = self
	
	for row in len(matrix):
		var new_row: Array[Cell] = []
		for col in len(matrix[row]):
			if matrix[row][col] == null:
				new_row.append(null)
			else:
				var cell: Cell = matrix[row][col].create_cell(piece)
				cell.offset = Vector2i(col, row)
				cell.coords = piece.coords + cell.offset
				new_row.append(cell)
				piece.cells.append(cell)
		piece.cell_matrix.append(new_row)
	return piece
