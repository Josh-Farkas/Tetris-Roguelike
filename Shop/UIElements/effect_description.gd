class_name EffectDescription extends Node2D

@export var shop_data := preload("res://Shop/shop_data.gd")
@onready var name_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/Name
@onready var effect_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/Effect

func set_data(effect_data: EffectData) -> void:
	name_label.text = effect_data.get_formatted_name()
	effect_label.text = effect_data.get_formatted_description()

func show_hovered_effect(layer: TileMapLayer) -> bool:
	var coords: Vector2 = layer.local_to_map(layer.get_local_mouse_position())
	var cell := layer.get_cell_tile_data(coords)
	if cell == null:
		hide()
		return false
	
	var effect_data: EffectData = cell.get_custom_data("effect")
	if effect_data == null or effect_data.name == "None":
		hide()
		return false

	var offset := Vector2(8, -24) # 8, 8 for corner
	
	position = layer.to_global(layer.map_to_local(coords) + offset)
	set_data(effect_data)
	show()
	return true
