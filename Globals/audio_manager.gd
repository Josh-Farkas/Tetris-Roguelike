extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

@export var level_music: AudioStream
@export var shop_music: AudioStream

func _ready() -> void:
	SignalBus.changed_scenes.connect(_on_scene_changed)
	play_shop_music()

## Play the given [param music]. [param volume] is offset to the default volume in dbs.
func _play_music(music: AudioStream, volume: float = GameManager.settings.volume) -> void:
	if music_player.stream == music: return
	if music == null:
		push_error("Failed to load music.")
		music_player.stop()
		return
	music_player.stream = music
	music_player.volume_db = volume
	music_player.play()

## Play the music for combat.
func play_level_music() -> void:
	return
	_play_music(level_music, GameManager.settings.music_volume)
	
## Play the music for the shop.
func play_shop_music() -> void:
	return
	_play_music(shop_music, GameManager.settings.music_volume)

## Plays the given sound [param sfx]. [param volume] is an offset from the default volume in dbs.
func play_SFX(sfx: AudioStream, volume: float = 0.0) -> void:
	if sfx == null:
		push_error("Failed to load SFX.")
		return
	var audio_player := AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = sfx
	audio_player.volume_db = volume + GameManager.settings.sfx_volume
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.play()

## Called when the scene is changed.
func _on_scene_changed(_from: Node, to: Node) -> void:
	match to.name:
		"Shop":
			play_shop_music()
		"TetrisMain":
			play_level_music()
	
