class_name MapRoom
extends RefCounted

## One hexagonal room on the map. Doors are direction indices into MapState.DIRS.

## Scene opened when the player builds a room of each type. Types can share a scene.
const SCENES := {
	Enum.RoomType.NORMAL_COMBAT: "res://scenes/combat.tscn",
	Enum.RoomType.ELITE_COMBAT: "res://scenes/combat.tscn",
	Enum.RoomType.BOSS_COMBAT: "res://scenes/combat.tscn",
	Enum.RoomType.CAMPFIRE: "res://scenes/rooms/campfire.tscn",
	Enum.RoomType.MERCHANT: "res://scenes/rooms/merchant.tscn",
	Enum.RoomType.BLACKSMITH: "res://scenes/rooms/blacksmith.tscn",
	Enum.RoomType.TREASURE: "res://scenes/rooms/treasure.tscn",
	Enum.RoomType.EVENT: "res://scenes/rooms/event.tscn",
}

const NAMES := {
	Enum.RoomType.START: "Entrance",
	Enum.RoomType.NORMAL_COMBAT: "Combat",
	Enum.RoomType.ELITE_COMBAT: "Elite",
	Enum.RoomType.BOSS_COMBAT: "Boss",
	Enum.RoomType.CAMPFIRE: "Campfire",
	Enum.RoomType.MERCHANT: "Merchant",
	Enum.RoomType.BLACKSMITH: "Blacksmith",
	Enum.RoomType.TREASURE: "Treasure",
	Enum.RoomType.EVENT: "Event",
	Enum.RoomType.INTERSECTION: "Intersection",
}

var coord: Vector2i
var type: Enum.RoomType
var doors: Array[int] = []
## A Merchant's or Blacksmith's offers and which were sold, so coming back shows the same items.
## Filled by the room's scene on the first visit; saved with the run.
var stock: Dictionary = {}
var number := 0  # rooms built on this floor before it, plus 1: shown as "Room N" (0 = entrance)


func _init(_coord: Vector2i, _type: Enum.RoomType, _doors: Array[int]) -> void:
	coord = _coord
	type = _type
	doors = _doors


func has_door(dir: int) -> bool:
	return dir in doors


func display_name() -> String:
	return NAMES.get(type, "Room")


## Empty for rooms without a scene (the entrance).
func scene_path() -> String:
	return SCENES.get(type, "")


## Shops can be walked back into, with the same stock (stock).
func can_reenter() -> bool:
	return type in [Enum.RoomType.MERCHANT, Enum.RoomType.BLACKSMITH]


func is_combat() -> bool:
	return type in [Enum.RoomType.NORMAL_COMBAT, Enum.RoomType.ELITE_COMBAT, Enum.RoomType.BOSS_COMBAT]
