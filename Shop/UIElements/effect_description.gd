class_name EffectDescription extends Node2D

@export var shop_data := preload("res://Shop/shop_data.gd")
@onready var name_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/Name
@onready var effect_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/Effect

func set_data(effect: GDScript) -> void:
	name_label.text = "[center][color=%s]%s[/color]" % [Constants.RARITY_COLORS[effect.rarity], effect.name.capitalize()]
	effect_label.text = effect.description

func show_hovered_effect(layer: TileMapLayer) -> bool:
	var coords: Vector2 = layer.local_to_map(layer.get_local_mouse_position())
	var cell := layer.get_cell_tile_data(coords)
	if cell == null:
		hide()
		return false
	
	var effect: GDScript = cell.get_custom_data("effect")
	if effect == null or effect.name == "none":
		hide()
		return false

	var offset := Vector2(8, -24) # 8, 8 for corner
	
	position = layer.to_global(layer.map_to_local(coords) + offset)
	set_data(effect)
	show()
	return true
