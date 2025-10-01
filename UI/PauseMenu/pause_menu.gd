class_name PauseMenu extends MarginContainer

var paused: bool = false

func _toggle() -> void:
	get_tree().paused = !get_tree().paused
	visible = !visible

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle()


func _on_resume_pressed() -> void:
	_toggle()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	pass # Replace with function body.
