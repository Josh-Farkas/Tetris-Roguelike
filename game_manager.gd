extends Node

signal start_combat

const enemy_pools = {
	"easy": [
		preload("res://Enemy/Types/Goblin/goblin.gd"),
	],
	"hard": [],
	"elite": [],
	"boss": [],
}

static var player: Player = preload("res://Player/player.tscn").instantiate()
var main: Node
var enemy: Enemy
var active_scene: Node
var bought_effect: Vector2i = Vector2i.ZERO
var level_num: int = 1

# SCENES
@onready var game_scene: PackedScene = preload("res://Tetris/tetris.tscn")
@onready var shop_scene: PackedScene = preload("res://Shop/shop.tscn")
@onready var apply_effect_scene: PackedScene = preload("res://Shop/Apply Effect/apply_effect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(player)
	main = get_tree().get_first_node_in_group("main")
	if main != null:
		change_scene(shop_scene)

func change_scene(new_scene: PackedScene, keep_loaded: bool = true) -> void:
	if keep_loaded:
		active_scene.hide()
		active_scene.process_mode = Node.PROCESS_MODE_DISABLED
		active_scene.get_tree().get_first_node_in_group("camera").enabled = false
	else:
		if active_scene != null:
			active_scene.queue_free()
		
	active_scene = new_scene.instantiate()
	main.add_child(active_scene)
	active_scene.get_tree().get_first_node_in_group("camera").enabled = true


func load_old_scene(scene_name: String, keep_loaded: bool = false) -> void:
	if main.get_node(scene_name) == null: push_error("No Scene Found")
	if keep_loaded:
		active_scene.hide()
		active_scene.process_mode = Node.PROCESS_MODE_DISABLED
		active_scene.get_tree().get_first_node_in_group("camera").enabled = false
	else:
		active_scene.queue_free()
		
	active_scene = main.get_node(scene_name)
	active_scene.process_mode = Node.PROCESS_MODE_PAUSABLE # TODO: Bug here?
	active_scene.show()
	active_scene.get_tree().get_first_node_in_group("camera").enabled = true
		

func on_enemy_killed() -> void:
	level_num += 1
	player.get_tree().call_group("cell", "unexhaust")
	player.set_block(0)
	change_scene(shop_scene, false)
	
	
func next_combat() -> void:
	# Choose Enemy
	var pool: Array
	if level_num in [1, 2]:
		pool = enemy_pools.easy
	elif level_num in [3, 4]:
		pool = enemy_pools.hard
	elif level_num >= 5:
		pool = enemy_pools.bossc
		
	change_scene(game_scene, false)
	enemy = load("res://Enemy/Types/Goblin/goblin.tscn").instantiate()
	GameManager.enemy = enemy
	get_tree().get_first_node_in_group("enemy_position").add_child(enemy)
	start_combat.emit()
