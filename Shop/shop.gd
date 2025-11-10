extends Control

var tileset: TileSet = preload(Constants.PIECE_TILESET_PATH)
@export var shop_data: ShopData = load("res://Shop/shop_data.gd").new()

var pieces: Array[Piece] = []
var bought_pieces: Array[int] = []
var bought_effects: Array[Vector2i] = []

var cell_coords: Dictionary = {}
var cell_offset_coords: Dictionary = {}

@onready var reroll_price: int = shop_data.base_reroll_price:
	set(value):
		reroll_price = value
		# TODO: Make update UI

@onready var player: Player = GameManager.player
@onready var effect_description: EffectDescription = $EffectDescription

@onready var background_layer: TileMapLayer = $TilemapContainer/SubViewport/Background
@onready var base_layer: TileMapLayer = $TilemapContainer/SubViewport/Base
@onready var effect_layer: TileMapLayer = $TilemapContainer/SubViewport/Effect
@onready var base_offset_layer: TileMapLayer = $TilemapContainer/SubViewport/BaseOffset
@onready var effect_offset_layer: TileMapLayer = $TilemapContainer/SubViewport/EffectOffset


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_items()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not effect_description.show_hovered_effect(effect_layer):
			effect_description.show_hovered_effect(effect_offset_layer)

	if event.is_action_pressed("click"):
		_on_click()
		
func _on_click() -> void:
	var coords: Vector2i = base_layer.local_to_map(effect_layer.get_local_mouse_position())
	var offset_coords: Vector2i = base_offset_layer.local_to_map(base_offset_layer.get_local_mouse_position())
	if coords in shop_data.effect_coords:
		_buy_effect(coords)
	
	# Detect Piece Click
	var cell: Cell
	if coords in cell_coords.keys():
		cell = cell_coords[coords]
	elif offset_coords in cell_offset_coords.keys():
		cell = cell_offset_coords[offset_coords]
	if cell != null:
		var piece: Piece = cell.piece
		var idx: int
		for i in range(len(pieces)):
			if piece == pieces[i]:
				idx = i
		_buy_piece(idx) # must be done outside loop as pieces size will change in loop


func _generate_items() -> void:
	_generate_effects()
	_generate_pieces()
	_generate_relics()

## Chooses and spawns the [Effect]s to put in the shop.
func _generate_effects() -> void:
	return
	#Slots 1-3 are common, slots 4 and 5 are uncommon, and slot 6 is rare
	var rarity_pool: Array
	for n in range(shop_data.num_effects):
		if shop_data.effect_coords[n] in bought_effects: continue
		if n in range(0, 3):
			rarity_pool = shop_data.effects[Constants.Rarity.COMMON]
		elif n in range(3, 5):
			rarity_pool = shop_data.effects[Constants.Rarity.UNCOMMON]
		else:
			rarity_pool = shop_data.effects[Constants.Rarity.RARE]
		var effect: String = rarity_pool.pick_random()
		
		effect_layer.set_cell(shop_data.effect_coords[n], 1, _get_effect_tilemap_coords(effect))


func _generate_pieces() -> void:
	return
	for n in range(shop_data.num_pieces):
		if n in bought_pieces: continue
		var piece_data: PieceData = load("res://Piece/piece_data.gd").new()
		# Select piece shape
		var rand: float = randf()
		var shape_pool: Array[PieceData.Shape]
		if rand <= shop_data.piece_shape_common_odds:
			shape_pool = shop_data.piece_shape_rarities[Constants.Rarity.COMMON]
		elif rand <= shop_data.piece_shape_uncommon_odds:
			shape_pool = shop_data.piece_shape_rarities[Constants.Rarity.UNCOMMON]
		else:
			shape_pool = shop_data.piece_shape_rarities[Constants.Rarity.RARE]
			
		piece_data.shape = shape_pool.pick_random()
		piece_data.coords = shop_data.piece_coords[n]
		# shift O right to center
		if piece_data.shape == PieceData.Shape.O:
			piece_data.spawn_coords += Vector2i.RIGHT
		
		# Apply effects
		for cell_data: CellData in piece_data.cells:
			var rarity_pool: Array
			rand = randf()
			if rand <= shop_data.piece_common_odds:
				rarity_pool = shop_data.effects.common
			elif rand <= shop_data.piece_uncommon_odds:
				rarity_pool = shop_data.effects.uncommon
			elif rand <= shop_data.piece_rare_odds:
				rarity_pool = shop_data.effects.rare
			else:
				continue # No Effect
			
			var effect_data: EffectData = rarity_pool.pick_random()
			cell_data.effect_atlas_coords = effect_data.atlas_coords
		
		var piece: Piece = piece_data.create_piece()
		pieces.append(piece)
		_draw_piece(piece, piece.display_offset)


func _generate_relics() -> void:
	pass


func _reroll() -> void:
	if player.gold < reroll_price: return
	player.gold -= reroll_price
	reroll_price += shop_data.reroll_scaling_amount
	
	pieces.clear()
	cell_coords.clear()
	cell_offset_coords.clear()
	
	for piece in $Pieces.get_children():
		# bought pieces won't be removed
		$Pieces.remove_child(piece)
		piece.queue_free()
		
	for n in range(shop_data.num_pieces):
		_clear_piece(n)
		
	_generate_items()


func _get_effect_tilemap_coords(effect: String) -> Vector2i:
	var source: TileSetAtlasSource = tileset.get_source(1)
	for tile_index in source.get_tiles_count():
		var coords: Vector2i = source.get_tile_id(tile_index)
		var tile_data := source.get_tile_data(coords, 0)
		var tile_effect_name: StringName = tile_data.get_custom_data("effect name")
		if tile_effect_name == effect:
			return coords
	push_error("Effect %s Not Found" % effect)
	return Vector2i.ZERO


func _draw_piece(piece: Piece, offset: bool = false) -> void:
	for cell in piece.cells:
		var coords: Vector2i = piece.coords + cell.offset
		if offset:
			cell_offset_coords[coords] = cell
			base_offset_layer.set_cell(coords, 0, cell.base_atlas_coords)
			effect_offset_layer.set_cell(coords, 1, cell.effect_atlas_coords)
		else:
			cell_coords[coords] = cell
			base_layer.set_cell(coords, 0, cell.base_atlas_coords)
			effect_layer.set_cell(coords, 1, cell.effect_atlas_coords)


func _buy_effect(coords: Vector2i) -> void:
	var data: TileData = effect_layer.get_cell_tile_data(coords)
	if data == null: return
	
	var effect_data: EffectData = data.get_custom_data("effect")
	var price: int = shop_data.prices[effect_data.rarity]
	
	if player.gold < price: return
	player.gold -= price
	bought_effects.append(effect_data)
	GameManager.bought_effect = effect_data
	effect_layer.erase_cell(coords)
	GameManager.change_scene("ApplyEffectMenu")


func _buy_piece(piece_num: int) -> void:
	if player.gold < shop_data.piece_price: return
	var piece: Piece = pieces[piece_num]
	player.gold -= shop_data.piece_price
	bought_pieces.append(piece_num)
	$Pieces.remove_child(piece)
	player.add_piece(piece)
	_clear_piece(piece_num)


func _clear_piece(piece_num: int) -> void:
	for col in range(4):
		for row in range(4):
			cell_coords.erase(shop_data.piece_coords[piece_num] + Vector2i(col, row))
			cell_offset_coords.erase(shop_data.piece_coords[piece_num] + Vector2i(col, row))

			base_layer.erase_cell(shop_data.piece_coords[piece_num] + Vector2i(col, row))
			effect_layer.erase_cell(shop_data.piece_coords[piece_num] + Vector2i(col, row))
			base_offset_layer.erase_cell(shop_data.piece_coords[piece_num] + Vector2i(col, row))
			effect_offset_layer.erase_cell(shop_data.piece_coords[piece_num] + Vector2i(col, row))


func _on_reroll_pressed() -> void:
	_reroll()


func _on_continue_button_pressed() -> void:
	GameManager.next_combat()
