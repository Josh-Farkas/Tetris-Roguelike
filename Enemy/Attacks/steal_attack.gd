class_name StealAttack extends EnemyAttack
## Attack that steals gold from the player

@export var steal_amount: int = 1

func trigger() -> void:
	var amount: int = min(GameManager.player.gold, steal_amount)
	GameManager.player.lose_gold(amount)
	if "gold_stolen" in GameManager.enemy:
		GameManager.enemy.gold_stolen += amount
	
