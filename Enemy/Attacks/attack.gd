@abstract
class_name Attack extends Resource

@export var atlas_coords: Vector2i
@export var name: String

@abstract
func trigger(user: Enemy) -> void
