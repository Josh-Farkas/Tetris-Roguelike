class_name CellData extends Resource

@export var effect_data: EffectData
@export var offset: Vector2i
@export var base_atlas_coords: Vector2i


func create_cell(piece: Piece = null) -> Cell:
	""" Creates a cell based on this cell data """
	var cell: Cell = preload("res://Piece/Cell/cell.tscn").instantiate()
	cell.data = self
	cell.piece = piece
	cell.effect = effect_data.create_effect(cell)
	return cell


func set_effect(data: EffectData) -> void:
	""" Sets the effect data of this cell to data """
	effect_data = data
