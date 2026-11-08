extends Node

## Data that lasts for the whole run (autoload "RunState").



var health:Dictionary[Vector2i, HealthTile] = {}
var gold := 0
var deck: Array[BaseCard] = []
var artifacts: Array[BaseArtifact] = []
var level :=0
var xp :=0
var dungeon_floor :=1
var fought: Dictionary = {}  # monster script -> times fought this run; repeats are less likely (combat_scene)
var normal_fights_on_floor := 0  # the first few of each floor are easy (combat_scene.EASY_FIGHTS)

const MAP_SCENE := "res://scenes/map.tscn"
const COMBAT_SCENE := "res://scenes/combat.tscn"
const MENU_SCENE := "res://scenes/mainmenu.tscn"
const BOSS_INTRO := preload("res://scenes/ui/boss_intro.tscn")

## Boss of each floor: FLOOR_BOSSES[0] is floor 1. Floors past the end reuse the last one.
static var FLOOR_BOSSES: Array = [Dragon, Dracula, Ramiel]

## Combat room backgrounds of each floor: [0] is floor 1 (medieval, halloween, sci-fi).
## Each room picks one at random.
const FLOOR_COMBAT_BACKGROUNDS: Array = [
	[preload("res://assets/rooms/background/floor_1_medieval.jpg")],
	[preload("res://assets/rooms/background/floor_2_halloween.jpg")],
	[
		preload("res://assets/rooms/background/floor_3_sci_fi_1.jpg"),
		preload("res://assets/rooms/background/floor_3_sci_fi_2.jpg"),
		preload("res://assets/rooms/background/floor_3_sci_fi_3.jpg"),
	],
]
## A background whose lights flicker now and then -> the image they flicker to.
const BACKGROUND_FLICKERS := {
	preload("res://assets/rooms/background/floor_2_halloween.jpg"): preload("res://assets/rooms/background/floor_2_halloween_flicker.jpg"),
}
## The boss room's.
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
var pending_tile_slots := 0  # health tiles to place from an artifact (Spare Hex), in the level-up modal
## Artifacts offered in this room and not taken yet (a boss reward, a shop shelf, a level-up while a
## chest is open). ArtifactPool skips them so two offers can't be the same artifact. Cleared on leaving.
var offered_artifacts: Array[BaseArtifact] = []

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
	pending_tile_slots = 0
	offered_artifacts = []
	dungeon_floor = 1
	fought = {}
	normal_fights_on_floor = 0

	deck.append(CureAilment.new())
	deck.append(LuckyShield.new())
	deck.append(XSlash.new())
	deck.append(SacredBlessing.new())
	#deck.append(ShoulderCharge.new())
	deck.append(Guard.new())
	deck.append(Taunt.new())
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
	offered_artifacts.clear()
	if beat_boss:
		_next_floor()
	get_tree().change_scene_to_file(MAP_SCENE)


func combat_background() -> Texture2D:
	if current_room != null and current_room.type == Enum.RoomType.BOSS_COMBAT:
		return FLOOR_BOSS_BACKGROUNDS[clampi(dungeon_floor, 1, FLOOR_BOSS_BACKGROUNDS.size()) - 1]
	return FLOOR_COMBAT_BACKGROUNDS[clampi(dungeon_floor, 1, FLOOR_COMBAT_BACKGROUNDS.size()) - 1].pick_random()


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
	normal_fights_on_floor = 0
	map = MapState.new()
	map.start()


func add_xp(amount: int) -> void:
	xp += amount
	while not is_max_level() and xp >= LEVEL_XP[level]:
		xp -= LEVEL_XP[level]
		level += 1
		pending_level_ups += 1


## Gives the player an artifact and runs its pick-up effect.
## Never owns two of the same artifact: a duplicate is ignored.
func add_artifact(artifact: BaseArtifact) -> void:
	offered_artifacts.erase(artifact)
	if has_artifact(artifact.get_script()):
		push_warning("Already own %s; not added again" % artifact.name)
		return
	artifacts.append(artifact)
	Sfx.play("artifact")
	artifact.on_pickup()


func has_artifact(script: Script) -> bool:
	return artifacts.any(func(a: BaseArtifact) -> bool: return a.get_script() == script)


## A Merchant or Blacksmith price, after Trading Sigil.
func shop_price(base: int) -> int:
	return ceili(base * TradingSigil.PRICE_FACTOR) if has_artifact(TradingSigil) else base



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
