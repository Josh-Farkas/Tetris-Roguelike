class_name Camera extends Camera2D


var shaking: bool = false
var _amplitude: float = 0

func screenshake(amplitude: float = 30, duration: float = 1) -> void:
	shaking = true
	_amplitude = amplitude
	await get_tree().create_timer(duration).timeout
	shaking = false
	offset = Vector2.ZERO

func shake(amplitude: float) -> void:
	offset = Vector2.from_angle(randf_range(0, 2*PI)) * amplitude


func _process(delta: float) -> void:
	if shaking:
		shake(_amplitude * delta)
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("click"):
		#screenshake(40, 1)

func disable() -> void:
	enabled = false

func enable() -> void:
	enabled = true
