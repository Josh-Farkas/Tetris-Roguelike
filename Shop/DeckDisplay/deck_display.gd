class_name DeckDisplay extends Control
## Node that displays your full [Deck].

const WIDTH = 40

@onready var background_layer: TileMapLayer = $ScrollContainer/SubViewportContainer/SubViewport/Background
@onready var base_layer: TileMapLayer = $ScrollContainer/SubViewportContainer/SubViewport/Base
@onready var effect_layer: TileMapLayer = $ScrollContainer/SubViewportContainer/SubViewport/Effects
@onready var effect_description: EffectDescription = $EffectDescription

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_deck()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		effect_description.show_hovered_effect(effect_layer)


## Displays the [Player]s [Deck].
func display_deck() -> void:
	var counts: Dictionary[PieceData.Shape, int] = \
		{PieceData.Shape.I: 0, PieceData.Shape.O: 0, 
		 PieceData.Shape.T: 0, PieceData.Shape.J: 0, 
		 PieceData.Shape.L: 0, PieceData.Shape.S: 0, 
		 PieceData.Shape.Z: 0}
		
	# Loop through all pieces and display them.
	var num_rows: int = 0
	for piece_data: PieceData in GameManager.player.deck.full_deck:
		var row: int = counts[piece_data.shape] * 5 + 1
		var col: int = piece_data.shape as int * 5 + 1
		var coords: Vector2i = Vector2i(col, row)
		if piece_data.shape == PieceData.Shape.O: coords.x += 1
		var piece: Piece = piece_data.create_piece()
		piece.coords = coords
		# Add row if needed
		counts[piece_data.shape] += 1
		if counts[piece_data.shape] > num_rows:
			num_rows += 1
			if num_rows > 3:
				draw_background(counts[piece_data.shape])
		# Draw cells
		for cell: Cell in piece.cells:
			add_child(cell)
			base_layer.set_cell(cell.coords, 0, cell.data.atlas_coords)
			effect_layer.set_cell(cell.coords, 1, cell.effect.data.atlas_coords)


## Fills in the background of the given [param row] with black cells 
## and increases [SubViewportContainer] size if needed.
func draw_background(row: int) -> void:
	for y in range(5):
		for col in range(WIDTH):
			background_layer.set_cell(Vector2i(col, (row * 5) + y), 0, Constants.TILE_COORDS.BLACK)
	if row > 5:
		$ScrollContainer/SubViewportContainer.custom_minimum_size.y += 5 * Constants.CELL_SIZE
