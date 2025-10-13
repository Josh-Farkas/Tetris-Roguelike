extends Node

const CELL_SIZE: int = 16

const TILE_COORDS: Dictionary = {
	"GRAY": Vector2i(4, 0),
	"BLACK": Vector2i(4, 1),
	"GREEN": Vector2i(0, 0),
	"PURPLE": Vector2i(1, 0),
	"BLUE": Vector2i(2, 0),
	"ORANGE": Vector2i(0, 1),
	"LIGHT_BLUE": Vector2i(1, 1),
	"RED": Vector2i(2, 1)
}

const EFFECT_COORDS: Dictionary = {
	"NONE": Vector2i(0, 0),
	"SHIELD": Vector2i(1, 0),
	"SWORD": Vector2i(2, 0),
	"DAGGER": Vector2i(3, 0),
	"BOMB": Vector2i(4, 0),
	"COIN": Vector2i(0, 1),
}


const RARITY_COLORS: Dictionary = {
	"common": "#ffffff",
	"uncommon": "#008000",
	"rare": "de0a26"
}
