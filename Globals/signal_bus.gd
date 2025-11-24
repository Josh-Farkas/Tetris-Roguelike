extends Node
## Autoloaded Signal Bus that controls all general purpose [Signal]s.
## This makes it much easier to connect to a signal without knowing the exact
## path to the emitting node. 
## This class should only be used to define signals.


#region General Signals
signal changed_scenes(from: Node, to: Node) ## Emitted when [GameManager] changes scene.
signal player_set(player: Player) ## Emitted when the [GameManager] sets [param player].
#endregion General Signals


#region Gameplay Signals
signal start_combat ## Emitted by [GameManager] when combat starts.
signal piece_placed ## Emitted when a piece is placed.
signal enemy_killed ## Emitted when an [Enemy] is killed.
#endregion Gameplay Signals
