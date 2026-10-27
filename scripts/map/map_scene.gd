extends Control

const DESIGN_SIZE := Vector2(1920, 1080)
const COLOR_BG := Color("#07080b")
const HINT_TIME := 2.0

var map := MapState.new()
var _busy := false  # walking, having popup modal or in a room.

@onready var _map_view: MapView = %MapView
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
	_start()


func _start() -> void:
	map.start()
	_map_view.setup(map)
	_draft_panel.hide()
	_game_over_panel.hide()
	_hint_label.text = ""
	_busy = false
	_refresh()


func _fit_to_window() -> void:
	var window := get_viewport_rect().size
	var s := minf(window.x / DESIGN_SIZE.x, window.y / DESIGN_SIZE.y)
	scale = Vector2(s, s)
	position = (window - DESIGN_SIZE * s) / 2


func _refresh() -> void:
	_steps_label.text = "Steps  %d / %d" % [map.steps, MapState.START_STEPS]


func _on_map_view_cell_clicked(cell: Vector2i) -> void:
	if _busy:
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
	_draft_panel.show()


func _on_room_chosen(room: MapRoom) -> void:
	_draft_panel.hide()
	map.place(room)
	_refresh()
	await _map_view.animate_path([room.coord] as Array[Vector2i])
	# Switch to room's own scene
	_room_title.text = room.display_name()
	_on_leave_pressed() 


func _on_leave_pressed() -> void:
	_busy = false
	_check_out_of_steps()


func _on_restart_pressed() -> void:
	_start()


func _check_out_of_steps() -> void:
	if map.steps <= 0:
		_busy = true
		_game_over_panel.show() # will change to transition to boss room


func _hint(text: String) -> void:
	_hint_label.text = text
	await get_tree().create_timer(HINT_TIME).timeout
	if _hint_label.text == text:
		_hint_label.text = ""
