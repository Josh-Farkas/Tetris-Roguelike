class_name PlayerUI extends PanelContainer

@onready var player: Player = GameManager.player
@onready var health_bar: HealthBarComponent = $MarginContainer/VBoxContainer/HealthBarComponent
@onready var status_effects_ui: StatusEffectsUI = $MarginContainer/VBoxContainer/HealthBarComponent/StatusEffectsUI

func _ready() -> void:
	player.max_health_changed.connect(_update_ui)
	player.health_changed.connect(_update_ui)
	player.gold_changed.connect(_update_ui)
	player.block_changed.connect(_update_ui)
	player.status_effects.status_changed.connect(_update_ui)
	_update_ui()

func _update_ui() -> void:
	$MarginContainer/VBoxContainer/HBoxContainer2/GoldLabel.text = str(player.gold)
	health_bar.set_health(player.health)
	health_bar.set_max_health(player.max_health)
	health_bar.set_block(player.block)
	status_effects_ui.update_ui(player.status_effects.status_effects)
