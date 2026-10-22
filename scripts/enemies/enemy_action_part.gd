class_name EnemyActionPart
extends RefCounted

## One piece of an enemy action: a tile pattern aimed at one grid.
## An action can have several parts, e.g. attack the player AND shield itself.

enum Side {
	PLAYER, # the player's health grid
	SELF,   # the enemy's own health grid
}

var side: Side
var tiles: Array[BaseActionTile]
var cell: Vector2i # chosen in plan(), used by execute() and shown as the intent


## _side is a Side value (typed as int: Godot rejects the class's own enum in _init from outside).
func _init(_side: int, _tiles: Array[BaseActionTile]) -> void:
	side = _side
	tiles = _tiles
