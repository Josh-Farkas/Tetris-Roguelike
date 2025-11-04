class_name Player extends Node

signal damaged
signal health_changed
signal max_health_changed
signal gold_changed
signal block_changed

@export_category("Deck")
@export var full_deck: Deck = Deck.new()
@export var preview_size: int = 3

@export_category("Stats")
@export var max_health: int = 100:
	set(value):
		max_health = value
		max_health_changed.emit()
@export var health: int = 100:
	set(value): 
		health = value
		health_changed.emit()
@export var gold: int = 99999:
	set(value):
		gold = value
		gold_changed.emit()
@export var block: int = 0:
	set(value):
		block = value
		block_changed.emit()

@export_range(0, 1) var base_crit_chance: float = .01

@onready var status_effects: StatusEffectsComponent = $StatusEffectsComponent

func _ready() -> void:
	pass


func take_damage(amount: int) -> void:
	var blocked_dmg: int = min(amount, block)
	var health_dmg: int = amount - blocked_dmg
	block -= blocked_dmg
	health -= health_dmg
	print("Player took %s damage" % health_dmg)
	if health < 0:
		die()


func heal(amount: int) -> void:
	health += amount
	health = min(health, max_health)


func gain_block(amount: int) -> void:
	block += amount
	block = min(block, max_health)
	
	
func lose_block(amount: int) -> void:
	block -= amount
	block = max(block, 0)
	
func set_block(amount: int) -> void:
	block = amount


func die() -> void:
	pass


func gain_gold(amount: int) -> void:
	gold += amount


func lose_gold(amount: int) -> void:
	gold -= amount
	gold = max(0, gold)


func add_piece(piece: Piece) -> void:
	full_deck.append(piece)
	$Deck.add_child(piece)


func reset_status_effects() -> void:
	pass
