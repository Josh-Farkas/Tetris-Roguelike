class_name EffectData extends Resource

const tileset: TileSet = preload(Constants.PIECE_TILESET_PATH)

enum Type {
	MELEE,
	SHIELD,
	MUSIC,
	RANGED,
	SUPPORT,
	ARROW,
	BUILDING,
	ECONOMY,
	SCIENCE,
	ARMOR,
	EXPLOSIVE,
	MISC,
}

static var effect_map: Dictionary[StringName, EffectData] = {}
static var none: EffectData

@export_group("Info")
@export var name: StringName:
	set(value):
		name = value
		effect_map[name] = self
@export var description: String
@export var rarity: Constants.Rarity
@export var types: Array[EffectData.Type]
@export var fragile: bool = false

@export_group("Data")
@export var effect_script: GDScript
@export var atlas_coords: Vector2i

var count: int = 0 ## Number of [Effect]s that have this [EffectData] placed

## Creates an [Effect] based on this [EffectData]
func create_effect(cell: Cell = null) -> Effect:
	var effect: Effect = effect_script.new()
	effect.data = self
	effect.cell = cell
	return effect


static func get_effect_data(name: StringName) -> EffectData:
	return effect_map.get(name)
