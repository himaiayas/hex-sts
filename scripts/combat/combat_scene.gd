extends Control

## Combat screen: hand, piles, energy, end turn, and health grids.
## Click a card to select it, then click a cell on an enemy's health grid to play it.

const RenderCard := preload("res://scripts/cards/render_card.gd")
const CARD_SIZE := Vector2(140, 190)
const SELECT_RAISE := 24.0

var combat: CombatState
var selected: BaseCard = null

var _enemy_views: Array[HealthGridView] = []

@onready var _status_label: Label = %StatusLabel
@onready var _hint_label: Label = %HintLabel
@onready var _player_view: HealthGridView = %PlayerGrid
@onready var _enemies_box: HBoxContainer = %Enemies
@onready var _hand_box: HBoxContainer = %Hand
@onready var _deck_button: Button = %DeckButton
@onready var _draw_button: Button = %DrawPileButton
@onready var _discard_button: Button = %DiscardButton

@onready var _pile_viewer: ColorRect = %PileViewer
@onready var _pile_title: Label = %PileTitle
@onready var _pile_grid: GridContainer = %PileGrid


func _ready() -> void:
	if RunState.deck.is_empty():
		RunState.start_new_run()
	combat = RunState.start_combat()
	var coords: Array[Vector2i] = [
		Vector2i(0, 0), 
		Vector2i(1, 0), 
		Vector2i(0, 1), 
		Vector2i(-1, 1), 
		Vector2i(-1, 0), 
		Vector2i(0, -1), 
		Vector2i(1, -1),
		Vector2i(2,0),
		Vector2i(1,1),
		Vector2i(0,2),
		Vector2i(-1,2),
		Vector2i(-2,1),
		Vector2i(-2,0),
		Vector2i(-1,-1),
		Vector2i(0,-2),
		Vector2i(1,-2),
		Vector2i(2,-1),
	]
	combat.enemies.append(CombatUnit.new("Slime", CombatUnit.make_hex_health(coords)))

	_player_view.setup(combat.player, false)
	for enemy in combat.enemies:
		var view := HealthGridView.new()
		view.setup(enemy, true)
		view.cell_clicked.connect(_on_enemy_cell_clicked)
		_enemies_box.add_child(view)
		_enemy_views.append(view)

	combat.start_turn()
	_refresh()


# --- Input -------------------------------------------------------------------

func _on_card_input(event: InputEvent, card: BaseCard) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	accept_event()
	if selected == card:
		selected = null
	elif combat.can_play(card):
		selected = card
	else:
		_hint_label.text = "Not enough energy."
		return
	_refresh()


func _on_enemy_cell_clicked(unit: CombatUnit, cell: Vector2i) -> void:
	if selected == null:
		_hint_label.text = "Select a card first."
		return
	combat.play_card(selected, unit, cell)
	selected = null
	_refresh()


func _on_end_turn_pressed() -> void:
	selected = null
	combat.end_turn()
	_refresh()


func _on_deck_pressed() -> void:
	_show_pile("Deck", RunState.deck)


func _on_draw_pile_pressed() -> void:
	_show_pile("Draw pile", combat.draw_pile, true)


func _on_discard_pressed() -> void:
	_show_pile("Discard pile", combat.discard_pile)


func _on_close_pile_pressed() -> void:
	_pile_viewer.hide()


## Clicking the dark background outside the panel closes the viewer.
func _on_pile_viewer_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_pile_viewer.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if _pile_viewer.visible:
			_pile_viewer.hide()
		elif selected:
			selected = null
			_refresh()


# --- Refresh -----------------------------------------------------------------

func _refresh() -> void:
	_status_label.text = "Turn %d    Energy %d/%d" % [combat.turn, combat.energy, combat.max_energy]
	_deck_button.text = "Deck (%d)" % RunState.deck.size()
	_draw_button.text = "Draw pile (%d)" % combat.draw_pile.size()
	_discard_button.text = "Discard (%d)" % combat.discard_pile.size()
	if selected:
		_hint_label.text = "Click a cell on the enemy. Right-click to cancel."
	else:
		_hint_label.text = "Click a card to select it."

	for child in _hand_box.get_children():
		child.queue_free()
	for card in combat.hand:
		var slot := _card_slot(card)
		var panel: Control = slot.get_child(0).get_node("Panel")
		panel.gui_input.connect(_on_card_input.bind(card))
		if card == selected:
			slot.get_child(0).position.y = -SELECT_RAISE
		elif not combat.can_play(card):
			slot.modulate = Color(0.55, 0.55, 0.55)
		_hand_box.add_child(slot)

	var pattern: Array[BaseActionTile] = []
	if selected:
		pattern = selected.tiles
	for view in _enemy_views:
		view.action_tiles = pattern
		view.refresh()
	_player_view.refresh()


## A card wrapped in a Control so containers can lay it out (Card.tscn's root is a Node2D).
func _card_slot(card: BaseCard) -> Control:
	var slot := Control.new()
	slot.custom_minimum_size = CARD_SIZE
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(RenderCard.create_card(card))
	return slot


# --- Pile viewer -------------------------------------------------------------

func _show_pile(title: String, cards: Array[BaseCard], hide_order := false) -> void:
	_pile_title.text = "%s (%d)" % [title, cards.size()]
	for child in _pile_grid.get_children():
		child.queue_free()
	var shown := cards.duplicate()
	if hide_order:
		shown.sort_custom(func(a: BaseCard, b: BaseCard) -> bool: return a.card_name < b.card_name)
	for card in shown:
		var slot := _card_slot(card)
		slot.get_child(0).get_node("Panel").mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pile_grid.add_child(slot)
	if shown.is_empty():
		var empty := Label.new()
		empty.text = "Empty"
		_pile_grid.add_child(empty)
	_pile_viewer.show()
