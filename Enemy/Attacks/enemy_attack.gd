@abstract
class_name EnemyAttack extends Resource
## Base resource for all enemy attacks

@export var name: StringName
@export var description: String
@export var atlas_coords: Vector2i = Vector2i.ZERO

@abstract
func trigger() -> void
