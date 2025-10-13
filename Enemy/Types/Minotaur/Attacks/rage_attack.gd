class_name RageAttack extends EnemyAttack


func trigger() -> void:
	print("Rage Triggered")
	GameManager.enemy.status_effects.gain_effect("rage", 1)
