class_name Steal extends EnemyAttack
## Attack that steals gold from the player

@export var amount: int = 1

func trigger() -> void:
	GameManager.player.lose_gold(amount)
