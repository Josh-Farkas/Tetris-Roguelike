class_name BasicAttack extends EnemyAttack

@export var damage: int

func trigger() -> void:
	GameManager.player.take_damage(damage)
