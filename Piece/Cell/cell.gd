class_name Cell extends Node2D

static var cell_coords: Dictionary[Vector2i, Cell] = {}

var piece: Piece
var effect: Effect
var offset: Vector2i # offset from piece position
var base_atlas_coords: Vector2i = Vector2i.ZERO
@onready 
var coords: Vector2i = offset + piece.coords:
	set(value):
		cell_coords.erase(coords)
		coords = value
		cell_coords[coords] = self
		position = coords * 16


func get_coords() -> Vector2i:
	return coords


func get_shadow_coords() -> Vector2i:
	return coords + piece.shadow_offset


func clear(trigger_effect: bool = true) -> void:
	if trigger_effect: 
		effect.on_clear()
