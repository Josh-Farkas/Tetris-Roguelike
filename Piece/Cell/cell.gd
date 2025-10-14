class_name Cell extends Node

var piece: Piece
var offset: Vector2i # offset from piece position
var base_atlas_coords: Vector2i = Vector2i.ZERO
var effect_atlas_coords: Vector2i = Vector2i.ZERO
# atlas coords to revert to after unexhaust
var unexhausted_atlas_coords: Vector2i = Vector2i.ZERO
var fragile: bool = false
var exhausted: bool = false

func unexhaust() -> void:
	exhausted = false
	effect_atlas_coords = unexhausted_atlas_coords
