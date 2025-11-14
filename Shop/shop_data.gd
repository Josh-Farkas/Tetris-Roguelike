class_name ShopData extends Resource
## Data for things in the shop. Handles things like prices, rarity, and more.
## Only one will be created, mostly used just for @export convenience.


const tileset: TileSet = preload(Constants.PIECE_TILESET_PATH) ## The [TileSet] with all [EffectData]s.
		

@export_category("Effects")
@export var prices: Dictionary[Constants.Rarity, int] = {
	Constants.Rarity.NONE: 0,
	Constants.Rarity.COMMON: 4,
	Constants.Rarity.UNCOMMON: 6,
	Constants.Rarity.RARE: 10
}

const num_effects: int = 6 ## Number of [Effect]s that spawn.

## Coordinates of effect spawn positions
@export var effect_spawn_coords: Array[Vector2i] = [
	Vector2i(2, 2),Vector2i(5, 2),Vector2i(8, 2),
	Vector2i(2, 5),Vector2i(5, 5),Vector2i(8, 5),
]


@export_category("Pieces")
@export var piece_price: int = 10 ## The price of a [Piece].

@export_subgroup("Piece Effect Rarities")
@export_range(0, 1) var piece_effect_common_odds: float = 0.10 # 10%
@export_range(0, 1) var piece_effect_uncommon_odds: float = 0.05 + .10 # 5%
@export_range(0, 1) var piece_effect_rare_odds: float = 0.01 + 0.05 + 0.10 # 1%

@export_subgroup("Piece Shape Rarities")
@export_range(0, 1) var piece_shape_common_odds: float = .55 # 55%
@export_range(0, 1) var piece_shape_uncommon_odds: float = .30 + .55 # 30%
@export_range(0, 1) var piece_shape_rare_odds: float = .15 + .30 + .55 # 15%

@export var piece_shape_rarities: Dictionary[Constants.Rarity, Array] = {
	Constants.Rarity.COMMON: [PieceData.Shape.J, PieceData.Shape.L, PieceData.Shape.S, PieceData.Shape.Z],
	Constants.Rarity.UNCOMMON: [PieceData.Shape.O, PieceData.Shape.T],
	Constants.Rarity.RARE: [PieceData.Shape.I],
}

@export_category("Rerolls")
@export var base_reroll_price: int = 5 ## Initial cost to reroll.
@export var reroll_scaling_amount: int = 2 ## Increase to cost after rerolling.

const num_pieces: int = 2 ## Number of pieces in the shop.
const piece_coords: Array[Vector2i] = [Vector2i(1, 9), Vector2i(6, 9)] ## Coordinates of pieces in the shop.

## Map from [Constants.Rarity] to [Array] of [EffectData]. 
## Each pool will contain all effects with that rarity.
const rarity_pools: Dictionary[Constants.Rarity, Array]= {
	Constants.Rarity.NONE: [],
	Constants.Rarity.COMMON: [],
	Constants.Rarity.UNCOMMON: [],
	Constants.Rarity.RARE: [],
}


#static func _init() -> void:
	#_generate_rarity_pools()


## Fills [member rarity_pools].
static func generate_rarity_pools() -> void:
	#var tileset := load(Constants.PIECE_TILESET_PATH)
	var source: TileSetAtlasSource = tileset.get_source(1)
	for tile_index in source.get_tiles_count():
		var coords: Vector2i = source.get_tile_id(tile_index)
		var tile_data := source.get_tile_data(coords, 0)
		var effect_data: EffectData = tile_data.get_custom_data("effect") as EffectData
		if effect_data == null or effect_data.name == "None": continue
		rarity_pools[effect_data.rarity].append(effect_data)
