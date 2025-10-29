class_name ShopData extends Resource

const tileset: TileSet = preload("res://Resources/piece_tileset.tres")

@export_category("Effects")
@export var prices: Dictionary = {
	"common": 4,
	"uncommon": 6,
	"rare": 10
}

const num_effects: int = 6
const effect_coords: Array[Vector2i] = [
	Vector2i(2, 2),Vector2i(5, 2),Vector2i(8, 2),
	Vector2i(2, 5),Vector2i(5, 5),Vector2i(8, 5),
]

static var effect_type_colors: Dictionary = {
	"RANGED": "Green",
	"ARROW": "Darkgreen",
	"MELEE": "Darkred",
	"SHIELD": "Mediumturquoise",
	"SUPPORT": "Peachpuff",
	"BUILDING": "Sienna",
	"ECONOMY": "Goldenrod",
	"SCIENCE": "Darkviolet",
	"ARMOR": "Dimgray",
	"EXPLOSIVE": "Red",
	"INSTRUMENT": "Aquamarine",
	"MISC": "White",
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

@export var piece_shape_rarities: Dictionary = {
	"common": [Piece.Shape.J, Piece.Shape.L, Piece.Shape.S, Piece.Shape.Z] as Array[Piece.Shape],
	"uncommon": [Piece.Shape.O, Piece.Shape.T] as Array[Piece.Shape],
	"rare": [Piece.Shape.I] as Array[Piece.Shape]
}
@export_category("Rerolls")
@export var base_reroll_price: int = 5
@export var reroll_scaling_amount: int = 2

const num_pieces: int = 2
const piece_coords: Array[Vector2i] = [Vector2i(1, 9), Vector2i(6, 9)]


static var effects := {
	"": [],
	"none": [],
	"common": [],
	"uncommon": [],
	"rare": [],
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
		var tile_effect_name: StringName = tile_data.get_custom_data("effect name")
		var effect_type: Array = tile_data.get_custom_data("effect type")
		var fragile: bool = tile_data.get_custom_data("fragile")
		if tile_effect_name == "none": continue
		effect_types[tile_effect_name] = effect_type
		if tile_effect_name in effect_descriptions:
			effect_descriptions[tile_effect_name] = effect_descriptions[tile_effect_name].insert(0, "[center]")
			if fragile: effect_descriptions[tile_effect_name] += "\n[center][color=efd10e]Fragile[/color]"
			effect_descriptions[tile_effect_name] += "\n" + " ".join(effect_type)
			for type: StringName in effect_type_colors:
				effect_descriptions[tile_effect_name] = effect_descriptions[tile_effect_name] \
						.replace(type, "[color=%s][%s][/color]" % [effect_type_colors[type], type])
		else:
			effect_descriptions[tile_effect_name] = ""
			
		effect_atlas_coords[tile_effect_name] = coords
		var tile_rarity: String = tile_data.get_custom_data("rarity")
		effects[tile_rarity].append(tile_effect_name)


static func _format_effect_descriptions() -> void:
	for effect: StringName in effect_descriptions:
		effect_descriptions[effect] = effect_descriptions[effect]\
				.replace("On Clear", "[u]On Clear[/u]") \
				.replace("On Place", "[u]On Place[/u]") \
				.replace("When you take self damage", "[u]When you take self damage[/u]") \
				.replace("When you place a piece", "[u]After you place a piece[/u]")


static func _parse_effect_descriptions() -> Dictionary:
	var file := FileAccess.open("res://Shop/effect_descriptions.json", FileAccess.READ)
	var content := file.get_as_text()
	return JSON.parse_string(content)
