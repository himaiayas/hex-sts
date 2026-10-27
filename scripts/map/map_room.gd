class_name MapRoom
extends RefCounted

## One hexagonal room on the map. Doors are direction indices into MapState.DIRS.

enum RoomType {
	START,
	COMBAT,
}

var coord: Vector2i
var type: RoomType
var doors: Array[int] = []


# _type is a RoomType value as Godot rejects the class enum in _init from outside).
func _init(_coord: Vector2i, _type: int, _doors: Array[int]) -> void:
	coord = _coord
	type = _type as RoomType
	doors = _doors


func has_door(dir: int) -> bool:
	return dir in doors


func display_name() -> String:
	match type:
		RoomType.START:
			return "Entrance"
		RoomType.COMBAT:
			return "Combat"
	return "Room"
