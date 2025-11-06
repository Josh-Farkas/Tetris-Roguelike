class_name Cell extends Node2D

static var cell_coords: Dictionary[Vector2i, Cell] = {}

var data: CellData
var piece: Piece
var effect: Effect
var offset: Vector2i # offset from piece position
@onready var coords: Vector2i = offset + piece.coords:
	set(value):
		cell_coords.erase(coords)
		coords = value
		cell_coords[coords] = self


func get_coords() -> Vector2i:
	return coords


func get_shadow_coords() -> Vector2i:
	return coords + piece.shadow_offset

func move(dir: Vector2i) -> void:
	coords += dir


func place(trigger_effect: bool = true) -> void:
	if not trigger_effect: return
	effect.base_on_place()
	for neighbor: Vector2i in Constants.NEIGHBORS:
		var cell: Cell = Cell.cell_coords.get(coords + neighbor)
		if cell == null: continue
		cell.effect.base_on_adjacent_cell_placed(-neighbor)


func clear(trigger_effect: bool = true) -> void:
	if not trigger_effect: return
	effect.base_on_clear()
	for neighbor: Vector2i in Constants.NEIGHBORS:
		var cell: Cell = Cell.cell_coords.get(coords + neighbor)
		if cell == null: continue
		cell.effect.base_on_adjacent_cell_cleared(-neighbor)
	cell_coords.erase(coords)
	queue_free()
