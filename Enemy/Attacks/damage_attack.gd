class_name GoblinAttack extends Attack

const ATLAS_COORDS = Vector2i(1, 0)
@export var damage: int


func trigger(user: Enemy) -> void:
	GameManager.player.take_damage(damage)
