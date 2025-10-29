@abstract
class_name Effect extends GDScript

const tileset: TileSet = preload("res://Resources/piece_tileset.tres")


static var effect_map: Dictionary[StringName, GDScript] = {}

static var atlas_coords: Vector2i
static var fragile: bool = false
static var name: StringName
static var description: String
static var rarity: StringName
static var types: Array[StringName]

static var player: Player
static var enemy: Enemy

var cell: Cell


static func get_effect(effect_name: StringName) -> Effect:
	if effect_name not in effect_map:
		printerr("Effect ", effect_name, " is not valid.")
	return effect_map.get(effect_name)


static func pascal_to_name(name: String) -> String:
	# Changes name from PascalCase to name format
	# SpikedShield -> spiked shield
	var result := ""
	for i in name.length():
		var c := name[i]
		if i > 0 and c == c.to_upper():
			result += " "
		result += c.to_lower()
	return result


static func register_effects() -> void:
	# Generate dictionary from name -> effect
	var script: Script = load("res://Tetris/Effects/effect.gd")
	for const_name: String in script.get_script_constant_map():
		var map := script.get_script_constant_map()
		var value: Variant = script.get_script_constant_map().get(const_name)
		if value is GDScript:
			effect_map[pascal_to_name(const_name)] = value
	
	# Set Tileset data to Effect classes
	var source: TileSetAtlasSource = tileset.get_source(1)
	for tile_index in source.get_tiles_count():
		var coords: Vector2i = source.get_tile_id(tile_index)
		var tile_data := source.get_tile_data(coords, 0)
		var effect_name: StringName = tile_data.get_custom_data("effect name")
		if effect_name not in effect_map: 
			tile_data.set_custom_data("effect", Effect.Debug)
			continue
		var effect: GDScript = effect_map.get(effect_name)
		tile_data.set_custom_data("effect", effect)
		effect.atlas_coords = coords
		effect.rarity = tile_data.get_custom_data("rarity")
		effect.types.append_array(tile_data.get_custom_data("effect type"))


func deal_damage(damage: float) -> void:
	enemy.take_damage(damage + player.status_effects.get_status_effect("strength"))
	if damage >= 3:
		GameManager.camera.screenshake(5 * min(damage, 8), .5)


func gain_block(block: int) -> void:
	player.gain_block(block)

# Triggers
func on_place() -> void:
	pass

func on_clear() -> void:
	pass

func on_adjacent_cell_placed(direction: Vector2i) -> void:
	pass
	
func on_adjacent_cell_cleared(direction: Vector2i) -> void:
	pass



# =================================================
# ==================== Effects ====================
# =================================================


class Debug extends Effect:
	func on_place() -> void:
		print_debug("Debug Effect Place")

class None extends Effect:
	# Effect with no functionality, if a cell has no effect
	# this is what its effect will be set to
	func _ready() -> void: 
		atlas_coords = Vector2i.ZERO

class Sword extends Effect:
	var data: Effect
	func _ready() -> void:
		name = &"Sword"
		description = "On Clear: Deals 2 damage"
		rarity = "common"
		
	func on_clear() -> void:
		deal_damage(2)


class Shield extends Effect:
	func _ready() -> void:
		description = "On Clear: Gain 3 block"
		
	func on_clear() -> void:
		gain_block(3)


class WoodenShield extends Effect:
	func _ready() -> void:
		description = "On Clear: Deals 0.2 damage for each block you have"

	func on_clear() -> void:
		deal_damage(0.2 * player.block)


class RoundShield extends Effect:
	func _ready() -> void:
		description = "On Place: Gain 2 block"
	func on_place() -> void:
		gain_block(2)


class Dagger extends Effect:
	func _ready() -> void:
		description = "When an adjacent cell is cleared: Deals 2 damage"
	func on_adjacent_cell_cleared(direction: Vector2i) -> void:
		deal_damage(2)



"""
	"none": "",
	"wooden shield": "On Clear: Deals 0.2 damage for each block you have",
	"round shield": "[u]On Place[/u]: Gain 2 block",
	"spiked shield": "On Clear: Lose 3 health then gain 15 block",
	"dagger": "[u]When an adjacent cell is cleared[/u]: deals 3 damage",
	"target": "Your arrows deal +1 damage",
	"bomb": "On Clear: Destroys a 3x3 area, deals 3 self damage",
	"grenade": "On Clear: Deals 8 damage, deals 2 self damage",
	"landmine": "[u]When a cell is placed on top of this[/u]: Destroy it and this",
	"poison vial": "On Clear: Applies 1 poison",
	"acid vial": "On Clear: Deals 1 damage for each poison the enemy has",
	"skull": "On Clear: Doubles the enemy's poison",
	"piggy bank": "Stores coins you collect\nOn Clear: Gain 1.5x collected coins",
	"cloud": "On Clear: Deals 0.5 damage for each line below this",
	"greatsword": "On Clear: Deals 4 damage",
	"tower": "On Place: Deals 1 damage for each other Building you have",
	"bricks": "On Place: Gain 2 block\nOn Clear: Lose 1 block",
	"helmet": "On Clear: Equip a helmet",
	"chestplate": "On Clear: Equip a chestplate",
	"leggings": "On Clear: Equip leggings",
	"boots": "On Clear: Equip boots (Gain +1 resistance when all armor is equipped)",
	"syringe": "On Place: Gain 3 Strength \nOn Clear: Lose 3 Strength",
	"bubbles": "On Clear: Deals 1 damage for each consecutive empty cell above this",
	"permanent coin": "On Clear: gain 1 gold",
	"armor plate": "On Place: Gain 7 block\nOn Clear: Lose 7 block",
	"house": "On Place: Trigger adjacent Buildings On Place effects",
	"office building": "On Place: Gain 1 gold for every 3 Buildings you have",
	"sword and shield": "On Clear: deal 2 damage and gain 2 block",
	"shovel": "On Place: 10% chance to dig up a relic",
	"weights": "On Clear: Gain 1 Strength",
	"guitar": "On Clear: Gain 1 Tranquility for each Music Note you have",
	"flute": "On Clear: Gain 2 Tranquility",
	
	"drums": "[u]Whenever you gain Tranquility[/u]: Deals 1 damage",
	"piano": "On Clear: Gain 1 Tranquility, 1 Strength, and 1 Prayer",
	"trumpet": "On Clear: Deals 1 damage for each Music Note you have",
	"trombone": "On Clear: Gain 2 block for each Music Note you have",
	"music note": "A part of a song",
	"glissando": "[u]Whenever you clear 2 instruments at the same time[/u]: Gain 3 tranquility",
	"speakers": "[u]Whenever you clear an instrument[/u]: gain 1 Tranquility",
	"basic bow": "When you place a piece: Fires a random arrow",
	"compound bow": "When you place a piece: Fires 3 random arrows",
	"arrow": "deals 3 damage",
	"volley": "Deals 2 damage 3 times",
	"dagger storm": "When an adjacent cell is cleared: Deal 3 damage 3 times",
	"quiver": "Your bows fire 1 additional arrow",
	"barbed arrow": "4 Damage\nOn Clear: Deal 1 self damage",
	"flaming arrow": "deals 3 damage, applies 1 burn",
	"obsidian arrow": "deals 6 damage",
	"poisoned arrow": "deals 2 damage, applies 2 poison",
	"slingshot": "When you place a piece: Deal 1 damage",
	"holy water": "On Clear: Cleanse all debuffs",
	"war flag": "Adjacent Melee effects deal +1 damage",
	"war axe": "When you take self damage: Deals 2 damage",
	"war hammer": "When you take self damage: Deals 5 damage",
	"horus' eye (down)": "Copies the effect of the cell below this",
	"horus' eye (up)": "Copies the effect of the cell above this",
	"fishie": "On Clear: heal 2 hp",
	"witch hut": "Something to do with poison",
	"medkit": "On Clear: heal 5 hp",
	"glass sword": "On Clear: Deal 10 damage",
	"rapier": "On Clear: Deal 1 damage 3 times",
	"lance": "TODO",
	"scythe": "TODO",


"""
