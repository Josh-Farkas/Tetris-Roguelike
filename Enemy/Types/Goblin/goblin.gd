class_name Goblin extends Enemy

var gold_stolen: int = 0

func attack() -> void:
	if randf() < .8:
		_place_attack_randomly(attacks.get("Goblin Attack"))
	else:
		_place_attack_randomly(attacks.get("Goblin Steal"))


func _on_piece_placed(pieces_placed: int) -> void:
	super(pieces_placed)
	attack()

func die() -> void:
	super()
	GameManager.player.gold += int(ceil(gold_stolen / 2.0))
