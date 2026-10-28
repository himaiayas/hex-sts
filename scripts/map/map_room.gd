class_name MapRoom
extends RefCounted

## One hexagonal room on the map. Doors are direction indices into MapState.DIRS.

## Scene opened when the player builds a room of each type. Types can share a scene.
const SCENES := {
	Enum.RoomType.NORMAL_COMBAT: "res://scenes/combat.tscn",
	Enum.RoomType.ELITE_COMBAT: "res://scenes/combat.tscn",
	Enum.RoomType.BOSS_COMBAT: "res://scenes/combat.tscn",
	Enum.RoomType.CAMPFIRE: "res://scenes/rooms/campfire.tscn",
	Enum.RoomType.CARD_SHOP: "res://scenes/rooms/shop.tscn",
	Enum.RoomType.AUGMENT_SHOP: "res://scenes/rooms/shop.tscn",
	Enum.RoomType.TREASURE: "res://scenes/rooms/treasure.tscn",
	Enum.RoomType.EVENT: "res://scenes/rooms/event.tscn",
}

const NAMES := {
	Enum.RoomType.START: "Entrance",
	Enum.RoomType.NORMAL_COMBAT: "Combat",
	Enum.RoomType.ELITE_COMBAT: "Elite",
	Enum.RoomType.BOSS_COMBAT: "Boss",
	Enum.RoomType.CAMPFIRE: "Campfire",
	Enum.RoomType.CARD_SHOP: "Card Shop",
	Enum.RoomType.AUGMENT_SHOP: "Augment Shop",
	Enum.RoomType.TREASURE: "Treasure",
	Enum.RoomType.EVENT: "Event",
}

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
	return NAMES.get(type, "Room")


## Empty for rooms without a scene (the entrance).
func scene_path() -> String:
	return SCENES.get(type, "")


func is_combat() -> bool:
	return type in [Enum.RoomType.NORMAL_COMBAT, Enum.RoomType.ELITE_COMBAT, Enum.RoomType.BOSS_COMBAT]
