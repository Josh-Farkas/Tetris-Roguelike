class_name Settings extends Resource

const SAVE_GAME_PATH: StringName = "user://player_settings.tres"

@export var test_setting: String = ""
@export_range(0, 1) var screenshake_magnitude: float = 1.0
@export_group("Sound")
@export var master_volume: float = 0.0
@export var music_volume: float = -20.0
@export var sfx_volume: float = 0.0
@export var muted: bool = false

func save_settings() -> void:
	ResourceSaver.save(self, SAVE_GAME_PATH)

static func load_settings() -> Settings:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return load(SAVE_GAME_PATH)
	return null
