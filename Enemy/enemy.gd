@abstract
class_name Enemy
extends MarginContainer
## Abstract base class for all enemy types. Handles shared functions and variables.

# UI Elements
@onready var name_label: Label = $EnemyBase/HBoxContainer/Name
@onready var health_bar: HealthBarComponent = $EnemyBase/HBoxContainer/HealthBarComponent
@onready var status_effects_ui: StatusEffectsUI = health_bar.get_node("StatusEffectsUI")
@onready var status_effects: StatusEffectsComponent = $EnemyBase/StatusEffectsComponent
@onready var sprite: TextureRect = $EnemyBase/Background/Sprite

@export_category("Stats")
@export var max_health: float: ## [member health] cannot go above this. Spawns with [member health] set to this.
	set(value):
		if not is_node_ready(): await ready
		max_health = value
		health = value
		health_bar.set_max_health(value)
		health_bar.set_health(value)

var health: float: ## Health.
	set(value):
		health = value
		health_bar.set_health(value)

@export var defense: int ## Flat damage reduction from every hit
@export var base_tick_rate: float = 1 ## Tick rate in seconds.

@export_category("Data")
@export var attack_list: Array[EnemyAttack]
var attacks: Dictionary[StringName, EnemyAttack]


# Tilemap vars
var attack_layer: TileMapLayer
var base_layer: TileMapLayer
	
func _ready() -> void:
	# Signals
	SignalBus.start_combat.connect(_start_combat)
	SignalBus.piece_placed.connect(_on_piece_placed)
	status_effects.status_changed.connect(_on_status_changed)
	
	# Variables
	for atk: EnemyAttack in attack_list:
		attacks[atk.name] = atk

	_set_tileset_data()
	name_label.text = name


## Runs when combat starts. Sets variables.
func _start_combat() -> void:
	attack_layer = get_tree().get_first_node_in_group("attack_layer")
	base_layer = get_tree().get_first_node_in_group("base_layer")

## Lowers [member health] by [param amount]. Dies if [member health] <= 0.
func take_damage(amount: float) -> void:
	if amount == 0: return
	health -= amount
	if amount >= Constants.SCREENSHAKE_MIN_DAMAGE:
		GameManager.camera.screenshake(5 * min(amount, Constants.SCREENSHAKE_MAX_DAMAGE) * GameManager.settings.screenshake_magnitude, .5)
	if health <= 0:
		die()

## Kills the enemy.
func die() -> void:
	SignalBus.enemy_killed.emit()


## Places [param atk] at a random empty position.
func _place_attack_randomly(atk: EnemyAttack) -> void:
	# TODO: Make this efficient and not just random 20 times until fail
	# Keep track of empty tiles and only randomize from those
	for __ in range(2, GameManager.board_height):
		var coords: Vector2i = Vector2i(randi_range(0, 10), randi_range(0, 20))
		if _place_attack(atk, coords): break

## Places [param atk] at the given [param coords]. 
## Returns [code]true[/code] if successful, and [code]false[/code] if something was already there.
func _place_attack(atk: EnemyAttack, coords: Vector2i) -> bool:
	if base_layer.get_cell_tile_data(coords) != null or attack_layer.get_cell_tile_data(coords) != null: return false # failed to place
	attack_layer.set_cell(coords, 0, atk.atlas_coords)
	return true

## Sets the custom data of [member attack_layer].
## The attack_resource custom data will be set to the [EnemyAttack]s in [member attack_list].
func _set_tileset_data() -> void:
	await get_tree().process_frame
	var source: TileSetAtlasSource = attack_layer.tile_set.get_source(0)
	for atk in attack_list:
		var data: TileData = source.get_tile_data(atk.atlas_coords, 0)
		data.set_custom_data("attack_resource", atk)


#region Signals
## Runs when a piece is place.
func _on_piece_placed() -> void:
	take_damage(status_effects.status_effects.poison)


func _on_status_changed() -> void:
	status_effects_ui.update_ui(status_effects.status_effects)
#endregion

@abstract
## Abstract function to be overriden and called by each [Enemy] type.
func attack() -> void
