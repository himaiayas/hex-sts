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
const BOSS_INTRO := preload("res://scenes/ui/boss_intro.tscn")

## Boss of each floor: FLOOR_BOSSES[0] is floor 1. Floors past the end reuse the last one.
static var FLOOR_BOSSES: Array = [Dragon, Dracula, Ramiel]

## Combat room background of each floor: [0] is floor 1 (medieval, halloween, sci-fi).
const FLOOR_COMBAT_BACKGROUNDS: Array[Texture2D] = [
	preload("res://assets/rooms/background/floor_1_medieval.jpg"),
	preload("res://assets/rooms/background/floor_2_halloween.jpg"),
	preload("res://assets/rooms/background/floor_3_sci_fi.jpg"),
]
## The boss room's. Unused alternatives are named *_alt_N.
const FLOOR_BOSS_BACKGROUNDS: Array[Texture2D] = [
	preload("res://assets/rooms/background/floor_1_medieval_boss.jpg"),
	preload("res://assets/rooms/background/floor_2_halloween_boss.jpg"),
	preload("res://assets/rooms/background/floor_3_sci_fi_boss.jpg"),
]

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
	# Radius-2 hexagon: 19 tiles, the sheet's starting health.
	var coords: Array[Vector2i] = []
	for q in range(-2, 3):
		for r in range(maxi(-2, -q - 2), mini(2, -q + 2) + 1):
			coords.append(Vector2i(q, r))
	health = CombatUnit.make_hex_health(coords)
	gold = 0
	deck = []
	artifacts = []
	level = 0
	xp = 0
	pending_level_ups = 0
	dungeon_floor = 1

	deck.append(CureAilment.new())
	deck.append(LuckyShield.new())
	deck.append(XSlash.new())
	deck.append(Enhance.new())
	#deck.append(ShoulderCharge.new())
	deck.append(Guard.new())
	deck.append(Burnout.new())
	deck.append(BurningStab.new())
	deck.append(Kindling.new())
	deck.append(OpenVein.new())
	# deck.append(Mend.new())
	# deck.append(BloodPrice.new())
	# deck.append(SpikedGuard.new())
	# deck.append(Lance.new())
	# deck.append(Sunder.new())
	# deck.append(Jab.new())
	# deck.append(Recall.new())
	# deck.append(Hone.new())
	# deck.append(DoubleTime.new())
	# deck.append(Foresight.new())
	# deck.append(Ward.new())
	# deck.append(Crack.new())
	# deck.append(Flurry.new())
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
## Leaving the boss room (after winning) goes to the next floor.
func leave_room() -> void:
	var beat_boss := current_room != null and current_room.type == Enum.RoomType.BOSS_COMBAT
	current_room = null
	if beat_boss:
		_next_floor()
	get_tree().change_scene_to_file(MAP_SCENE)


func combat_background() -> Texture2D:
	var boss := current_room != null and current_room.type == Enum.RoomType.BOSS_COMBAT
	var backgrounds := FLOOR_BOSS_BACKGROUNDS if boss else FLOOR_COMBAT_BACKGROUNDS
	return backgrounds[clampi(dungeon_floor, 1, backgrounds.size()) - 1]


## A new instance of this floor's boss.
func floor_boss() -> BaseEnemy:
	return FLOOR_BOSSES[mini(dungeon_floor, FLOOR_BOSSES.size()) - 1].new()


## Out of steps: fade to black, show the boss's name, then fight it where the player stands.
func start_boss() -> void:
	current_room = MapRoom.new(map.current, Enum.RoomType.BOSS_COMBAT, [])
	var intro := BOSS_INTRO.instantiate()
	get_tree().root.add_child(intro)
	intro.play(floor_boss().display_name, current_room.scene_path())


func _next_floor() -> void:
	dungeon_floor += 1
	map = MapState.new()
	map.start()


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
