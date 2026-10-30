class_name EnemyActionPart
extends RefCounted

## One piece of an enemy action: a tile pattern aimed at one grid.
## An action can have several parts, e.g. attack the player AND shield itself.

var side: Enum.Side
var tiles: Array[BaseActionTile]
var cell: Vector2i # chosen in plan(), used by execute() and shown as the intent


func _init(_side: Enum.Side, _tiles: Array[BaseActionTile]) -> void:
	side = _side
	tiles = _tiles
