class_name EffectDescription extends Node2D

@export var shop_data := preload("res://Shop/shop_data.gd")
@onready var name_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/Name
@onready var effect_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/Effect

func set_data(effect_name: StringName, description: String, rarity: StringName = "common") -> void:
	name_label.text = "[center][color=%s]%s[/color]" % [Constants.RARITY_COLORS[rarity], effect_name.capitalize()]
	effect_label.text = description

func show_hovered_effect(layer: TileMapLayer) -> bool:
	var coords: Vector2 = layer.local_to_map(layer.get_local_mouse_position())
	var cell := layer.get_cell_tile_data(coords)
	if cell == null:
		hide()
		return false
		
	var effect: StringName = cell.get_custom_data("effect")
	var rarity: StringName = cell.get_custom_data("rarity")
	if effect == "none" or effect == "":
		hide()
		return false

	var offset := Vector2(8, -24) # 8, 8 for corner
	
	position = layer.to_global(layer.map_to_local(coords) + offset)
	if !shop_data.effect_descriptions.has(effect): return false
	set_data(effect, shop_data.effect_descriptions[effect], rarity)
	show()
	return true
