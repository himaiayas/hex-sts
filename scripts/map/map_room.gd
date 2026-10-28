class_name MapRoom
extends RefCounted

## One hexagonal room on the map. Doors are direction indices into MapState.DIRS.

var coord: Vector2i
var type: Enum.RoomType
var doors: Array[int] = []


func _init(_coord: Vector2i, _type: Enum.RoomType, _doors: Array[int]) -> void:
	coord = _coord
	type = _type
	doors = _doors


func has_door(dir: int) -> bool:
	return dir in doors


func display_name() -> String:
	match type:
		Enum.RoomType.START:
			return "Entrance"
		Enum.RoomType.COMBAT:
			return "Combat"
	return "Room"
