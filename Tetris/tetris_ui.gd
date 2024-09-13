extends Control

@onready var player: Player = GameManager.player
var enemy: Enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/LeftSide/MarginContainer.add_child(player)
	_choose_enemy()

# TODO: Make this randomly choose based on pools
func _choose_enemy() -> void:
	enemy = load("res://Enemy/Types/Goblin/goblin.tscn").instantiate()
	GameManager.enemy = enemy
	$HBoxContainer/EnemyPosition.add_child(enemy)
