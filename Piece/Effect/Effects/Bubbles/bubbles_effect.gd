class_name BubblesEffect extends Effect

func on_clear() -> void:
	deal_damage(cell.coords.y)
