class_name HealthBarComponent extends VBoxContainer

@onready var health_label: Label = $HBoxContainer/VBoxContainer/HealthLabel
@onready var block_label: Label = $HBoxContainer/VBoxContainer/BlockLabel

var max_health: int
var health: int = max_health
var block: int = 0

func set_health(value: int) -> void:
	health = value
	$HBoxContainer/HealthBar.value = value
	health_label.text = "%s/%s" % [health, max_health]
	
func set_max_health(value: int) -> void:
	max_health = value
	$HBoxContainer/HealthBar.max_value = value
	$HBoxContainer/HealthBar/BlockBar.max_value = value
	health_label.text = "%s/%s" % [health, max_health]
	
func set_block(value: int) -> void:
	block = value
	$HBoxContainer/HealthBar/BlockBar.value = value
	block_label.text = str(value) if value != 0 else ""
