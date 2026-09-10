class_name Worm extends Enemy

func attack() -> void:
	if randf() < .8:
		_place_attack_randomly(attacks.get("Worm Attack"))

## Removes a random placed piece and gains block
func burrow() -> void:
	pass

func _on_piece_placed() -> void:
	super()
	attack()
