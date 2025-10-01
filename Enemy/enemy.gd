@abstract
class_name Enemy
extends MarginContainer

signal killed

# UI Elements
@onready var name_label: Label = $EnemyBase/VBoxContainer/VBoxContainer/Name
@onready var health_bar: HealthBarComponent = $EnemyBase/VBoxContainer/VBoxContainer/HealthBarComponent
@onready var status_effects_ui: StatusEffectsUI = health_bar.get_node("StatusEffectsUI")
@onready var status_effects: StatusEffectsComponent = $EnemyBase/StatusEffectsComponent
@onready var sprite: TextureRect = $EnemyBase/VBoxContainer/Background/Sprite
@onready var player: Player = GameManager.player

@export var resource: EnemyResourceBase

# Stats
@onready var max_health: int:
	set(value):
		max_health = value
		health_bar.set_max_health(value)
@onready var health: float:
	set(value):
		health = value
		health_bar.set_health(value)

var defense: int
var damage: int
var base_tick_rate: float = 1 # seconds
var attacks: Array

# Tilemap vars
var attack_layer: TileMapLayer
var base_layer: TileMapLayer
var attack_atlas_coords: Dictionary
	
func _ready() -> void:
	_set_data()
	_update_ui()
	killed.connect(GameManager.on_enemy_killed)
	GameManager.player.piece_placed.connect(_on_piece_placed)
	status_effects.status_changed.connect(status_effects_ui.update_ui)


func _set_data() -> void:
	max_health = resource.max_health
	health = resource.max_health
	defense = resource.defense
	damage = resource.damage


func _update_ui() -> void:
	name_label.text = name

	
func _start_combat() -> void:
	attack_layer = get_tree().get_first_node_in_group("attack_layer")
	base_layer = get_tree().get_first_node_in_group("base_layer")


func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		die()


func die() -> void:
	killed.emit()

@abstract
func attack() -> void

func _place_attack_randomly(attack: Attack) -> void:
	for __ in range(20):
		var coords: Vector2i = Vector2i(randi_range(0, 10), randi_range(0, 20))
		if _place_attack(attack, coords): break
	
func _place_attack(attack: Attack, coords: Vector2i) -> bool:
	if base_layer.get_cell_tile_data(coords) != null or attack_layer.get_cell_tile_data(coords) != null: return false # failed to place
	attack_layer.set_cell(coords, 0, attack_atlas_coords[attack])
	return true

# Signals
func _on_piece_placed(pieces_placed: int) -> void:
	take_damage(status_effects.status_effects.poison)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		die()
