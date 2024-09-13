class_name StatusEffectsComponent extends HBoxContainer

signal tranquility_gained

var status_effects: Dictionary = {
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

	
@onready var status_effect_nodes: Dictionary = {
	"strength": $Strength,
	"weakness": $Weakness,
	"prayer": $Blindness,
	"accuracy": $Accuracy,
	"tranquility": $Poison,
	"poison": $Confusion,
	"confusion": $Tranquility,
	"blindness": $Panic,
	"panic": $Prayer,
}

func get_status(status: StringName) -> int:
	return status_effects[status]


func gain_effect(status: StringName, amount: int) -> void:
	if status_effects[status] == 0 and amount != 0:
		move_child(status_effect_nodes[status], -1)
		status_effect_nodes[status].show()
	status_effects[status] += amount
	if status == "Tranquility":
		tranquility_gained.emit()
	if status_effects[status] == 0:
		status_effect_nodes[status].hide()
		
func lose_effect(status: StringName, amount: int) -> void:
	gain_effect(status, -amount)
	
	
func set_effect(status: StringName, value: int) -> void:
	if status_effects[status] == 0:
		move_child(status_effect_nodes[status], -1)
		status_effect_nodes[status].show()
	if value == 0:
		status_effect_nodes[status].hide()
	status_effects[status] = value
	
func mult_effect(status: StringName, value: int) -> void:
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
