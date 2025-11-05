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

#region File Paths
const PIECE_TILESET_PATH := "res://Piece/piece_tileset.tres"
const EFFECTS_FOLDER_PATH := "res://Piece/Effect/Effects/"
#endregion


#region Tunable Settings
const SCREENSHAKE_MIN_DAMAGE: int = 3 ## Minimum damage dealt to cause screenshake
const SCREENSHAKE_MAX_DAMAGE: int = 8 ## Max damage that screenshake will scale with, any more and the screenshake will be the same
#endregion
