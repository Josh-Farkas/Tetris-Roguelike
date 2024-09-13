class_name Goblin extends Enemy

var attack_layer: TileMapLayer
var base_layer: TileMapLayer
var attack_atlas_coords: Vector2i = Vector2i(1, 0)

func _ready() -> void:
	super()
	GameManager.start_combat.connect(start_combat)
	$AttackTimer.wait_time = resource.attack_speed
	
func start_combat() -> void:
	attack_layer = get_tree().get_first_node_in_group("attack_layer")
	base_layer = get_tree().get_first_node_in_group("base_layer")

	$AttackTimer.start()
	

func _attack() -> void:
	for __ in range(10):
		var coords: Vector2i = Vector2i(randi_range(0, 10), randi_range(0, 20))
		if base_layer.get_cell_tile_data(coords) == null:
			attack_layer.set_cell(coords, 0, attack_atlas_coords)
			break


func _on_attack_timer_timeout() -> void:
	_attack()
