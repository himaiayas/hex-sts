extends Control

## Fight any monster: every normal, elite and boss from the combat scene's lists, by floor.
## Click one to fight it with DECK_SIZE random cards; when the fight ends, won or lost, it comes back here.
## Run this scene with F6.

const SCENE_PATH := "res://scenes/tests/monster_test.tscn"
const CombatScene := preload("res://scripts/combat/combat_scene.gd")
const BUTTON_SIZE := Vector2(220, 56)
const DECK_SIZE := 10
const COLOR_BG := Color("#10121a")
const COLOR_HEADER := Color("#ffd45a")


func _ready() -> void:
	CombatScene.testing = null  # left over from the last fight picked here
	CombatScene.return_scene = ""
	BackToMenu.add_to.call_deferred(self)  # after the scene's own background and list

	var background := ColorRect.new()
	background.color = COLOR_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 48)
	add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 14)
	scroll.add_child(box)

	var title := Label.new()
	title.text = "Fight a monster"
	title.add_theme_font_size_override("font_size", 44)
	box.add_child(title)

	var floors := maxi(CombatScene.NORMALS.size(), RunState.FLOOR_BOSSES.size())
	for f in floors:
		box.add_child(_header("Floor %d" % (f + 1)))
		if f < CombatScene.NORMALS.size():
			box.add_child(_row("Normal", CombatScene.NORMALS[f], f, Enum.RoomType.NORMAL_COMBAT))
		if f < CombatScene.ELITES.size():
			box.add_child(_row("Elite", CombatScene.ELITES[f], f, Enum.RoomType.ELITE_COMBAT))
		if f < RunState.FLOOR_BOSSES.size():
			box.add_child(_row("Boss", [RunState.FLOOR_BOSSES[f]], f, Enum.RoomType.BOSS_COMBAT))


func _header(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 34)
	label.add_theme_color_override("font_color", COLOR_HEADER)
	return label


func _row(kind: String, monsters: Array, floor_index: int, room_type: Enum.RoomType) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var label := Label.new()
	label.text = kind
	label.custom_minimum_size.x = 120
	label.add_theme_font_size_override("font_size", 26)
	row.add_child(label)
	var buttons := HFlowContainer.new()
	buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_theme_constant_override("h_separation", 10)
	buttons.add_theme_constant_override("v_separation", 10)
	row.add_child(buttons)
	for monster: Script in monsters:
		var button := Button.new()
		button.text = monster.new().display_name
		button.custom_minimum_size = BUTTON_SIZE
		button.add_theme_font_size_override("font_size", 24)
		button.pressed.connect(_fight.bind(monster, floor_index, room_type))
		buttons.add_child(button)
	return row


## A fresh run on that floor, straight into the fight. Bosses use a real boss room
## (RunState.floor_boss, boss music and background); others go through CombatScene.testing.
func _fight(monster: Script, floor_index: int, room_type: Enum.RoomType) -> void:
	RunState.start_new_run()
	RunState.deck.assign(CardPool.random_cards(DECK_SIZE))  # different cards each fight
	RunState.dungeon_floor = floor_index + 1
	CombatScene.testing = null if room_type == Enum.RoomType.BOSS_COMBAT else monster
	CombatScene.return_scene = SCENE_PATH
	RunState.current_room = MapRoom.new(Vector2i(1, 0), room_type, [3])
	get_tree().change_scene_to_file(RunState.COMBAT_SCENE)
