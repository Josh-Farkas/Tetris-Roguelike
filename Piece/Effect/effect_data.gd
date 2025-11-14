class_name EffectData extends Resource
## Holds the data of an [Effect] such as
## [member name], [member description], [member rarity], [member types], [member fragile].
## This can create an [Effect] based on its data to use during gameplay.
## Does not handle the [Effect] functions, that is in the [Effect] class.

const tileset: TileSet = preload(Constants.PIECE_TILESET_PATH) ## The [TileSet] with all [EffectData]s.

## Enum of [Effect] types. Each [Effect] can have multiple types, or only one.
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

static var none: EffectData

@export_group("Info")
@export var name: StringName
@export var description: String ## Description of what this effect does.
@export var rarity: Constants.Rarity ## Rarity of this effect.
@export var types: Array[EffectData.Type] ## What effect types this has.[br]Ex: [code][EffectData.Type.MELEE, EffectData.Type.SHIELD][/code]
@export var fragile: bool = false ## Whether or not this effect is fragile. Fragile effects can only be placed once per combat.

@export_group("Data")
@export var effect_script: GDScript ## Script of this effect type.
@export var atlas_coords: Vector2i ## Atlas coords of this effect type.

var count: int = 0 ## Number of [Effect]s placed that have this [EffectData].

## Creates an [Effect] based on this [EffectData].
func create_effect(cell: Cell = null) -> Effect:
	var effect: Effect = effect_script.new()
	effect.data = self
	effect.cell = cell
	return effect


func get_formatted_description() -> String:
	var formatted: String = description \
		.replace("On Clear", "[u]On Clear[/u]") \
		.replace("On Place", "[u]On Place[/u]") \
		.replace("When you take self damage", "[u]When you take self damage[/u]") \
		.replace("When you place a piece", "[u]After you place a piece[/u]") \
		.replace("When an adjacent piece is placed", "[u]When an adjacent piece is placed[/u]") \
		.replace("When an adjacent piece is cleared", "[u]When an adjacent piece is cleared[/u]")
	
	formatted += "\n"
	# turns types array into "[TYPE1] [TYPE2]" with the correct color.
	formatted += " ".join(types.map(func(t: Type) -> String: return "[color=%s][%s][/color]" % [Constants.TYPE_COLORS[t], Type.keys()[t]]))
	return formatted
