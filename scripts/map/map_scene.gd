extends Control

const DESIGN_SIZE := Vector2(1920, 1080)
const COLOR_BG := Color("#07080b")
const HINT_TIME := 2.0

var map: MapState  # RunState.map, so it survives visiting a room's scene
var _busy := false  # walking, having popup modal or in a room.

@onready var _map_view: MapView = %MapView
@onready var _top_bar: TopBar = %TopBar
@onready var _steps_label: Label = %StepsLabel
@onready var _hint_label: Label = %HintLabel
@onready var _draft_panel: Control = %DraftPanel
@onready var _draft_options: HBoxContainer = %DraftOptions
@onready var _room_title: Label = %RoomTitle
@onready var _game_over_panel: Control = %GameOverPanel


func _ready() -> void:
	RenderingServer.set_default_clear_color(COLOR_BG)
	get_viewport().size_changed.connect(_fit_to_window)
	_fit_to_window()
	if RunState.map == null:
		RunState.start_new_run()
	_start()
	_check_out_of_steps()  # coming back from a room may have used the last steps


## The draft's "View map" button and the map's "Back to rooms" button (_build_map_peek).
var _view_map_button: Button
var _back_to_rooms_button: Button


func _start() -> void:
	_build_map_peek()
	map = RunState.map
	_map_view.setup(map)
	_draft_panel.hide()
	_game_over_panel.hide()
	_hint_label.text = ""
	_busy = false
	_refresh()
	_top_bar.refresh()


func _fit_to_window() -> void:
	var window := get_viewport_rect().size
	var s := minf(window.x / DESIGN_SIZE.x, window.y / DESIGN_SIZE.y)
	scale = Vector2(s, s)
	position = (window - DESIGN_SIZE * s) / 2


func _refresh() -> void:
	_steps_label.text = "%d / %d" % [map.steps, MapState.START_STEPS]


func _on_map_view_cell_clicked(cell: Vector2i) -> void:
	if _busy:
		return
	if cell == map.current and map.rooms[cell].can_reenter():  # standing on a shop: go back in
		_busy = true
		RunState.enter_room(map.rooms[cell])
		return
	var plan := map.plan_to(cell)
	if plan.is_empty():
		return
	if plan.cost > map.steps:
		_hint("Not enough steps.")
		return

	_busy = true
	var path: Array[Vector2i] = plan.path
	map.walk(path)
	_refresh()
	await _map_view.animate_path(path)
	if plan.build:
		_open_draft(plan.target, plan.door)
	elif map.rooms[plan.target].can_reenter():  # walked back to a shop: it opens with the same stock
		RunState.enter_room(map.rooms[plan.target])
	else:
		_busy = false
		_check_out_of_steps()


func _open_draft(cell: Vector2i, door: int) -> void:
	for child in _draft_options.get_children():
		child.queue_free()
	for room in map.draft_options(cell, door):
		var option := RoomOptionView.new()
		option.setup(room, door)
		option.chosen.connect(_on_room_chosen)
		_draft_options.add_child(option)
	_map_view.drafting_cell = cell
	_back_to_rooms_button.hide()
	_draft_panel.show()


## A way to look at the whole map while choosing a room: View map hides the draft (the spot being
## built is outlined; map clicks stay off, as _busy is set), Back to rooms brings it back.
func _build_map_peek() -> void:
	if _view_map_button:
		return
	_view_map_button = Button.new()
	_view_map_button.text = "View map"
	_view_map_button.custom_minimum_size = Vector2(240, 56)
	_view_map_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_view_map_button.add_theme_font_size_override("font_size", 26)
	_view_map_button.pressed.connect(_peek_map)
	_draft_options.get_parent().add_child(_view_map_button)
	_back_to_rooms_button = Button.new()
	_back_to_rooms_button.text = "Back to rooms"
	_back_to_rooms_button.custom_minimum_size = Vector2(280, 64)
	_back_to_rooms_button.add_theme_font_size_override("font_size", 28)
	_back_to_rooms_button.pressed.connect(_unpeek_map)
	add_child(_back_to_rooms_button)
	_back_to_rooms_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_back_to_rooms_button.offset_left = -140.0
	_back_to_rooms_button.offset_right = 140.0
	_back_to_rooms_button.offset_top = -110.0
	_back_to_rooms_button.offset_bottom = -46.0
	_back_to_rooms_button.hide()


func _peek_map() -> void:
	_draft_panel.hide()
	_back_to_rooms_button.show()


func _unpeek_map() -> void:
	_back_to_rooms_button.hide()
	_draft_panel.show()


func _on_room_chosen(room: MapRoom) -> void:
	_draft_panel.hide()
	_map_view.drafting_cell = MapView.NO_CELL
	Sfx.play("build")
	map.place(room)
	_refresh()
	await _map_view.animate_path([room.coord] as Array[Vector2i])
	if room.scene_path().is_empty():  # nothing inside (an Intersection): stay on the map
		_busy = false
		_check_out_of_steps()
		return
	RunState.enter_room(room)  # switches to the room's scene; leaving it comes back here


func _on_leave_pressed() -> void:
	_busy = false
	_check_out_of_steps()


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file(RunState.MENU_SCENE)


## Out of steps, or (only if a fully walled-in spot made _ensure_exit impossible) nowhere left to build.
func _check_out_of_steps() -> void:
	if map.steps <= 0 or map.frontier().is_empty():
		_busy = true
		RunState.start_boss()


func _hint(text: String) -> void:
	_hint_label.text = text
	await get_tree().create_timer(HINT_TIME).timeout
	if _hint_label.text == text:
		_hint_label.text = ""
