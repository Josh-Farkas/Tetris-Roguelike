class_name TetrisGame extends Node2D

const WIDTH: int = 10
const HEIGHT: int = 22
const WALLKICKS = preload("res://Tetris/wallkicks.gd").WALLKICKS
const WALLKICKS_I = preload("res://Tetris/wallkicks.gd").WALLKICKS_I

## Lines cleared: damage dealt
const DAMAGE_AMTS: Dictionary[int, int] = {
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

var active_piece: Piece = null
var pieces_placed: int = 0
var type_counts: Dictionary = { ## Count of each type of [Effect] placed
	EffectData.Type.MELEE: 0,
	EffectData.Type.RANGED: 0,
	EffectData.Type.ARROW: 0,
	EffectData.Type.SHIELD: 0,
	EffectData.Type.BUILDING: 0,
	EffectData.Type.ECONOMY: 0,
	EffectData.Type.SCIENCE: 0,
	EffectData.Type.SUPPORT: 0,
	EffectData.Type.ARMOR: 0,
	EffectData.Type.EXPLOSIVE: 0,
	EffectData.Type.MUSIC: 0,
	EffectData.Type.MISC: 0,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.start_combat.connect(_on_start_combat)


## Runs at the start of combat, initializes values
func _on_start_combat() -> void:
	enemy = GameManager.enemy
	tick_timer.wait_time = enemy.base_tick_rate
	spawn_piece()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var cell := get_cell(base_layer.local_to_map(base_layer.get_local_mouse_position()))
		if cell == null:
			print("NULL")
		else:
			print(cell.coords)
	
	if Constants.DEBUG and event.is_action_pressed("debug_action"):
		_lower_rows_above(20)
	
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


## Core game clock, causes pieces to fall
func tick() -> void:
	_move_piece(active_piece, Vector2i.DOWN)

#region Draw Functions

## Returns the cell at [param coords]
func get_cell(coords: Vector2i) -> Cell:
	return Cell.get_cell_at(coords)


## Set cell without triggering its [Effect] or [EnemyAttack].[br]
## Used while cells are falling or for display purposes
func set_cell(cell: Cell) -> void:
	if cell == null: return
	base_layer.set_cell(cell.coords, 0, cell.data.atlas_coords)	
	#effect_layer.set_cell(cell.get_coords(), 1, cell.effect.data.atlas_coords)


## Removes [param cell] without triggering its [Effect].
func erase_cell(cell: Cell) -> void:
	if cell == null: return
	base_layer.erase_cell(cell.get_coords())
	effect_layer.erase_cell(cell.get_coords())


## Draws the shadow of [param cell].
func set_cell_shadow(cell: Cell) -> void:
	base_ghost_layer.set_cell(cell.get_shadow_coords(), 0, cell.data.atlas_coords)
	effect_ghost_layer.set_cell(cell.get_shadow_coords(), 0, cell.effect.data.atlas_coords)


## Erases the shadow of [param cell]
func _erase_cell_shadow(cell: Cell) -> void:
	base_ghost_layer.erase_cell(cell.get_shadow_coords())
	effect_ghost_layer.erase_cell(cell.get_shadow_coords())


## Draws [param piece] without triggering effects.
## Also draws the shadow if [param draw_shadow] is [code]true[/code]
func _draw_piece(piece: Piece = active_piece, draw_shadow: bool = true) -> void:
	for cell: Cell in piece.cells:
		set_cell(cell)
	if draw_shadow: _draw_shadow(piece)


## Draws the shadow of [param piece]
func _draw_shadow(piece: Piece = active_piece) -> void:
	var y: int = 1
	while not check_collision(piece, Vector2i.DOWN * y, 0, base_layer):
		y += 1
		if y > 100:
			printerr("Failed Shadow Draw, No Floor")
			return
	y -= 1
	piece.shadow_offset = Vector2i(0, y)
	for cell in piece.cells:
		set_cell_shadow(cell)

## Remove [param piece] without triggering effects. 
## Also removes the shadow if [param remove_shadow] is [code]true[/code].
func _remove_piece(piece: Piece = active_piece, remove_shadow: bool = true) -> void:
	for cell: Cell in piece.cells:
		erase_cell(cell)
	if remove_shadow:
		_remove_shadow(piece)


## Removes [param piece]'s shadow
func _remove_shadow(piece: Piece = active_piece) -> void:
	for cell in piece.cells:
		_erase_cell_shadow(cell)


## Draws the [Piece]s upcoming in the preview
func _draw_preview() -> void:
	const START_Y: int = 2
	# Clear preview
	for x in range(11, 15):
		for y in range(START_Y, 15):
			erase_cell(get_cell(Vector2i(x, y)))
			base_layer.erase_cell(Vector2i(x, y))
			effect_layer.erase_cell(Vector2i(x, y))
			
	
	# Draw preview
	for n: int in player.preview_size:
		var piece: Piece = player.deck.peek(n).create_piece()
		piece.coords = Vector2i(11, 5 * n + START_Y)
		_draw_piece(piece, false)

#endregion Draw Functions

#region Game Logic

## Moves [param piece] in direction [param dir]. 
## [br]If [param collision_enabled] is [code]true[/code] it will check for collisions, 
## and return [code]false[/code] and place the piece if it collides
func _move_piece(piece: Piece, dir: Vector2i, collision_enabled: bool = true) -> bool:
	if collision_enabled and check_collision(piece, dir):
		if dir.y >= 1: place_piece(piece)
		return false
	_remove_piece(piece, true)
	piece.move(dir)
	_draw_piece(piece)
	return true


## Rotates a piece [param rot] times, negative means reversed rotation
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
			_draw_piece(piece)
			return
	

## Checks if [param piece] will collide with anything on [param layer] when moved in direction [param dir] and rotated by [param rot].
## [br][br]Returns [code]true[/code] if collided, otherwise [code]false[/code].
func check_collision(piece: Piece, dir: Vector2i = Vector2i.ZERO, rot: int = 0, layer: TileMapLayer = base_layer) -> bool:
	_remove_piece(piece, false)
	piece.rotate(rot)
	
	var collided: bool = false
	for cell: Cell in piece.cells:
		if layer.get_cell_tile_data(cell.get_coords() + dir) != null:
			collided = true
			break
			
	piece.rotate(-rot)
	_draw_piece(piece, false)
	return collided
	


func place_piece(piece: Piece) -> void:
	for cell: Cell in piece.cells:
		place_cell(cell)
	
	_remove_shadow(piece)
	_clear_full_lines()
	spawn_piece()
	pieces_placed += 1
	SignalBus.piece_placed.emit(pieces_placed)


## Place [param cell] and trigger its [Effect] and any [EnemyAttack] on that tile.
func place_cell(cell: Cell) -> void:
	set_cell(cell)
	
	cell.place()
	
	# Enemy Attacks
	var data: TileData = attack_layer.get_cell_tile_data(cell.coords)
	if data != null:
		var attack: EnemyAttack = data.get_custom_data("attack_resource")
		if attack != null:
			attack.trigger()
			attack_layer.erase_cell(cell.coords)


## Removes [param cell] and triggers its [Effect].
func clear_cell(cell: Cell) -> void:
	if cell == null: return
	erase_cell(cell)
	cell.clear()


## Spawns the next [Piece] in the [member deck].
func spawn_piece() -> void:
	var piece: Piece = player.deck.draw().create_piece()
	for cell: Cell in piece.cells:
		cell.active = true
	_draw_preview()
	active_piece = piece
	piece.coords = Vector2i(4, 1)
	if check_collision(piece, Vector2i.ZERO, 0, base_layer):
		piece.move(Vector2i.UP)
		if check_collision(piece, Vector2i.ZERO, 0, base_layer):
			lose()
			return
	_draw_piece(piece, true)
	for cell: Cell in piece.cells:
		add_child(cell)


## Returns [code]true[/code] if [param row] is a full line, otherwise [code]false[/code].
func check_line(row: int) -> bool:
	for col in WIDTH:
		if base_layer.get_cell_tile_data(Vector2i(col, row)) == null:
			return false
	return true

## Clears the given [param row].
func _clear_line(row: int) -> void:
	for col: int in WIDTH:
		var cell: Cell = get_cell(Vector2i(col, row))
		clear_cell(cell)

## Clears all full lines.
func _clear_full_lines() -> void:
	var rows := []
	for row in HEIGHT:
		if check_line(row):
			rows.append(row)
	if rows.is_empty(): return
	print("Clearing Lines...")
	
	var num_cleared := len(rows)
	var damage: int = DAMAGE_AMTS[num_cleared]
	# goes top down so clearing one won't move it below 
	# another cleared line. 0 -> 22
	for row: int in rows:
		_clear_line(row)
	for row: int in rows:
		_lower_rows_above(row)
	deal_damage(damage)


## Lowers all [Cell]s in the rows above [param start_row].
func _lower_rows_above(start_row: int) -> void:
	var moved: Array[Cell] = []
	for cell: Cell in Cell.cells:
		if cell.get_parent() == null or not cell.active: continue
		if cell.get_coords().y < start_row: # less than is up
			erase_cell(cell)
			cell.move(Vector2i.DOWN)
			moved.append(cell)
	for cell: Cell in moved:
		set_cell(cell)


## Deals [param damage] to the [member enemy].
func deal_damage(damage: float) -> void:
	enemy.take_damage(damage + player.status_effects.get_status_effect("strength"))
	if damage >= 3:
		GameManager.camera.screenshake(5 * min(damage, 8), .5)

## Loses the game
func lose() -> void:
	print("YOU LOST")
	return
	
#endregion Game Logic
