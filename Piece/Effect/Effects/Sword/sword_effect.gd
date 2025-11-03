class_name SwordEffect extends Effect
	
func _init() -> void:
	data = load("res://Piece/Effect/Effects/Sword/sword_data.tres")

func on_place() -> void:
	deal_damage(2)
	
