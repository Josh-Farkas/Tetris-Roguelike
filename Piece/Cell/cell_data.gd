class_name CellData extends Resource
## Holds the data of a [Cell] that doesn't change during gameplay,
## such as the [PieceData] and [EffectData] of the cell.[br]
## This can create a [Cell] based on its data to use during gameplay.


@export var effect_data: EffectData ## Data for the [Effect] of this cell.
@export var piece_data: PieceData ## The data for the [Piece] that this cell is a part of.
@export var atlas_coords: Vector2i ## Atlas coords for the color of this cell.
@export var exhausted: bool = false ## Whether or not this cell has been placed before for exhaustable cells.


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
