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

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	NONE
}

const RARITY_COLORS: Dictionary = {
	Rarity.COMMON: "#ffffff",
	Rarity.UNCOMMON: "#008000",
	Rarity.RARE: "de0a26",
	Rarity.NONE: "#555555"
}

# ========== File Paths ==========
const PIECE_TILESET_PATH := "res://Piece/piece_tileset.tres"
