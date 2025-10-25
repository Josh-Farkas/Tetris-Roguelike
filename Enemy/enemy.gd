@abstract
class_name Enemy
extends MarginContainer
## Base class for all enemy types

# UI Elements
@onready var name_label: Label = $EnemyBase/HBoxContainer/Name
@onready var health_bar: HealthBarComponent = $EnemyBase/HBoxContainer/HealthBarComponent
@onready var status_effects_ui: StatusEffectsUI = health_bar.get_node("StatusEffectsUI")
@onready var status_effects: StatusEffectsComponent = $EnemyBase/StatusEffectsComponent
@onready var sprite: TextureRect = $EnemyBase/Background/Sprite
@export var attack_list: Array[EnemyAttack]
var attacks: Dictionary[StringName, EnemyAttack]

# Stats
@export var max_health: float:
	set(value):
		if not is_node_ready(): await ready
		max_health = value
		health = value
		health_bar.set_max_health(value)
		health_bar.set_health(value)

var health: float:
	set(value):
		health = value
		health_bar.set_health(value)

@export var defense: int

var base_tick_rate: float = 1 # seconds

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



func _start_combat() -> void:
	attack_layer = get_tree().get_first_node_in_group("attack_layer")
	base_layer = get_tree().get_first_node_in_group("base_layer")


func take_damage(amount: float) -> void:
	if amount == 0: return
	health -= amount
	if health <= 0:
		die()


func die() -> void:
	SignalBus.enemy_killed.emit()


func _place_attack_randomly(atk: EnemyAttack) -> void:
	for __ in range(2, GameManager.board_height):
		var coords: Vector2i = Vector2i(randi_range(0, 10), randi_range(0, 20))
		if _place_attack(atk, coords): break


func _place_attack(atk: EnemyAttack, coords: Vector2i) -> bool:
	if base_layer.get_cell_tile_data(coords) != null or attack_layer.get_cell_tile_data(coords) != null: return false # failed to place
	attack_layer.set_cell(coords, 0, atk.atlas_coords)
	return true


func _set_tileset_data() -> void:
	await get_tree().process_frame
	var source: TileSetAtlasSource = attack_layer.tile_set.get_source(0)
	for atk in attack_list:
		var data: TileData = source.get_tile_data(atk.atlas_coords, 0)
		data.set_custom_data("attack_resource", atk)


# Signals
func _on_piece_placed(pieces_placed: int) -> void:
	take_damage(status_effects.status_effects.poison)


func _on_status_changed() -> void:
	status_effects_ui.update_ui(status_effects.status_effects)
		
	

@abstract
func attack() -> void
