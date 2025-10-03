class_name BasicAttack extends EnemyAttack


func trigger() -> void:
	GameManager.player.take_damage(damage)
