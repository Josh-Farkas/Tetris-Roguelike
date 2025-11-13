class_name Cell extends Node2D

#static var cell_coords: Dictionary[Vector2i, Cell] = {}

static var cells: Array[Cell] = []

var data: CellData ## This cell's [CellData].
var piece: Piece ## The [Piece] this cell is part of.
var effect: Effect ## The [Effect] this cell has.
var offset: Vector2i ## Offset from piece position
var coords: Vector2i:
	set(value):
		coords = value
		position = coords * 16 + Vector2i(24, -24)
var active: bool = false


static func get_cell_at(cell_coords: Vector2i) -> Cell:
	for cell: Cell in cells:
		if cell.coords == cell_coords:
			return cell
	return null


func _ready() -> void:
	coords = piece.coords + offset
	cells.append(self)


func _exit_tree() -> void:
	cells.erase(self)


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
		var cell: Cell = get_cell_at(coords + neighbor)
		if cell == null: continue
		cell.effect.base_on_adjacent_cell_placed(-neighbor)


func clear(trigger_effect: bool = true) -> void:
	if not trigger_effect: return
	effect.base_on_clear()
	for neighbor: Vector2i in Constants.NEIGHBORS:
		var cell: Cell = get_cell_at(coords + neighbor)
		if cell == null: continue
		cell.effect.base_on_adjacent_cell_cleared(-neighbor)
	queue_free()
