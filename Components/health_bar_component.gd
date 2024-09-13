class_name HealthBarComponent extends VBoxContainer

var max_health: int
var health: int
var block: int

func set_health(value: int) -> void:
	health = value
	$HBoxContainer/HealthBar.value = value
	$HboxContainer/HealthLabel.text = "%s/%s" % [health, max_health]
	
func set_max_health(value: int) -> void:
	max_health = value
	$HealthBar.max_value = value
	$HealthBar/BlockBar.max_value = value
	$HealthLabel.text = "%s/%s" % [health, max_health]
	
func set_block(value: int) -> void:
	block = value
	$HealthBar/BlockBar.value = value
