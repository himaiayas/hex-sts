extends Node

## Sound effects (autoload "Sfx"). Call Sfx.play("event"): it plays one of that event's sounds
## at random, slightly re-pitched, so repeats don't sound identical. Every Button in the game
## clicks on its own (set meta "no_click_sfx" on one to silence it). Sounds play on the "SFX" bus
## when the project has one, else on Master. Sources and licences: CREDITS.md.

const DIR := "res://assets/sfx/"
## event -> sound files under DIR. Add or swap files here.
const SOUNDS := {
	# UI
	click = ["interface/click_001.ogg", "interface/click_002.ogg", "interface/click_003.ogg"],
	error = ["interface/error_004.ogg"],
	# cards
	card_hover = ["interface/tick_001.ogg", "interface/tick_002.ogg"],
	card_select = ["casino/card-slide-1.ogg", "casino/card-slide-2.ogg"],
	card_discard = ["casino/card-fan-1.ogg", "casino/card-fan-2.ogg"],
	shuffle = ["casino/card-fan-1.ogg", "casino/card-fan-2.ogg"],  # draw pile refilled from the discard pile
	exhaust = ["interface/minimize_005.ogg"],
	play_attack = ["rpg/knifeSlice.ogg", "rpg/knifeSlice2.ogg", "rpg/drawKnife1.ogg", "rpg/drawKnife2.ogg"],
	play_defense = ["rpg/metalLatch.ogg", "rpg/metalClick.ogg"],
	play_skill = ["casino/card-place-1.ogg", "casino/card-place-2.ogg", "casino/card-place-3.ogg", "casino/card-place-4.ogg"],
	play_power = ["interface/maximize_003.ogg"],
	# combat
	hit = ["impact/impactPunch_medium_000.ogg", "impact/impactPunch_medium_001.ogg", "impact/impactPunch_medium_002.ogg"],
	# a boss's big move (BaseEnemyAction.heavy_impact): both layers play together
	boss_boom = ["impact/impactBell_heavy_000.ogg", "impact/impactBell_heavy_001.ogg", "impact/impactBell_heavy_002.ogg"],
	boss_crash = ["impact/impactPlate_heavy_000.ogg", "impact/impactPlate_heavy_001.ogg", "impact/impactPlate_heavy_002.ogg"],
	hit_player = ["impact/impactPunch_heavy_000.ogg", "impact/impactPunch_heavy_001.ogg", "impact/impactPunch_heavy_002.ogg"],
	block = ["impact/impactMetal_medium_000.ogg", "impact/impactMetal_medium_001.ogg", "impact/impactMetal_medium_002.ogg"],
	shield = ["impact/impactPlate_light_000.ogg", "impact/impactPlate_light_001.ogg", "impact/impactPlate_light_002.ogg"],
	debuff = ["impact/impactGlass_light_000.ogg", "impact/impactGlass_light_001.ogg", "impact/impactGlass_light_002.ogg"],
	buff = ["interface/pluck_001.ogg", "interface/pluck_002.ogg"],
	heal = ["interface/glass_001.ogg", "interface/glass_002.ogg"],
	turn_start = ["interface/bong_001.ogg"],
	win = ["interface/confirmation_004.ogg"],
	lose = ["interface/error_008.ogg"],
	# map and rewards
	footstep = ["rpg/footstep00.ogg", "rpg/footstep01.ogg", "rpg/footstep02.ogg", "rpg/footstep03.ogg"],
	build = ["rpg/doorOpen_1.ogg", "rpg/doorOpen_2.ogg"],
	coins = ["rpg/handleCoins.ogg", "rpg/handleCoins2.ogg"],
	artifact = ["casino/card-slide-1.ogg", "casino/card-slide-2.ogg"],  # like picking a card
}
## Per-event volume in dB on top of VOLUME_DB (missing = 0). Quiet the frequent ones.
const EVENT_VOLUME := {card_hover = -10.0, shuffle = -4.0, footstep = -6.0, click = -4.0, boss_boom = 3.0, boss_crash = 2.0}
const VOLUME_DB := -4.0
const PITCH_JITTER := 0.06  # random pitch up or down by up to this fraction
const VOICES := 12  # sounds that can play at once

var _streams := {}  # event -> Array[AudioStream]
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for event: String in SOUNDS:
		var streams: Array[AudioStream] = []
		for file: String in SOUNDS[event]:
			streams.append(load(DIR + file))
		_streams[event] = streams
	var bus := "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"
	for i in VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = bus
		add_child(player)
		_players.append(player)
	get_tree().node_added.connect(_on_node_added)


## Plays a random sound of event (a SOUNDS key), volume_db louder or quieter than usual.
func play(event: String, volume_db := 0.0) -> void:
	var streams: Array = _streams.get(event, [])
	if streams.is_empty():
		push_warning("Sfx: no sound for %s" % event)
		return
	var player := _players[_next]  # round-robin: the oldest voice is cut if all are busy
	_next = (_next + 1) % _players.size()
	player.stream = streams.pick_random()
	player.volume_db = VOLUME_DB + EVENT_VOLUME.get(event, 0.0) + volume_db
	player.pitch_scale = randf_range(1.0 - PITCH_JITTER, 1.0 + PITCH_JITTER)
	player.play()


func _on_node_added(node: Node) -> void:
	if node is BaseButton and not node.has_meta("no_click_sfx"):
		node.pressed.connect(play.bind("click"))
