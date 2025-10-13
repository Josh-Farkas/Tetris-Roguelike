extends Node

# General Signals
signal changed_scenes(from: Node, to: Node)

# Tetris Signals
signal start_combat
signal piece_placed(amount_placed: int)
signal enemy_killed
