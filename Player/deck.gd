class_name Deck extends Resource
## Acts as a deck that can hold pieces
## Provies functions to make managing the deck simpler

const N_POPULATE: int = 20 # copies of full deck
@export var full_deck: Array[PieceData] = []: # full deck of pieces
	set(value):
		full_deck = value
		reset()
var deck: Array[PieceData] = [] # many copies of full deck to draw in game
var idx: int = 0 # index into deck


## Populates [member deck] with [param n] copies of your shuffled [member full_deck].
func repopulate(n: int = N_POPULATE) -> void:
	deck = deck.slice(idx, -1) # get rid of used pieces
	idx = 0
	var full_deck_cpy := full_deck.duplicate() # copy to shuffle
	for __ in n:
		full_deck_cpy.shuffle()
		deck.append_array(full_deck_cpy)


## Returns the next piece in the deck
func draw() -> PieceData:
	if idx + GameManager.player.preview_size >= len(deck) - 1:
		repopulate()
	var piece_data: PieceData = deck[idx]
	idx += 1
	return piece_data


## Gets the nth next piece in the deck
func peek(n: int = 0) -> PieceData:
	if idx + n > len(deck):
		repopulate()
	return deck[idx + n]


## Clears your deck
func clear() -> void:
	deck = []
	idx = 0


## Clears the current deck and populates a new one
func reset() -> void:
	clear()
	repopulate()


## Adds a piece to your full deck
func add_piece(piece_data: PieceData) -> void:
	# BUG if enemies add pieces mid combat they'll call this and
	#     cause the preview to mess up
	full_deck.append(piece_data)
	reset()
	

## Removes a piece from your full deck
func remove_piece(piece_data: PieceData) -> void:
	full_deck.erase(piece_data)
	reset()

## Sets the [EffectData] of all cells without an effect to none_data
func initialize_pieces() -> void:
	var none_data: EffectData = load("res://Piece/Effect/Effects/None/none_data.tres")
	EffectData.none = none_data
	for piece_data: PieceData in full_deck:
		piece_data.create_cells()
