extends Node
## Autoloaded constant values to be used throughout the game.

#region Debug
const DEBUG: bool = true
#endregion Debug

#region Misc
## Size of one cell.
const CELL_SIZE: int = 16

## Map from colors to [TileSet] atlas coords. 
## Only used for manual setting of colors.
const TILE_COORDS: Dictionary[String, Vector2i] = {
	"GRAY": Vector2i(4, 0),
	"BLACK": Vector2i(4, 1),
	"GREEN": Vector2i(0, 0),
	"PURPLE": Vector2i(1, 0),
	"BLUE": Vector2i(2, 0),
	"ORANGE": Vector2i(0, 1),
	"LIGHT_BLUE": Vector2i(1, 1),
	"RED": Vector2i(2, 1)
}

## Rarity enum. Handles rarity for things in the [Shop], such as [Effect]s or [Piece] shapes.
enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	NONE
}

# TODO: Maybe move to shop_data for @export with color picker?
## The hex colors that different [Rarity] effects will display as in text.
const RARITY_COLORS: Dictionary[Rarity, String] = {
	Rarity.COMMON: "#ffffff",
	Rarity.UNCOMMON: "#008000",
	Rarity.RARE: "de0a26",
	Rarity.NONE: "#555555"
}

## Map from [EffectData.Type] to [StringName] of a [Color].
const TYPE_COLORS: Dictionary[EffectData.Type, StringName] = {
	EffectData.Type.RANGED: "Green",
	EffectData.Type.ARROW: "Darkgreen",
	EffectData.Type.MELEE: "Darkred",
	EffectData.Type.SHIELD: "Mediumturquoise",
	EffectData.Type.SUPPORT: "Peachpuff",
	EffectData.Type.BUILDING: "Sienna",
	EffectData.Type.ECONOMY: "Goldenrod",
	EffectData.Type.SCIENCE: "Darkviolet",
	EffectData.Type.ARMOR: "Dimgray",
	EffectData.Type.EXPLOSIVE: "Red",
	EffectData.Type.MUSIC: "Aquamarine",
	EffectData.Type.MISC: "White",
}

## [Array] of [member Vector2i.UP], [member Vector2i.DOWN], [member Vector2i.LEFT], [member Vector2i.RIGHT].
const NEIGHBORS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
#endregion Misc


#region File Paths
## Path to the [TileSet] used by pieces.
const PIECE_TILESET_PATH := "res://Piece/piece_tileset.tres"
## Path to the folder of all [EffectData] types.
const EFFECTS_FOLDER_PATH := "res://Piece/Effect/Effects/"
#endregion File Paths


#region Tunable Gameplay Settings
## Minimum damage required to cause screenshake.
const SCREENSHAKE_MIN_DAMAGE: int = 3
## Max damage that screenshake will scale with, caps at this value.
const SCREENSHAKE_MAX_DAMAGE: int = 8

## Maps lines cleared to damage dealt
const LINE_CLEAR_DAMAGE_AMOUNTS: Dictionary[int, int] = {
	1: 1,
	2: 3,
	3: 6,
	4: 10
}
#endregion Tunable Settings
