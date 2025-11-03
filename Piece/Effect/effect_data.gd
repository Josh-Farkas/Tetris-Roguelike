class_name EffectData extends Resource

const tileset: TileSet = preload("res://Resources/piece_tileset.tres")
static var effect_map: Dictionary[StringName, EffectData] = {}

@export_category("Info")
@export var name: StringName
@export var description: String
@export var rarity: Constants.Rarity
@export var types: Array[Effect.Type]
@export var fragile: bool = false

@export_category("Data")
@export var effect_script: GDScript
@export var atlas_coords: Vector2i


func create_effect(cell: Cell = null) -> Effect:
	""" Creates an Effect based on this EffectData """
	var effect: Effect = effect_script.new()
	effect.cell = cell
	effect.data = self
	return effect
