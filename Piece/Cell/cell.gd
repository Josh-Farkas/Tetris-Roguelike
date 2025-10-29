class_name Cell extends Node2D

static var effect_none: Effect = Effect.None.new()
static var cell_coords: Dictionary[Vector2i, Cell] = {}

var piece: Piece
var offset: Vector2i # offset from piece position
var base_atlas_coords: Vector2i = Vector2i.ZERO
var effect_atlas_coords: Vector2i = Vector2i.ZERO
var unexhausted_atlas_coords: Vector2i = Vector2i.ZERO # atlas coords to revert to after unexhaust
var effect: Effect = effect_none
var fragile: bool = false
var exhausted: bool = false

@onready var coords: Vector2i = offset + piece.coords:
	set(value):
		cell_coords.erase(coords)
		coords = value
		cell_coords[coords] = self
		position = coords * 16

func unexhaust() -> void:
	exhausted = false
	effect_atlas_coords = unexhausted_atlas_coords

func exhaust() -> void:
	exhausted = true
	effect_atlas_coords = Vector2i.ZERO

func set_effect(eff: Effect) -> void:
	effect = eff
	effect_atlas_coords = effect.atlas_coords
	effect.cell = self

	
func get_coords() -> Vector2i:
	return coords


func get_shadow_coords() -> Vector2i:
	return coords + piece.shadow_offset


func copy() -> Cell:
	var copy: Cell = duplicate()
	copy.piece = piece
	copy.coords = coords
	copy.effect = effect.duplicate()
	copy.effect.cell = copy
	copy.base_atlas_coords = base_atlas_coords
	copy.fragile = fragile
	copy.exhausted = exhausted
	copy.unexhausted_atlas_coords = unexhausted_atlas_coords
	return copy


func clear(trigger_effect: bool = true) -> void:
	if trigger_effect: effect.on_clear()
	if fragile:
		exhaust()
