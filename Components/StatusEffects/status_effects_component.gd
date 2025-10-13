class_name StatusEffectsComponent extends Node

signal tranquility_changed(amount: int)
signal status_changed(new_status: Dictionary)

var status_effects: Dictionary = {
	"strength": 0, # flat damage increase to attacks
	"weakness": 0, # flat damage reduction to attacks ?
	"accuracy": 0, # flat damage increase to RANGED attacks
	"poison": 0, # Take damage every time a piece is placed, then reduced by 1
	"confusion": 0, # Piece rotation is randomized and spinning ?
	"blindness": 0, # Can't see board? can't see up next?
	"tranquility": 0, # makes the game tick slower, -1 per piece placed
	"panic": 0, # makes the game tick faster, -1 per piece placed
	"rage": 0, # makes time based enemies attack faster
}:
	set(value):
		status_effects = value
		status_changed.emit(value)


func _ready() -> void:
	SignalBus.piece_placed.connect(_on_piece_placed)


func get_status_effect(status: StringName) -> int:
	return status_effects[status]


func gain_status_effect(status: StringName, amount: int) -> void:
	status_effects[status] += amount
	if status == "tranquility":
		tranquility_changed.emit(amount)
	status_changed.emit()


func lose_status_effect(status: StringName, amount: int) -> void:
	gain_status_effect(status, -amount)


func set_effect(status: StringName, value: int) -> void:
	if status == "tranquility":
		tranquility_changed.emit(value - status_effects[status])
	status_effects[status] = value
	status_changed.emit()


func mult_status_effect(status: StringName, value: int) -> void:
	if status == "tranquility":
		tranquility_changed.emit(status_effects[status] * value - status_effects[status])
	status_effects[status] *= value
	status_changed.emit()


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
	status_changed.emit()


func _on_piece_placed(amount_placed: int) -> void:
	if status_effects.poison > 0:
		lose_status_effect("poison", 1)
	mult_status_effect("tranquility", .5)
