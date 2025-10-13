class_name Minotaur extends Enemy

@export var attack_speed: float = 5.0
@export var max_attack_speed: float = 2.0

func _ready() -> void:
	super()
	$AttackTimer.wait_time = attack_speed

func attack() -> void:
	_place_attack_randomly(attacks.get("Minotaur Attack"))


func _on_attack_timer_timeout() -> void:
	attack()
	
func take_damage(amount: float) -> void:
	super(amount)
	if amount <= 0: return # Can change this so it only rages when big chunks of damage are taken
	_place_attack_randomly(attacks.get("Rage"))


func _on_status_changed(new_status: Dictionary[StringName, int]) -> void:
	super(new_status)
	$AttackTimer.wait_time = max(attack_speed - new_status.rage, max_attack_speed)
	print("new wait time is", $AttackTimer.wait_time)
