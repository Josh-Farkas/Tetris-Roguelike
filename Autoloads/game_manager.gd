extends Node


const easy_pool: Array[PackedScene] = [
	#preload("res://Enemy/Types/Goblin/goblin.tscn"),
	preload("res://Enemy/Types/Minotaur/minotaur.tscn"),
]
const hard_pool: Array[PackedScene] = []

const elite_pool: Array[PackedScene] = []
const boss_pool: Array[PackedScene] = []

const scenes: Dictionary[StringName, PackedScene] = {
	"Shop": preload("res://Shop/shop.tscn"),
	"TetrisMain": preload("res://Tetris/tetris.tscn"),
	"ApplyEffectMenu": preload("res://Shop/ApplyEffect/apply_effect.tscn"),
}

var player: Player = preload("res://Player/player.tscn").instantiate()
var main: Node
var enemy: Enemy
var active_scene: Node
var bought_effect: Vector2i = Vector2i.ZERO
var level_num: int = 1
var camera: Camera
var loaded_scenes: Dictionary[StringName, Node] = {}
var board_height := 22 # two hidden rows above for pieces to spawn
var board_width := 10


func _ready() -> void:
	SignalBus.enemy_killed.connect(_on_enemy_killed)
	add_child(player)
	main = get_tree().get_first_node_in_group("main")
	if main != null:
		change_scene("Shop")
	else:
		push_error("Failed to load main scene")


func change_scene(new_scene: StringName, keep_loaded: bool = true) -> void:
	if active_scene != null:
		if keep_loaded:
			active_scene.hide()
			active_scene.process_mode = Node.PROCESS_MODE_DISABLED
			loaded_scenes[active_scene.name] = active_scene
			camera.disable()
		else:
			loaded_scenes.erase(active_scene.name)
			active_scene.queue_free()
	
	var old_scene := active_scene
	if new_scene in loaded_scenes:
		active_scene = loaded_scenes[new_scene]
		active_scene.process_mode = Node.PROCESS_MODE_INHERIT
		active_scene.show()
	else:
		active_scene = scenes[new_scene].instantiate()
		loaded_scenes[new_scene] = active_scene
		main.add_child(active_scene)
	main.move_child(active_scene, 0)
	get_tree().call_group("camera", "disable")
	camera = active_scene.get_tree().get_first_node_in_group("camera")
	if camera != null: camera.enable()
	SignalBus.changed_scenes.emit(old_scene, active_scene)


func _on_enemy_killed() -> void:
	level_num += 1
	player.get_tree().call_group("cell", "unexhaust")
	player.set_block(0)
	change_scene("Shop", false)
	
	
func next_combat() -> void:
	# Choose Enemy
	var pool: Array[PackedScene]
	if level_num in [1, 2]:
		pool = easy_pool
	elif level_num in [3, 4]:
		pool = hard_pool
	else:
		pool = boss_pool
		
	if pool != []:
		enemy = pool.pick_random().instantiate()
	else:
		enemy = load("res://Enemy/Types/Goblin/goblin.tscn").instantiate()
	
	change_scene("TetrisMain", false)
	get_tree().get_first_node_in_group("enemy_position").add_child(enemy)
	GameManager.enemy = enemy
	SignalBus.start_combat.emit()
