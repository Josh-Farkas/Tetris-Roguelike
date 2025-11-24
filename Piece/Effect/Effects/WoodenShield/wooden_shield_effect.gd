class_name WoodenShield extends Effect

func on_clear() -> void:
	deal_damage(player.block * 0.2)
