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

# Tilemap Layers
@onready var background_layer: TileMapLayer = $Background
@onready var attack_layer: TileMapLayer = $Attack
@onready var base_layer: TileMapLayer = $Base
@onready var effect_layer: TileMapLayer = $Effect
@onready var base_ghost_layer: TileMapLayer = $BaseGhost
@onready var effect_ghost_layer: TileMapLayer = $EffectGhost

@onready var tick_timer: Timer = $TickTimer

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
var num_up_next: int = 2
var effect_queue: Dictionary[Vector2i, StringName]
var pieces_placed: int = 0


var effect_counts: Dictionary[StringName, int] = {}
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
	"INSTRUMENT": 0,
	"MISC": 0,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.start_combat.connect(_on_start_combat)
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
	if event.is_action_pressed("click"):
		print(get_cell(base_layer.local_to_map(base_layer.get_local_mouse_position())))
	
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
	deck = []
	for piece in full_deck:
		deck.append(piece.copy())
	deck.shuffle()
	discard.clear()


func get_cell(coords: Vector2i) -> Cell:
	return Cell.cell_coords.get(coords)


func set_cell(cell: Cell) -> void:
	if cell == null: return
	# Set tilemap layers
	base_layer.set_cell(cell.get_coords(), 0, cell.base_atlas_coords)
	effect_layer.set_cell(cell.get_coords(), 1, cell.effect_atlas_coords)
	
	# Trigger Effect
	var effect: Effect = cell.effect
	if effect != null:
		effect.on_place()
	
	# Enemy Attacks
	var data: TileData = attack_layer.get_cell_tile_data(cell.coords)
	if data != null:
		var attack: EnemyAttack = data.get_custom_data("attack_resource")
		if attack != null:
			attack.trigger()
			attack_layer.erase_cell(cell.coords)

	#if effect.name not in effect_counts:
		#effect_counts[effect.name] = 0
	#effect_counts[effect.name] += 1
	
	#for type: StringName in cell.effect.types:
		#if not effect_counts.has(type):
			#type_counts[cell.effect.types] = 0
		#effect_counts[cell.effect.name] += 1


func erase_cell(cell: Cell, trigger_effect: bool = true) -> void:
	if cell == null: return
	cell.clear(trigger_effect)
	_trigger_adjacent_clear_effects(cell.get_coords())
	base_layer.erase_cell(cell.get_coords())
	effect_layer.erase_cell(cell.get_coords())


func set_cell_shadow(cell: Cell) -> void:
	base_ghost_layer.set_cell(cell.get_shadow_coords(), 0, cell.base_atlas_coords)
	if cell.effect != null:
		effect_ghost_layer.set_cell(cell.get_shadow_coords(), 0, cell.effect.atlas_coords)


func erase_cell_shadow(cell: Cell) -> void:
	base_ghost_layer.erase_cell(cell.get_shadow_coords())
	effect_ghost_layer.erase_cell(cell.get_shadow_coords())


func _get_effect(coords: Vector2i) -> GDScript:
	var data: TileData = effect_layer.get_cell_tile_data(coords)
	if data == null: return null
	return data.get_custom_data("effect")
	
func _get_effect_types(coords: Vector2i) -> Array:
	var data: TileData = effect_layer.get_cell_tile_data(coords)
	if data == null: return []
	return data.get_custom_data("effect type")

func draw_piece(piece: Piece = active_piece, shadow: bool = true) -> void:
	for cell: Cell in piece.cells:
		set_cell(cell)
	if shadow: draw_shadow(piece)
	

func remove_piece(piece: Piece = active_piece, remove_shadow: bool = true) -> void:
	for cell in piece.cells:
		erase_cell(cell, false)
	if remove_shadow:
		remove_shadow(piece)


func draw_shadow(piece: Piece = active_piece) -> void:
	var y: int = 1
	while not check_collision(piece, Vector2i.DOWN * y, 0, base_layer):
		y += 1
	y -= 1
	piece.shadow_offset = Vector2i(0, y)
	for cell in piece.cells:
		set_cell_shadow(cell)


func remove_shadow(piece: Piece = active_piece) -> void:
	for cell in piece.cells:
		erase_cell_shadow(cell)


func move_piece(piece: Piece, dir: Vector2i, collision_enabled: bool = true) -> bool:
	if collision_enabled and check_collision(piece, dir):
		if dir.y >= 1: place_piece(piece)
		return false
	remove_piece(piece)
	piece.move(dir)
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
			piece.move(vec)
			draw_piece(piece)
			return
	
	
func check_collision(piece: Piece, dir: Vector2i = Vector2i.ZERO, rot: int = 0, layer: TileMapLayer = base_layer) -> bool:
	remove_piece(piece, false)
	piece.rotate(rot)
	
	var collided: bool = false
	for cell: Cell in piece.cells:
		if layer.get_cell_tile_data(cell.get_coords() + dir) != null:
			collided = true
			break
			
	piece.rotate(-rot)
	draw_piece(piece, false)
	return collided


func place_piece(piece: Piece) -> void:
	for cell: Cell in piece.cells:
		set_cell(cell)
	
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
	piece.active = true
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
		if cell.unique:
			cell.exhausted = true
	_draw_next()
	
	active_piece = piece
	piece.coords = Vector2i(4, 1)
	if check_collision(piece, Vector2i.ZERO, 0, base_layer):
		piece.move(Vector2i.UP)
		if check_collision(piece, Vector2i.ZERO, 0, base_layer):
			lose()
			return
	draw_piece(piece, true)


func _draw_next() -> void:
	# Clear up next
	for x in range(11, 15):
		for y in range(2, 10):
			erase_cell(get_cell(Vector2i(x, y)))
	
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
	var damage: int = base_damage
	for row: int in rows: # goes top down
		for col: int in WIDTH:
			var cell: Cell = get_cell(Vector2i(col, row))
			erase_cell(cell)
	for row: int in rows:
		lower_rows_above(row)


func lower_rows_above(start_row: int) -> void:
	var cpy := Cell.cell_coords.duplicate()
	for cell: Cell in cpy.values():
		#await get_tree().create_timer(.5).timeout
		if cell.coords.y < start_row:
			erase_cell(cell)
			cell.coords += Vector2i.DOWN
			set_cell(cell)
		
	#for row: int in range(start_row, 0, -1): # bottom up
		#for col: int in WIDTH:
			#var cell: Cell = get_cell(Vector2i(col, row - 1))
			#if cell == null:
				#erase_cell(get_cell(Vector2i(col, row)))
			#else:
				#cell.coords += Vector2i.DOWN
				#set_cell(cell)


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


func _trigger_adjacent_place_effects(coords: Vector2i) -> void:
	for neighbor in NEIGHBORS:
		var cell: Cell = get_cell(coords + neighbor)
		if cell == null: continue
		cell.effect.on_adjacent_cell_placed(-neighbor)


func _trigger_adjacent_clear_effects(coords: Vector2i) -> void:
	for neighbor in NEIGHBORS:
		var cell: Cell = get_cell(coords)
		if cell == null: continue
		cell.effect.on_adjacent_cell_cleared(-neighbor)
