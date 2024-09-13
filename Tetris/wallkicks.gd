extends Node


const WALLKICKS := [
	[Vector2i.ZERO, Vector2i(-1,0), Vector2i(-1,-1), Vector2i(0,2), Vector2i(-1,2)],
	[Vector2i.ZERO, Vector2i(1,0), Vector2i(1,1), Vector2i(0,-2), Vector2i(1,-2)],
	[Vector2i.ZERO, Vector2i(1,0), Vector2i(1,-1), Vector2i(0,2), Vector2i(1,2)],
	[Vector2i.ZERO, Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,2), Vector2i(1,2)]
]

const WALLKICKS_I := [
	[Vector2i.ZERO, Vector2i(-2,0), Vector2i(1,0), Vector2i(-2,1), Vector2i(1,-2)],
	[Vector2i.ZERO, Vector2i(-1,0), Vector2i(2,0), Vector2i(-1,-2), Vector2i(2,1)],
	[Vector2i.ZERO, Vector2i(2,0), Vector2i(-1,0), Vector2i(2,-1), Vector2i(-1,2)],
	[Vector2i.ZERO, Vector2i(1,0), Vector2i(-2,0), Vector2i(1,2), Vector2i(-2,-1)],
]
