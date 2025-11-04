class_name TetrisGame extends Node2D

const WIDTH: int = 10
const HEIGHT: int = 22
const WALLKICKS = preload("res://Tetris/wallkicks.gd").WALLKICKS
const WALLKICKS_I = preload("res://Tetris/wallkicks.gd").WALLKICKS_I
const NEIGHBORS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

# Lines cleared -> damage dealt
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

var deck: Deck = Deck.new()
var deck_idx: int = 0
var active_piece: Piece = null
var fall_speed: float = 1
var preview_size: int = 3
var pieces_placed: int = 0
var type_counts: Dictionary = {
	Effect.Type.MELEE: 0,
	Effect.Type.RANGED: 0,
	Effect.Type.ARROW: 0,
	Effect.Type.SHIELD: 0,
	Effect.Type.BUILDING: 0,
	Effect.Type.ECONOMY: 0,
	Effect.Type.SCIENCE: 0,
	Effect.Type.SUPPORT: 0,
	Effect.Type.ARMOR: 0,
	Effect.Type.EXPLOSIVE: 0,
	Effect.Type.MUSIC: 0,
	Effect.Type.MISC: 0,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.start_combat.connect(_on_start_combat)
	deck = player.deck


func _on_start_combat() -> void:
	enemy = GameManager.enemy
	tick_timer.wait_time = enemy.base_tick_rate
	spawn_piece()


func tick() -> void:
	_move_piece(active_piece, Vector2i.DOWN)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		print(get_cell(base_layer.local_to_map(base_layer.get_local_mouse_position())))
	
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()
		
	if event.is_action_pressed("right"):
		_move_piece(active_piece, Vector2i.RIGHT)
		
	elif event.is_action_pressed("left"):
		_move_piece(active_piece, Vector2i.LEFT)
	
	if event.is_action_pressed("soft_drop"):
		_move_piece(active_piece, Vector2i.DOWN)
		
	if Input.is_action_just_pressed("hard_drop"):
		while _move_piece(active_piece, Vector2i.DOWN): pass
		
	if Input.is_action_just_pressed("rotate"):
		rotate_piece(active_piece, 1)
	
	if Input.is_action_just_pressed("rotate_reversed"):
		rotate_piece(active_piece, -1)


func get_cell(coords: Vector2i) -> Cell:
	""" Returns the cell at the given coords"""
	return Cell.cell_coords.get(coords)


func set_cell(cell: Cell) -> void:
	""" Set cell without triggering effects/attacks """
	if cell == null: return
	# Set tilemap layers
	base_layer.set_cell(cell.get_coords(), 0, cell.base_atlas_coords)
	effect_layer.set_cell(cell.get_coords(), 1, cell.effect_atlas_coords)
	
	
func place_cell(cell: Cell) -> void:
	""" Place and trigger effects/attacks """
	set_cell(cell)
	cell.place()
	
	# Enemy Attacks
	var data: TileData = attack_layer.get_cell_tile_data(cell.coords)
	if data != null:
		var attack: EnemyAttack = data.get_custom_data("attack_resource")
		if attack != null:
			attack.trigger()
			attack_layer.erase_cell(cell.coords)


func erase_cell(cell: Cell) -> void:
	""" Remove cell without triggering effects """
	if cell == null: return
	base_layer.erase_cell(cell.get_coords())
	effect_layer.erase_cell(cell.get_coords())


func clear_cell(cell: Cell) -> void:
	""" Remove cell and trigger effects """
	if cell == null: return
	erase_cell(cell)
	cell.clear()


func set_cell_shadow(cell: Cell) -> void:
	""" Draws the shadow of a cell """
	base_ghost_layer.set_cell(cell.get_shadow_coords(), 0, cell.base_atlas_coords)
	if cell.effect != null:
		effect_ghost_layer.set_cell(cell.get_shadow_coords(), 0, cell.effect.atlas_coords)


## Erases the shadow of a cell
func erase_cell_shadow(cell: Cell) -> void:
	base_ghost_layer.erase_cell(cell.get_shadow_coords())
	effect_ghost_layer.erase_cell(cell.get_shadow_coords())


## Draws a piece without triggering effects
func draw_piece(piece: Piece = active_piece, shadow: bool = true) -> void:
	for cell: Cell in piece.cells:
		set_cell(cell)
	if shadow: draw_shadow(piece)


func draw_shadow(piece: Piece = active_piece) -> void:
	""" Draws a piece's shadow """
	var y: int = 1
	while not check_collision(piece, Vector2i.DOWN * y, 0, base_layer):
		y += 1
	y -= 1
	piece.shadow_offset = Vector2i(0, y)
	for cell in piece.cells:
		set_cell_shadow(cell)


func _remove_piece(piece: Piece = active_piece, remove_shadow: bool = true) -> void:
	""" Remove piece without triggering effects """
	for cell in piece.cells:
		erase_cell(cell)
	if remove_shadow:
		_remove_shadow(piece)


func _remove_shadow(piece: Piece = active_piece) -> void:
	""" Removes a piece's shadow """
	for cell in piece.cells:
		erase_cell_shadow(cell)


func _move_piece(piece: Piece, dir: Vector2i, collision_enabled: bool = true) -> bool:
	if collision_enabled and check_collision(piece, dir):
		if dir.y >= 1: place_piece(piece)
		return false
	_remove_piece(piece, false)
	piece.move(dir)
	draw_piece(piece)
	return true


func rotate_piece(piece: Piece = active_piece, rot: int = 1) -> void:
	# TODO: If needed you can rotate before collision check and rotate back, but less readable
	if rot == 0: return
	var kicks: Array = WALLKICKS if piece.data.shape != PieceData.Shape.I else WALLKICKS_I
	# add one to rotation since piece hasn't been rotated yet
	kicks = kicks[(piece.rotation + 1) % 4] # BUG: Might need to be +2 for cc rotation
	for vec: Vector2i in kicks:
		vec *= sign(rot)
		if not check_collision(piece, vec, rot):
			_remove_piece(piece)
			piece.rotate(rot)
			piece.move(vec)
			draw_piece(piece)
			return
	
	
func check_collision(piece: Piece, dir: Vector2i = Vector2i.ZERO, rot: int = 0, layer: TileMapLayer = base_layer) -> bool:
	_remove_piece(piece, false)
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
	
	_remove_shadow(piece)
	clear_lines()
	spawn_piece()
	pieces_placed += 1
	SignalBus.piece_placed.emit(pieces_placed)


func spawn_piece() -> void:
	# TODO BUG: Deal with small decks where there might not be enough pieces
	if deck.is_empty():
		_shuffle()

	var piece_data: PieceData = up_next.pop_front()
	up_next.append(deck.pop_front())
	discard.append(piece_data)
	var piece: Piece = piece_data.create_piece()
	piece.active = true
	# Coins
	var coin_chance := 0.1
	# TODO: Fix coins
	for cell in up_next[-1].cells:
		if cell.exhausted:
			cell.effect_atlas_coords = Vector2i.ZERO
		if cell.effect_atlas_coords == Vector2i(0, 1): # coin
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
	pass
	## Clear up next
	#for x in range(11, 15):
		#for y in range(2, 10):
			#erase_cell(get_cell(Vector2i(x, y)))
	#
	## Draw up next
	#for n in num_up_next:
		#up_next[n].coords = Vector2i(11, 5 * n + 2)
		#draw_piece(up_next[n], false)


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
	# TODO: make enemy take base damage
	var damage: int = base_damage
	for row: int in rows: # goes top down
		for col: int in WIDTH:
			var cell: Cell = get_cell(Vector2i(col, row))
			clear_cell(cell)
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
