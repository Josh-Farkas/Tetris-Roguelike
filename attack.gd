@abstract
class_name EnemyAttack extends Resource
## Base resource for all enemy attacks

@export var name: String
@export var damage: int

@abstract
func trigger() -> void
