extends Control

@onready var deck_display: DeckDisplay = $VBoxContainer/DeckDisplay
@onready var effect_layer: TileMapLayer = $VBoxContainer/DeckDisplay/ScrollContainer/SubViewportContainer/SubViewport/Effects

@onready var selected_effect: Vector2i = GameManager.bought_effect
@onready var selected_effect_coords: Vector2i = effect_layer.local_to_map(effect_layer.get_local_mouse_position())
var prev_coords: Vector2i
var can_place: bool = false

#func _ready() -> void:
	#SignalBus.scene_changed.connect(_on_scene_changed)
	#
#func _on_scene_changed()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_overlay_effect()
		
	
	if event.is_action_pressed("click") and can_place:
		_place_effect()


func _overlay_effect() -> void:
	if selected_effect == Vector2i.ZERO: return
	var coords: Vector2i = effect_layer.local_to_map(effect_layer.get_local_mouse_position())
	
	if coords != selected_effect_coords: # over new cell
		# prevents bug where empty cell is set to None on first frames
		if effect_layer.get_cell_tile_data(selected_effect_coords) != null:
			effect_layer.set_cell(selected_effect_coords, 1, Constants.EFFECT_COORDS.NONE)
		var cell := effect_layer.get_cell_tile_data(coords)
		can_place = cell != null and cell.get_custom_data("effect") == "none"
	
		if cell == null or cell.get_custom_data("effect") != "none":
			selected_effect_coords = Vector2i.ZERO
			return

		selected_effect_coords = coords
		effect_layer.set_cell(coords, 1, selected_effect)


func _place_effect() -> void:
	var coords: Vector2i = effect_layer.local_to_map(effect_layer.get_local_mouse_position())
	if effect_layer.get_cell_tile_data(coords) == null: return
	var cell: Cell = deck_display.cell_coords[coords]
	cell.effect_atlas_coords = selected_effect
	cell.unexhausted_atlas_coords = selected_effect
	
	var source: TileSetAtlasSource = effect_layer.tile_set.get_source(1)
	cell.fragile = source.get_tile_data(selected_effect, 0).get_custom_data("fragile")
	
	selected_effect = Vector2i.ZERO
	

func _on_return_button_pressed() -> void:
	GameManager.change_scene("Shop", false)
