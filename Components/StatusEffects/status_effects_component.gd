class_name StatusEffectsComponent extends Node

signal tranquility_changed(amount: int)
signal status_changed(new_status: Dictionary)

var status_effects: Dictionary = {
	"strength": 0, # flat damage increase to attacks
	"weakness": 0, # flat damage reduction to attacks ?
	"prayer": 0, #
	"accuracy": 0, # flat damage increase to RANGED attacks
	"tranquility": 0, # 
	"poison": 0, # Take damage every time a piece is placed, then reduced by 1
	"confusion": 0, # Piece rotation is randomized and spinning ?
	"blindness": 0, # Can't see board? can't see up next?
	"panic": 0 # 
}:
	set(value):
		status_effects = value
		status_changed.emit(value)

func _ready() -> void:
	SignalBus.piece_placed.connect(_on_piece_placed)


func get_status(status: StringName) -> int:
	return status_effects[status]


func gain_effect(status: StringName, amount: int) -> void:
	status_effects[status] += amount
	if status == "tranquility":
		tranquility_changed.emit(amount)


func lose_effect(status: StringName, amount: int) -> void:
	gain_effect(status, -amount)
	
	
func set_effect(status: StringName, value: int) -> void:
	if status == "tranquility":
		tranquility_changed.emit(value - status_effects[status])
	status_effects[status] = value

	
func mult_effect(status: StringName, value: int) -> void:
	if status == "tranquility":
		tranquility_changed.emit(status_effects[status] * value - status_effects[status])
	status_effects[status] *= value


func reset() -> void:
	status_effects = {
		"strength": 0,
		"weakness": 0,
		"prayer": 0,
		"accuracy": 0,
		"tranquility": 0,
		"poison": 0,
		"confusion": 0,
		"blindness": 0,
		"panic": 0
	}


func _on_piece_placed(amount_placed: int) -> void:
	if status_effects.poison > 0:
		status_effects.poison -= 1
	status_effects.tranquility = int(status_effects.tranquility/2)
