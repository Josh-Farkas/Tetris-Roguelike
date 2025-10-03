class_name Goblin extends Enemy

var gold_stolen: int

func _ready() -> void:
	super()
	GameManager.start_combat.connect(start_combat)


func start_combat() -> void:
	attack_layer = get_tree().get_first_node_in_group("attack_layer")
	base_layer = get_tree().get_first_node_in_group("base_layer")


func attack() -> void:
	if randf() < .8:
		# Damage
		_place_attack_randomly(Vector2i(1, 0))
	else:
		# Steal
		_place_attack_randomly(Vector2i(1, 2))


func _on_piece_placed(pieces_placed: int) -> void:
	super(pieces_placed)
	attack()
	


func steal(amount: int) -> void:
	amount = min(player.gold, amount)
	player.gold -= amount
	gold_stolen += amount
	
