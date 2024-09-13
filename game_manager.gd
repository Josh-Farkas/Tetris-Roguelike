extends Node

signal start_combat

@onready var player: Player = preload("res://Player/player.tscn").instantiate()
var main: Node
var enemy: Enemy
var active_scene: Node
var bought_effect: Vector2i = Vector2i.ZERO

# SCENES
@onready var game_scene: PackedScene = preload("res://Tetris/tetris.tscn")
@onready var shop_scene: PackedScene = preload("res://Shop/shop.tscn")
@onready var apply_effect_scene: PackedScene = preload("res://Shop/Apply Effect/apply_effect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main = get_tree().get_first_node_in_group("main")
	if main != null:
		#change_scene(shop_scene)
		change_scene(game_scene)
		await get_tree().create_timer(1).timeout
		start_combat.emit()

func change_scene(new_scene: PackedScene, keep_loaded: bool = false) -> void:
	if keep_loaded:
		active_scene.hide()
		active_scene.process_mode = Node.PROCESS_MODE_DISABLED
		active_scene.get_tree().get_first_node_in_group("camera").enabled = false
	else:
		if active_scene != null:
			main.remove_child(active_scene)
		
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
		main.remove_child(active_scene)
		
	active_scene = main.get_node(scene_name)
	active_scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	active_scene.show()
	active_scene.get_tree().get_first_node_in_group("camera").enabled = true
		

func on_enemy_killed() -> void:
	change_scene(shop_scene, false)
