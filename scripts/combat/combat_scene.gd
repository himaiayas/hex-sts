extends Control

## Combat screen: hand, piles, energy, end turn, and health grids.
## Click a card to select it, then click a cell for each of its grid actions to play it.

const RenderCard := preload("res://scripts/cards/render_card.gd")
const CARD_SIZE := HandView.CARD_SIZE

var combat: CombatState
var selected: BaseCard = null
var _units: Array[CombatUnit] = []  # grid and cell clicked for each grid action so far
var _cells: Array[Vector2i] = []
var _rotations: Array[int] = []  # rotation chosen for each of those clicks
var _rotation := 0  # 60° clockwise steps for the next grid action, kept between clicks

var _enemy_views: Array[HealthGridView] = []
var _intent_labels: Array[Label] = []

@onready var _status_label: Label = %StatusLabel
@onready var _hint_label: Label = %HintLabel
@onready var _player_view: HealthGridView = %PlayerGrid
@onready var _enemies_box: HBoxContainer = %Enemies
@onready var _hand: HandView = %Hand
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
	combat.enemies.append(Slime.new())

	_hand.card_clicked.connect(_on_card_clicked)
	_player_view.setup(combat.player, true)
	_player_view.cell_clicked.connect(_on_cell_clicked)
	for enemy in combat.enemies:
		var view := HealthGridView.new()
		view.setup(enemy, true)
		view.cell_clicked.connect(_on_cell_clicked)
		var intent_label := Label.new()
		intent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var box := VBoxContainer.new()
		box.add_child(view)
		box.add_child(intent_label)
		_enemies_box.add_child(box)
		_enemy_views.append(view)
		_intent_labels.append(intent_label)

	combat.start_turn()
	_refresh()


# --- Input -------------------------------------------------------------------

func _on_card_clicked(card: BaseCard) -> void:
	if selected == card:
		_select(null)
	elif combat.can_play(card):
		_select(card)
	else:
		_hint_label.text = "Not enough energy."
		return
	_refresh()


func _on_cell_clicked(unit: CombatUnit, cell: Vector2i) -> void:
	if selected == null:
		_hint_label.text = "Select a card first."
		return
	if (unit == combat.player) != _targets_player():
		_hint_label.text = "This card targets %s." % ("your grid" if _targets_player() else "an enemy")
		return
	_units.append(unit)
	_cells.append(cell)
	_rotations.append(_rotation)
	if _cells.size() < selected.grid_actions.size(): #store intents in _cells, when all grid has been chosen, this condition reeturn false
		_refresh()
		return
	combat.play_card(selected, _units, _cells, _rotations)
	_select(null)
	_refresh()


func _on_end_turn_pressed() -> void:
	_select(null)
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


## _input, not _unhandled_input: the grids and this root stop mouse events, so right-clicks never arrive unhandled.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if _pile_viewer.visible:
			_pile_viewer.hide()
		elif selected:
			_select(null)
			_refresh()
		else:
			return
		get_viewport().set_input_as_handled()
	elif selected and not _pile_viewer.visible and _rotation_step(event) != 0:
		_rotation = posmod(_rotation + _rotation_step(event), 6)
		_refresh()
		get_viewport().set_input_as_handled()


## +1 clockwise (E or wheel down), -1 anticlockwise (Q or wheel up), 0 for anything else.
## Physical keys so Q/E stay put on other keyboard layouts.
func _rotation_step(event: InputEvent) -> int:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_E: return 1
			KEY_Q: return -1
	elif event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_DOWN: return 1
			MOUSE_BUTTON_WHEEL_UP: return -1
	return 0


# --- Refresh -----------------------------------------------------------------

func _refresh() -> void:
	_status_label.text = "Turn %d    Energy %d/%d" % [combat.turn, combat.energy, combat.max_energy]
	_deck_button.text = "Deck (%d)" % RunState.deck.size()
	_draw_button.text = "Draw pile (%d)" % combat.draw_pile.size()
	_discard_button.text = "Discard (%d)" % combat.discard_pile.size()
	if selected:
		var step := ""
		if selected.grid_actions.size() > 1:
			step = " (pattern %d/%d)" % [_cells.size() + 1, selected.grid_actions.size()]
		_hint_label.text = "Click a cell on %s%s. Q/E or scroll to rotate. Right-click to cancel." % ["your grid" if _targets_player() else "the enemy", step]
	else:
		_hint_label.text = "Click a card to select it."

	_hand.set_hand(combat.hand, selected, combat.can_play)

	# Only the grid action the next click places is previewed.
	var pattern: Dictionary[Vector2i, BaseActionTile] = {}
	if selected and _cells.size() < selected.grid_actions.size():
		pattern = selected.grid_actions[_cells.size()].rotated(_rotation)
	var none: Dictionary[Vector2i, BaseActionTile] = {}
	var on_player := selected != null and _targets_player()
	for view in _enemy_views:
		view.preview = none if on_player else pattern
		view.refresh()
	_player_view.preview = pattern if on_player else none

	# Grid actions already clicked flicker where they will land.
	for view in _enemy_views:
		view.placed = []
	_player_view.placed = []
	for i in _cells.size():
		_view_for(_units[i]).placed.append({cell = _cells[i], tiles = selected.grid_actions[i].rotated(_rotations[i])})

	# Intents blink on the grid each part targets: attacks on the player, shields on the enemy itself.
	var player_intents: Array = []
	for i in combat.enemies.size():
		var enemy := combat.enemies[i] as BaseEnemy
		var action: BaseEnemyAction = enemy.intent_action if enemy else null
		var self_intents: Array = []
		_intent_labels[i].text = "Intent: %s" % action.action_name if action else ""
		if action:
			for part in action.parts:
				var intent := {cell = part.cell, tiles = part.tiles}
				if part.side == Enum.Side.PLAYER:
					player_intents.append(intent)
				else:
					self_intents.append(intent)
		_enemy_views[i].intents = self_intents
		_enemy_views[i].refresh()
	_player_view.intents = player_intents
	_player_view.refresh()


func _view_for(unit: CombatUnit) -> HealthGridView:
	if unit == combat.player:
		return _player_view
	return _enemy_views[combat.enemies.find(unit)]


func _select(card: BaseCard) -> void:
	selected = card
	_units.clear()
	_cells.clear()
	_rotations.clear()
	_rotation = 0


## Whether the next click goes on the player's grid: the current grid action's target, or the card's.
func _targets_player() -> bool:
	var target := selected.target
	if _cells.size() < selected.grid_actions.size():
		target = selected.grid_actions[_cells.size()].target
	return target == Enum.TargetType.PLAYER


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
