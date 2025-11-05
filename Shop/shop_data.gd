class_name ShopData extends Resource

const tileset: TileSet = preload(Constants.PIECE_TILESET_PATH)

@export_category("Effects")
@export var prices: Dictionary[Constants.Rarity, int] = {
	Constants.Rarity.NONE: 0,
	Constants.Rarity.COMMON: 4,
	Constants.Rarity.UNCOMMON: 6,
	Constants.Rarity.RARE: 10
}

const num_effects: int = 6
# Where effects will spawn in the shop
const effect_coords: Array[Vector2i] = [
	Vector2i(2, 2),Vector2i(5, 2),Vector2i(8, 2),
	Vector2i(2, 5),Vector2i(5, 5),Vector2i(8, 5),
]

static var effect_type_colors: Dictionary[EffectData.Type, StringName] = {
	EffectData.Type.RANGED: "Green",
	EffectData.Type.ARROW: "Darkgreen",
	EffectData.Type.MELEE: "Darkred",
	EffectData.Type.SHIELD: "Mediumturquoise",
	EffectData.Type.SUPPORT: "Peachpuff",
	EffectData.Type.BUILDING: "Sienna",
	EffectData.Type.ECONOMY: "Goldenrod",
	EffectData.Type.SCIENCE: "Darkviolet",
	EffectData.Type.ARMOR: "Dimgray",
	EffectData.Type.EXPLOSIVE: "Red",
	EffectData.Type.MUSIC: "Aquamarine",
	EffectData.Type.MISC: "White",
}


@export_category("Pieces")
@export var piece_price: int = 10

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
@export var base_reroll_price: int = 5
@export var reroll_scaling_amount: int = 2

const num_pieces: int = 2
const piece_coords: Array[Vector2i] = [Vector2i(1, 9), Vector2i(6, 9)]


static var effects := {
	Constants.Rarity.NONE: [],
	Constants.Rarity.COMMON: [],
	Constants.Rarity.UNCOMMON: [],
	Constants.Rarity.RARE: [],
}

static var effect_types: Dictionary = {}
static var effect_atlas_coords: Dictionary = {}
static var effect_descriptions: Dictionary = {}

static func _init() -> void:
	effect_descriptions = _parse_effect_descriptions()
	_format_effect_descriptions()
	_generate_effects()

static func _generate_effects() -> void:
	var source: TileSetAtlasSource = tileset.get_source(1)
	for tile_index in source.get_tiles_count():
		var coords: Vector2i = source.get_tile_id(tile_index)
		var tile_data := source.get_tile_data(coords, 0)
		var effect: Effect = tile_data.get_custom_data("effect") as Effect
		if effect == null or effect.name == "None": continue
		effect_types[effect.name] = effect.types
		if effect.name in effect_descriptions:
			effect_descriptions[effect.name] = effect_descriptions[effect.name].insert(0, "[center]")
			if effect.fragile: effect_descriptions[effect.name] += "\n[center][color=efd10e]Fragile[/color]"
			effect_descriptions[effect.name] += "\n" + " ".join(effect.type)
			for type: EffectData.Type in effect_type_colors:
				effect_descriptions[effect.name] = effect_descriptions[effect.name] \
						.replace(type, "[color=%s][%s][/color]" % [effect_type_colors[type], type])
		else:
			effect_descriptions[effect.name] = ""
			
		effect_atlas_coords[effect.name] = coords
		var tile_rarity: String = tile_data.get_custom_data("rarity")
		effects[tile_rarity].append(effect.name)


static func _format_effect_descriptions() -> void:
	for effect: StringName in effect_descriptions:
		effect_descriptions[effect] = effect_descriptions[effect]\
				.replace("On Clear", "[u]On Clear[/u]") \
				.replace("On Place", "[u]On Place[/u]") \
				.replace("When you take self damage", "[u]When you take self damage[/u]") \
				.replace("When you place a piece", "[u]After you place a piece[/u]") \
				.replace("When an adjacent piece is placed", "[u]When an adjacent piece is placed[/u]") \
				.replace("When an adjacent piece is cleared", "[u]When an adjacent piece is cleared[/u]")
				


static func _parse_effect_descriptions() -> Dictionary:
	var file := FileAccess.open("res://Shop/effect_descriptions.json", FileAccess.READ)
	var content := file.get_as_text()
	return JSON.parse_string(content)
