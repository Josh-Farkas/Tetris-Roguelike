class_name Goblin extends Enemy


#var attack_atlas_coords: Dictionary[Attack, Vector2] = {
	#Attack.DAMAGE: Vector2(1, 0),
	#Attack.STEAL: Vector2(2, 0),
#}


var gold_stolen: int

func _ready() -> void:
	super()
	GameManager.start_combat.connect(start_combat)


func start_combat() -> void:
	attack_layer = get_tree().get_first_node_in_group("attack_layer")
	base_layer = get_tree().get_first_node_in_group("base_layer")


func attack() -> void:
	#_place_attack_randomly()
	pass
#
#func attack1():
	#_place_attack_randomly()

func steal(amount: int) -> void:
	amount = min(player.gold, amount)
	player.gold -= amount
	gold_stolen += amount
	
