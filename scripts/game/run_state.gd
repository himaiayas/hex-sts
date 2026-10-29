extends Node

## Data that lasts for the whole run (autoload "RunState").



var health:Dictionary[Vector2i, HealthTile] = {}
var gold := 0
var deck: Array[BaseCard] = []
var level :=0
var xp :=0
var dungeon_floor :=1

const MAP_SCENE := "res://scenes/map.tscn"

var map: MapState = null
var current_room: MapRoom = null

## Non-null only during a fight.
var combat: CombatState = null


func start_new_run() -> void:
	health = CombatUnit.make_hex_health([
		Vector2i(0, 0), 
		Vector2i(1, 0), 
		Vector2i(0, 1), 
		Vector2i(-1, 1), 
		Vector2i(-1, 0), 
		Vector2i(0, -1), 
		Vector2i(1, -1),
		
	])
	gold = 0
	deck = []
	level = 0
	xp = 0
	dungeon_floor = 1
	for i in 4:
		deck.append(Strike.new())
		deck.append(StatusStrike.new())
		deck.append(ShieldPlayer.new())
	for i in 2:
		deck.append(WomboCombo.new())
	map = MapState.new()
	map.start()
	current_room = null
	combat = null


## Opens the room's scene. Rooms without one (the entrance) do nothing.
func enter_room(room: MapRoom) -> void:
	if room.scene_path().is_empty():
		return
	current_room = room
	get_tree().change_scene_to_file(room.scene_path())


## Called by a room's scene when the player is done there.
func leave_room() -> void:
	current_room = null
	get_tree().change_scene_to_file(MAP_SCENE)


func start_combat() -> CombatState:
	combat = CombatState.new(self)
	return combat


func end_combat() -> void:
	if combat:
		combat.finish(self)
	combat = null
