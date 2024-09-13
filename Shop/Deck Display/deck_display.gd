class_name DeckDisplay extends Control

const WIDTH = 40

@onready var background_layer: TileMapLayer = $ScrollContainer/SubViewportContainer/SubViewport/Background
@onready var base_layer: TileMapLayer = $ScrollContainer/SubViewportContainer/SubViewport/Base
@onready var effect_layer: TileMapLayer = $ScrollContainer/SubViewportContainer/SubViewport/Effects

@onready var effect_description: EffectDescription = $EffectDescription

var cell_coords: Dictionary = {} # Vector2i: Cell 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_deck()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		effect_description.show_hovered_effect(effect_layer)


func display_deck() -> void:
	var counts: Array[int] = [0, 0, 0, 0, 0, 0, 0]
	var num_rows: int = 0
	for piece in GameManager.player.full_deck:
		var shape: Piece.Shape = piece.shape
		var row: int = counts[shape] * 5 + 1
		var col: int = shape as int * 5 + 1
		var coords: Vector2i = Vector2i(col, row)
		if shape == Piece.Shape.O: coords.x += 1
		piece.coords = coords
		for cell in piece.cells:
			cell_coords[coords + cell.offset] = cell
			base_layer.set_cell(coords + cell.offset, 0, cell.base_atlas_coords)
			effect_layer.set_cell(coords + cell.offset, 1, cell.effect_atlas_coords)
		counts[shape] += 1
		if counts[shape] > num_rows:
			num_rows += 1
			if num_rows > 3:
				draw_background(counts[shape])


func draw_background(row: int) -> void:
	for y in range(5):
		for col in range(WIDTH):
			background_layer.set_cell(Vector2i(col, (row * 5) + y), 0, Constants.TILE_COORDS.BLACK)
	if row > 5:
		$ScrollContainer/SubViewportContainer.custom_minimum_size.y += 5 * Constants.CELL_SIZE
