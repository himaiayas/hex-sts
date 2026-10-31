extends Node

## Data that lasts for the whole run (autoload "RunState").



var health:Dictionary[Vector2i, HealthTile] = {}
var gold := 0
var deck: Array[BaseCard] = []
var artifacts: Array[BaseArtifact] = []
var level :=0
var xp :=0
var dungeon_floor :=1

const MAP_SCENE := "res://scenes/map.tscn"
const COMBAT_SCENE := "res://scenes/combat.tscn"
const MENU_SCENE := "res://scenes/mainmenu.tscn"

## EXP needed for each level-up: LEVEL_XP[0] takes level 0 to 1, ... LEVEL_XP[8] takes 8 to 9 (max).
## xp is the progress toward the next level; it resets (keeping the leftover) on level-up.
const LEVEL_XP: Array[int] = [10, 20, 30, 45, 60, 80, 100, 125, 150]
const LEVEL_UP_TILES := 3

## Level-ups not yet claimed in the level-up modal.
var pending_level_ups := 0

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
	artifacts = []
	level = 0
	xp = 0
	pending_level_ups = 0
	dungeon_floor = 1
	for i in 4:
		deck.append(Strike.new())
		deck.append(StatusStrike.new())
		deck.append(ShieldPlayer.new())
	for i in 2:
		deck.append(WomboCombo.new())
	# One of each #9 example card, for testing.
	deck.append(Thrust.new())
	deck.append(DivineMercy.new())
	deck.append(RapidFire.new())
	deck.append(ArrowRain.new())
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


func add_xp(amount: int) -> void:
	xp += amount
	while not is_max_level() and xp >= LEVEL_XP[level]:
		xp -= LEVEL_XP[level]
		level += 1
		pending_level_ups += 1


func is_max_level() -> bool:
	return level >= LEVEL_XP.size()


## EXP needed to reach the next level; 0 at max level.
func xp_to_next() -> int:
	return 0 if is_max_level() else LEVEL_XP[level]


func start_combat() -> CombatState:
	combat = CombatState.new(self)
	return combat


func end_combat() -> void:
	if combat:
		combat.finish(self)
	combat = null
