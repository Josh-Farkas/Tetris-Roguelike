class_name StatusEffectsUI extends HBoxContainer

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
	"rage": $Rage, # TODO: Make Icon
}


func update_ui(new_status: Dictionary) -> void:
	for status: String in new_status:
		if not status_effect_nodes[status].get_node("Label").visible and new_status[status] != 0:
			status_effect_nodes[status].show()
			move_child(status_effect_nodes[status], -1)
		elif new_status[status] == 0:
			status_effect_nodes[status].hide()	
		status_effect_nodes[status].get_node("Label").text = str(new_status[status])
