class_name Player extends Control

signal piece_placed
signal damaged

var piggy_bank_stored: int = 0

var full_deck: Array[Piece]

@onready var health_bar: HealthBarComponent = $MarginContainer/VBoxContainer/HealthBarComponent
@onready var status_effects: StatusEffectsComponent = health_bar.get_node("StatusEffectsComponent")
@onready var gold_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/MoneyLabel

@export var max_health: int = 100:
	set(value):
		max_health = value
		health_bar.set_max_health(value)
@export var health: int = 100:
	set(value): 
		health = value
		health_bar.set_health(value)
@export var gold: int = 999:
	set(value):
		gold = value
		_update_ui()
@export var block: int = 0:
	set(value):
		block = value
		health_bar.set_block(value)

@export_range(0, 1) var base_crit_chance: float = .01

func _ready() -> void:
	full_deck.append_array($Deck.get_children() as Array[Piece])
	_update_ui()


func take_damage(amount: int) -> void:
	health -= amount
	if health < 0:
		die()
	_update_ui()


func heal(amount: int) -> void:
	health += amount
	health = min(health, max_health)


func gain_block(amount: int) -> void:
	block += amount
	block = min(block, max_health)
	
	
func lose_block(amount: int) -> void:
	block -= amount
	block = max(block, 0)


func _update_ui() -> void:
	#health_label.text = "%s/%s" % [health, max_health]
	gold_label.text = str(gold)


func die() -> void:
	pass


func add_piece(piece: Piece) -> void:
	full_deck.append(piece)
	$Deck.add_child(piece)



func reset_status_effects() -> void:
	pass
