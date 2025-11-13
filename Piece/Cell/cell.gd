class_name Cell extends Node2D

## [Array] of all [Cell]s. Automatically updates when a [Cell] is created or freed.
static var cells: Array[Cell] = []

var data: CellData ## This cell's [CellData].
var piece: Piece ## The [Piece] this cell is part of.
var effect: Effect ## The [Effect] this cell has.
var offset: Vector2i ## Offset from piece position
var coords: Vector2i: ## The coordinates of this cell in the game.
	set(value):
		coords = value
		position = coords * 16 + Vector2i(24, -24)
var active: bool = false ## Whether or not this cell is currently on the game board (not in preview).

## Returns the [Cell] at the given [param coords], or [code]null[/code] if none exists.
static func get_cell_at(cell_coords: Vector2i) -> Cell:
	for cell: Cell in cells:
		if cell.coords == cell_coords:
			return cell
	return null


func _ready() -> void:
	coords = piece.coords + offset
	cells.append(self)

## Erase this from [member cells] when it's cleared.
func _exit_tree() -> void:
	cells.erase(self)

## Returns the coords of the shadow.
func get_shadow_coords() -> Vector2i:
	return coords + piece.shadow_offset

## Moves the cell in the direction [param dir].
func move(dir: Vector2i) -> void:
	coords += dir


## Place this cell. If [param trigger_effects] is [code]true[/code] then [EffectData] [code]on_place[/code] and [code]on_adjacent_place[/code] methods will run.
func place(trigger_effects: bool = true) -> void:
	if not trigger_effects: return
	effect.base_on_place()
	for neighbor: Vector2i in Constants.NEIGHBORS:
		var cell: Cell = get_cell_at(coords + neighbor)
		if cell == null: continue
		cell.effect.base_on_adjacent_cell_placed(-neighbor)

## Clear this cell. If [param trigger_effects] is [code]true[/code] then [EffectData] [code]on_clear[/code] and [code]on_adjacent_clear[/code] methods will run.
func clear(trigger_effects: bool = true) -> void:
	if not trigger_effects: return
	effect.base_on_clear()
	for neighbor: Vector2i in Constants.NEIGHBORS:
		var cell: Cell = get_cell_at(coords + neighbor)
		if cell == null: continue
		cell.effect.base_on_adjacent_cell_cleared(-neighbor)
	queue_free()
