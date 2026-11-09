extends Node

## Background music (autoload "Music"). Whenever the scene changes it picks a track for it and
## crossfades: the boss track in the boss room, the combat track in other fights, and the
## exploration track everywhere else (menu, map, campfire, merchant...). A track already playing
## carries on across scenes instead of restarting. Sources and licences: CREDITS.md.

const TRACKS := {
	exploration = preload("res://assets/music/exploration_whispers_in_the_fog.ogg"),
	combat = preload("res://assets/music/combat_cynic_battle_loop.ogg"),
	boss = preload("res://assets/music/boss_epic_boss_battle.wav"),
}
const VOLUME_DB := -8.0  # all tracks
const SILENT_DB := -60.0
const FADE_TIME := 1.2  # seconds of crossfade
const BUS := "Music"  # made at start if the project has none; the Options slider sets its volume

## 0 to 1, set from Options; saved by AudioSettings.
var volume := 0.8:
	set(value):
		volume = clampf(value, 0.0, 1.0)
		AudioSettings.apply(BUS, volume)
		AudioSettings.save_level("music", volume)

var _players: Array[AudioStreamPlayer] = []
var _active := 0  # index into _players of the one fading in / playing
var _track := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keeps playing while the game is paused
	AudioSettings.ensure_bus(BUS)
	volume = AudioSettings.load_level("music", volume)
	for i in 2:
		var player := AudioStreamPlayer.new()
		player.bus = BUS
		player.volume_db = SILENT_DB
		add_child(player)
		_players.append(player)
	get_tree().scene_changed.connect(_on_scene_changed)
	_on_scene_changed.call_deferred()  # the first scene loads without a scene_changed


func _on_scene_changed() -> void:
	var track := _track_for_scene()
	if not track.is_empty():
		play(track)


## The track for the current scene, or "" to keep what's playing.
func _track_for_scene() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	if scene.scene_file_path == RunState.COMBAT_SCENE:
		var room := RunState.current_room
		return "boss" if room and room.type == Enum.RoomType.BOSS_COMBAT else "combat"
	return "exploration"


## Crossfades to track (a TRACKS key). Does nothing if it's already playing.
func play(track: String) -> void:
	if track == _track:
		return
	_track = track
	var old := _players[_active]
	_active = 1 - _active
	var new := _players[_active]
	new.stream = TRACKS[track]
	new.volume_db = SILENT_DB
	new.play()
	var tween := create_tween().set_parallel()
	tween.tween_property(new, "volume_db", VOLUME_DB, FADE_TIME)
	if old.playing:
		tween.tween_property(old, "volume_db", SILENT_DB, FADE_TIME)
		tween.chain().tween_callback(old.stop)

