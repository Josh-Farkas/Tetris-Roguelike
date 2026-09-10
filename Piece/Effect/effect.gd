@abstract
class_name Effect extends Resource
## Abstract class that will be inherited by specific effects, Ex: [SwordEffect], [ShieldEffect].[br]
## Instance of an Effect, created based on an [EffectData].[br]
## Handles runtime variables like [member coords] and [member cell].
## Also has all the functions related to the effect.


static var player: Player ## The [member player].

var data: EffectData ## The [EffectData] of this [Effect], has the functions to actually use it.
var cell: Cell ## The [Cell] this [Effect] is on.


#static func get_effect(effect_name: StringName) -> Effect:
	#if effect_name not in effect_map:
		#printerr("Effect ", effect_name, " is not valid.")
	#return effect_map.get(effect_name)

#region Helper Functions
func deal_damage(damage: float) -> void:
	GameManager.enemy.take_damage(damage + GameManager.get_player().status_effects.get_status_effect("strength"))
	if damage >= 3:
		GameManager.camera.screenshake(5 * min(damage, 8), .5)


func gain_block(block: int) -> void:
	player.gain_block(block)
#endregion

#region Triggers
## Called when this [Effect] is placed.
## Updates data and then calls the [code]on_place[/code] virtual method.

func base_on_place() -> void:
	data.count += 1
	on_place()

## Called when this [Effect] is cleared.
## Updates data and then calls the [code]on_clear[/code] virtual method.
func base_on_clear() -> void:
	data.count -= 1
	on_clear()
	
## Called when a [Cell] is placed adjacent to this. 
## [param direction] is the direction it was placed relative to this.
## This just calls the [code]on_adjacent_cell_placed[/code] virtual method.
func base_on_adjacent_cell_placed(direction: Vector2i) -> void:
	on_adjacent_cell_placed(direction)
	
## Called when a [Cell] is cleared adjacent to this. 
## [param direction] is the direction it was cleared relative to this.
## This just calls the [code]on_adjacent_cell_cleared[/code] virtual method.
func base_on_adjacent_cell_cleared(direction: Vector2i) -> void:
	on_adjacent_cell_cleared(direction)
	

# Triggers
@warning_ignore_start("unused_parameter")
## Called when this
## Should be overridden by inherited class.
func on_place() -> void:
	pass

## Should be overridden by inherited class.
func on_clear() -> void:
	pass

func on_adjacent_cell_placed(direction: Vector2i) -> void:
	pass
	
func on_adjacent_cell_cleared(direction: Vector2i) -> void:
	pass
#endregion


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
