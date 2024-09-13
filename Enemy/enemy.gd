class_name Enemy
extends Control

signal killed

@onready var name_label: Label = $EnemyUI/VBoxContainer/VBoxContainer/Name
@onready var health_bar: HealthBarComponent = $EnemyUI/VBoxContainer/HealthBarComponent
@onready var status_effects: StatusEffectsComponent = $EnemyUI/VBoxContainer/HealthBarComponent/StatusEffectsComponent
@onready var sprite: TextureRect = $EnemyUI/VBoxContainer/Sprite
@onready var player: Player = GameManager.player

@export var resource: EnemyResourceBase

var max_health: int
var health: float
var defense: int
var damage: int
var base_tick_rate: float = 1 # seconds
	
func _ready() -> void:
	_set_data()
	_update_ui()
	killed.connect(GameManager.on_enemy_killed)

func _set_data() -> void:
	max_health = 20
	health = 20
	defense = 0
	damage = 1

func _update_ui() -> void:
	name_label.text = name

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		die()
	
func die() -> void:
	killed.emit()
