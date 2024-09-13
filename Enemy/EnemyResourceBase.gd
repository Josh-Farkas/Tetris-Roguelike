class_name EnemyResourceBase extends Resource

@export var name: String
@export_category("Stats")
@export var max_health: int
@export var defense: int
@export var damage: int
@export var attack_speed: float

@export_category("Data")
@export var texture: Texture
@export var enemy_script: Script
