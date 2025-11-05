class_name Settings extends Resource

const SAVE_GAME_PATH: StringName = "user://player_settings.tres"

@export var test_setting: String = ""
@export_range(0, 1) var screenshake_magnitude: float = 1.0
@export var seed: int:
	set(value):
		seed = value
		seed(seed)

func save_settings() -> void:
	ResourceSaver.save(self, SAVE_GAME_PATH)

static func load_settings() -> Settings:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return load(SAVE_GAME_PATH)
	return null
