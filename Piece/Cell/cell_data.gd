class_name CellData extends Resource

@export var effect_data: EffectData = preload("res://Piece/Effect/Effects/None/none_data.tres") as EffectData
@export var piece_data: PieceData
@export var offset: Vector2i
@export var base_atlas_coords: Vector2i
@export var exhausted: bool = false


## Creates a [Cell] based on this [CellData] with its [member piece] set to [param piece].
func create_cell(piece: Piece = null) -> Cell:
	var cell: Cell = preload("res://Piece/Cell/cell.tscn").instantiate()
	cell.data = self
	cell.piece = piece
	cell.effect = effect_data.create_effect(cell)
	return cell


## Sets [member effect_data] to [param data].
func set_effect(data: EffectData) -> void:
	effect_data = data
