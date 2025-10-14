class_name TetrisGame extends Node2D

const WIDTH: int = 10
const HEIGHT: int = 22
const WALLKICKS = preload("res://Tetris/wallkicks.gd").WALLKICKS
const WALLKICKS_I = preload("res://Tetris/wallkicks.gd").WALLKICKS_I
const NEIGHBORS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

const DAMAGE_AMTS := {
	1: 1,
	2: 3,
	3: 6,
	4: 10
}


@onready var background_layer: TileMapLayer = $Background
@onready var attack_layer: TileMapLayer = $Attack
@onready var base_layer: TileMapLayer = $Base
@onready var effect_layer: TileMapLayer = $Effect
@onready var base_ghost_layer: TileMapLayer = $BaseGhost
@onready var effect_ghost_layer: TileMapLayer = $EffectGhost

@onready var tick_timer: Timer = $TickTimer

@onready var effect_layers: Dictionary = {
	base_layer: effect_layer,
	base_ghost_layer: effect_ghost_layer
}

#@onready var target_enemy: Enemy = get_tree().get_first_node_in_group("enemy") as Enemy
@onready var player: Player = GameManager.player
@onready var crit_chance: float = player.base_crit_chance

var enemy: Enemy = null

var full_deck: Array[Piece]
var deck: Array[Piece]
var discard: Array[Piece] = []
var up_next: Array[Piece] = []

var active_piece: Piece = null
var fall_speed: float = 1
var num_up_next: int = 1
var cells_to_clear: Dictionary # row: [col1, col2, col3]
var effect_queue: Dictionary[Vector2i, StringName]
var damage: int
var pieces_placed: int = 0


var effect_counts: Dictionary = {}
var type_counts: Dictionary = {
	"RANGED": 0,
	"MELEE": 0,
	"ARROW": 0,
	"SHIELD": 0,
	"SUPPORT": 0,
	"BUILDING": 0,
	"ECONOMY": 0,
	"SCIENCE": 0,
	"ARMOR": 0,
	"EXPLOSIVE": 0,
	"MUSIC": 0,
	"MISC": 0,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.start_combat.connect(_on_start_combat)
	#player.status_effects.tranquility_gained.connect(_on_tranquility_gained)
	for row in HEIGHT:
		cells_to_clear[row] = {}
	#add_child(player) # jank to call _ready() in player TODO: find better solution
	#remove_child(player)
	full_deck = player.full_deck.duplicate()
	deck = full_deck.duplicate()
	shuffle()
	for __ in num_up_next:
		up_next.append(deck.pop_front())
	spawn_piece()


func _on_start_combat() -> void:
	enemy = GameManager.enemy
	tick_timer.wait_time = enemy.base_tick_rate


func tick() -> void:
	move_piece(active_piece, Vector2i.DOWN)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()
		
	if event.is_action_pressed("right"):
		move_piece(active_piece, Vector2i.RIGHT)
		
	elif event.is_action_pressed("left"):
		move_piece(active_piece, Vector2i.LEFT)
	
	if event.is_action_pressed("soft_drop"):
		move_piece(active_piece, Vector2i.DOWN)
		
	if Input.is_action_just_pressed("hard_drop"):
		while move_piece(active_piece, Vector2i.DOWN): pass
		
	if Input.is_action_just_pressed("rotate"):
		rotate_piece(active_piece, 1)
	
	if Input.is_action_just_pressed("rotate_reversed"):
		rotate_piece(active_piece, -1)


func shuffle() -> void:
	deck = full_deck.duplicate()
	deck.shuffle()
	discard.clear()
	

func set_cell(layer: TileMapLayer, coords: Vector2i, base_atlas_coords: Vector2i = Vector2i.ZERO, effect_atlas_coords: Vector2i = Vector2i.ZERO, alternative_tile: int = 0) -> void:
	layer.set_cell(coords, 0, base_atlas_coords, alternative_tile)
	effect_layers[layer].set_cell(coords, 1, effect_atlas_coords, alternative_tile)


func erase_cell(layer: TileMapLayer, coords: Vector2i, trigger_effects: bool = false) -> void:
	if trigger_effects:
		if effect_layer.get_cell_tile_data(coords) != null:
			var effect: StringName = _get_effect(coords)
			var effect_types: Array[StringName] = _get_effect_types(coords)
			
			effect_counts[effect] -= 1
			for type: StringName in effect_types:
				type_counts[type] -= 1
			
			effect_layer.erase_cell(coords)
	layer.erase_cell(coords)
	effect_layers[layer].erase_cell(coords)


func _clear_cell(row: int, col: int) -> void:
	cells_to_clear[row][col] = null
	for neighbor in NEIGHBORS:
		match _get_effect(neighbor):
			"dagger":
				deal_damage(3)


func _get_effect(coords: Vector2i) -> StringName:
	var data: TileData = effect_layer.get_cell_tile_data(coords)
	if data == null: return "none"
	return data.get_custom_data("effect")
	
func _get_effect_types(coords: Vector2i) -> Array:
	var data: TileData = effect_layer.get_cell_tile_data(coords)
	if data == null: return []
	return data.get_custom_data("effect type")

func draw_piece(piece: Piece = active_piece, draw_shadow: bool = true) -> void:
	for cell in piece.cells:
		set_cell(base_layer, piece.coords + cell.offset, cell.base_atlas_coords, cell.effect_atlas_coords)
	if draw_shadow: draw_shadow(piece)
	

func remove_piece(piece: Piece = active_piece, remove_shadow: bool = true) -> void:
	for cell in piece.cells:
		erase_cell(base_layer, piece.coords + cell.offset)
	if remove_shadow:
		remove_shadow(piece)


func draw_shadow(piece: Piece = active_piece) -> void:
	var y: int = 1
	while not check_collision(piece, Vector2i.DOWN * y, 0, base_layer):
		y += 1
	y -= 1
	piece.shadow_y = y
	for cell in piece.cells:
		set_cell(base_ghost_layer, piece.coords + Vector2i.DOWN * y + cell.offset, cell.base_atlas_coords, cell.effect_atlas_coords)


func remove_shadow(piece: Piece = active_piece) -> void:
	for cell in piece.cells:
		erase_cell(base_ghost_layer, piece.coords + Vector2i.DOWN * piece.shadow_y + cell.offset)


func move_piece(piece: Piece, dir: Vector2i, collision_enabled: bool = true) -> bool:
	if collision_enabled and check_collision(piece, dir):
		if dir.y >= 1: place_piece(piece)
		return false
	remove_piece(piece)
	piece.coords += dir
	draw_piece(piece)
	return true


func rotate_piece(piece: Piece = active_piece, rot: int = 1) -> void:
	# TODO: If needed you can rotate before collision check and rotate back, but less readable
	if rot == 0: return
	#if check_collision(piece, Vector2i.ZERO, rot):
	var kicks: Array = WALLKICKS if piece.shape != Piece.Shape.I else WALLKICKS_I
	# add one to rotation since piece hasn't been rotated yet
	kicks = kicks[(piece.rotation + 1) % 4] # BUG: Might need to be +2 for cc rotation
	for vec: Vector2i in kicks:
		vec *= sign(rot)
		if not check_collision(piece, vec, rot):
			remove_piece(piece)
			piece.rotate(rot)
			piece.coords += vec
			draw_piece(piece)
			return
	
	
func check_collision(piece: Piece, dir: Vector2i = Vector2i.ZERO, rot: int = 0, layer: TileMapLayer = base_layer) -> bool:
	remove_piece(piece, false)
	piece.rotate(rot)
	
	var collided: bool = false
	for cell: Cell in piece.cells:
		if layer.get_cell_tile_data(piece.coords + cell.offset + dir) != null:
			collided = true
			break
			
	piece.rotate(-rot)
	draw_piece(piece, false)
	return collided



func place_piece(piece: Piece) -> void:
	for cell: Cell in piece.cells:
		var coords: Vector2i = piece.coords + cell.offset
		
		# Cell effects
		var effect: StringName = _get_effect(coords)
		if not effect_counts.has(effect):
			effect_counts[effect] = 0
		effect_counts[effect] += 1
		
		var effect_types: Array = _get_effect_types(coords)
		for type: StringName in effect_types:
			if not effect_counts.has(type):
				type_counts[effect_types] = 0
			effect_counts[effect] += 1
		_trigger_on_place_effect(effect, coords)
		_trigger_adjacent_place_effects(effect, coords)
		
		# Enemy Attacks
		var data: TileData = attack_layer.get_cell_tile_data(coords)
		if data == null: continue
		var attack: EnemyAttack = data.get_custom_data("attack_resource")
		if attack == null: continue
		attack.trigger()
		#var damage: int = data.get_custom_data("damage")
		#player.take_damage(damage * enemy.damage)
		#if data.get_custom_data("clear_on_place"):
			#attack_layer.erase_cell(coords)
	
	_trigger_effects()
	_erase_cleared_cells()
	
	remove_shadow(piece)
	piece.set_rotation(0)
	clear_lines()
	spawn_piece()
	pieces_placed += 1
	SignalBus.piece_placed.emit(pieces_placed)
	
	
func spawn_piece() -> void:
	if deck.is_empty():
		shuffle()

	var piece: Piece = up_next.pop_front()
	up_next.append(deck.pop_front())
	# Coins
	var coin_chance := 0.1
	for cell in up_next[-1].cells:
		if cell.exhausted:
			cell.effect_atlas_coords = Vector2i.ZERO
		if cell.effect_atlas_coords == Vector2i(0, 1):
			cell.effect_atlas_coords = Vector2i.ZERO
		if cell.effect_atlas_coords == Vector2i.ZERO:
			if randf() < coin_chance:
				cell.effect_atlas_coords = Vector2i(0, 1)
		if cell.fragile:
			cell.exhausted = true
	_draw_next()
	
	active_piece = piece
	piece.coords = Vector2i(4, 1)
	if check_collision(piece, Vector2i.ZERO, 0, base_layer):
		piece.coords += Vector2i.UP
		if check_collision(piece, Vector2i.ZERO, 0, base_layer):
			lose()
			return
	draw_piece(piece, true)


func _draw_next() -> void:
	# Clear up next
	for x in range(11, 15):
		for y in range(2, 10):
			erase_cell(base_layer, Vector2i(x, y))
	
	# Draw up next
	for n in num_up_next:
		up_next[n].coords = Vector2i(11, 5 * n + 2)
		draw_piece(up_next[n], false)


func check_line(row: int) -> bool:
	for col in WIDTH:
		if base_layer.get_cell_tile_data(Vector2i(col, row)) == null:
			return false
	return true


func clear_lines() -> void:
	var rows := []
	for row in HEIGHT:
		if check_line(row):
			rows.append(row)
	if rows.is_empty(): return
	
	var num_cleared := len(rows)
	var base_damage: int = DAMAGE_AMTS[num_cleared]
	damage = base_damage
	for row: int in rows: # goes top down
		for col: int in WIDTH:
			_clear_cell(row, col)
			_queue_effect(row, col)
			var cell_effect: String = _get_effect(Vector2i(col, row))

	_trigger_effects()
	deal_damage(damage)
	_erase_cleared_cells()


func lower_rows_above(start_row: int) -> void:
	for row: int in range(start_row, 0, -1):
		for col: int in WIDTH:
			set_cell(base_layer, Vector2i(col, row), base_layer.get_cell_atlas_coords(Vector2i(col, row - 1)), effect_layer.get_cell_atlas_coords(Vector2i(col, row - 1)))


func lower_column_above(start_row: int, col: int) -> void:
	for row: int in range(start_row, 0, -1):
		set_cell(base_layer, Vector2i(col, row), base_layer.get_cell_atlas_coords(Vector2i(col, row - 1)), effect_layer.get_cell_atlas_coords(Vector2i(col, row - 1)))


func _erase_cleared_cells() -> void:
	for row: int in HEIGHT:
		for col: int in cells_to_clear[row].keys():
			erase_cell(base_layer, Vector2i(col, row), false)
			lower_column_above(row, col)
		cells_to_clear[row] = {}
		

func deal_damage(damage: float) -> void:
	enemy.take_damage(damage + player.status_effects.get_status_effect("strength"))
	if damage >= 3:
		GameManager.camera.screenshake(5 * min(damage, 8), .5)


func lose() -> void:
	print("YOU LOST")


func _get_effect_count(effect: String) -> int:
	if effect not in effect_counts:
		effect_counts[effect] = 0
	return effect_counts[effect]

# PIECE EFFECT FUNCTIONS
func explode(coords: Vector2i, radius: int) -> void:
	for col in range(coords.x - radius, coords.x + radius + 1):
		if col < 0 or col >= WIDTH: continue
		for row in range(coords.y - radius, coords.y + radius + 1):
			if row < 0 or row >= HEIGHT: continue
			_clear_cell(row, col)


func _on_tranquility_changed(amount: int) -> void:
	if amount > 0:
		for __ in _get_effect_count("drums"):
			deal_damage(1)
	tick_timer.wait_time = enemy.base_tick_rate + 0.1 * player.status_effects.get_effect("tranquility")


func _queue_effect(row: int, col: int) -> void:
	var effect: String = _get_effect(Vector2i(col, row))
	if effect == "none" or effect == "": return
	# Bomb explosion
	# TODO: Make work for any effect that breaks tiles
	if _get_effect(Vector2i(col, row)) == "bomb":
		for neighbor in NEIGHBORS:
			_queue_effect(neighbor.y, neighbor.x)
			
	effect_queue[Vector2i(col, row)] = effect


func _trigger_effects() -> void:
	for coords: Vector2i in effect_queue:
		var effect: StringName = effect_queue[coords]
		_trigger_on_clear_effect(effect, coords)
	effect_queue.clear()


func _trigger_on_clear_effect(effect: String, coords: Vector2i) -> void:
	match effect:
		"none":
			return
		"coin":
			if _get_effect_count("piggy bank") > 0:
				player.piggy_bank_stored += effect_counts["piggy bank"]
			else:
				player.gold += 1
		"permanent coin":
			if _get_effect_count("piggy bank") > 0:
				player.piggy_bank_stored += effect_counts["piggy bank"]
			else:
				player.gold += 1
		"sword":
			deal_damage(2)
		"shield":
			player.gain_block(3)
		"wooden shield":
			deal_damage(player.block / 5)
		"spiked shield":
			player.lose_health(3)
			player.gain_block(15)
		"bomb":
			explode(coords, 1)
			player.take_damage(3)
		"grenade":
			deal_damage(8)
			player.take_damage(2)
		"greatsword":
			deal_damage(4)
		"piggy bank":
			player.gold += round(player.piggy_bank_stored * 1.5)
			player.piggy_bank_stored = 0
		"cloud":
			deal_damage((HEIGHT - coords.y) * 0.5)
		"bubbles":
			var d: int
			for y in range(coords.y, -1, -1):
				if base_layer.get_cell_tile_data(Vector2i(coords.x, y)) != null:
					break
				d += 1
			deal_damage(d)
		"poison vial":
			enemy.status_effects.POISON += 1
		"acid vial":
			deal_damage(enemy.status_effects.get_effect("poison"))
		"skull":
			enemy.status_effects.mult_effect("poison", 2)
		"syringe":
			player.status_effects.gain_effect("strength", 3)
		"armor plate":
			player.lose_block(7)
		"sword and shield":
			player.gain_block(2)
			deal_damage(2)
		"shovel":
			if randf() > .9:
				# TODO: Gain random relic
				pass
		"weights":
			player.status_effects.gain_effect("strength", 1)
		"guitar":
			player.status_effects.gain_effect("tranquility", effect_counts["music note"])
		"flute":
			player.status_effects.gain_effect("tranquility", 2)
		"fishie":
			player.heal(2)
		


func _trigger_on_place_effect(effect: StringName, coords: Vector2i) -> void:
	match effect:
		"none":
			return
		"syringe":
			player.status_effects.gain_effect("strength", 3)
		"round shield":
			player.gain_block(2)
		"armor plate":
			player.gain_block(7)
		"bricks":
			player.gain_block(2)
		"house":
			for neighbor in NEIGHBORS:
				var neighbor_effect: StringName = _get_effect(coords + neighbor)
				if "BUILDING" not in _get_effect_types(coords + neighbor) or effect == "house": continue
				_trigger_on_clear_effect(neighbor_effect, coords + neighbor)
		"tower":
			deal_damage(type_counts["BUILDING"])
		"office":
			player.gold += max(1, type_counts["BUILDING"] / 3)


func _trigger_adjacent_place_effects(effect_placed: StringName, coords: Vector2i) -> void:
	for neighbor in NEIGHBORS:
		var effect: StringName = _get_effect(coords + neighbor)
		match effect:
			"landmine":
				if neighbor != Vector2i.UP:
					break
				_clear_cell(coords.y, coords.x)
				_queue_effect(coords.y, coords.x)
				_clear_cell(coords.y + 1, coords.x)
				player.take_damage(1)
	_trigger_effects()
	_erase_cleared_cells()
