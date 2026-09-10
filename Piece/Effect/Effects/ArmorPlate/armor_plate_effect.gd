extends Effect

func on_place() -> void:
	gain_block(7)

func on_clear() -> void:
	gain_block(-7)
