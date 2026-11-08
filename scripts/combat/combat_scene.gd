extends Control

## Combat screen: hand, piles, energy, end turn, and health grids.
## Click a card to select it, then click a cell for each of its grid actions to play it.
## A card with no grid actions is played by dragging it to the middle of the screen.
## A card that has the player pick cards (from hand or the discard pile) asks while it resolves
## (CombatState.chooser): the player picks them and presses Confirm. There's no cancelling then.
## Picking from the discard pile happens in the pile viewer.

const RenderCard := preload("res://scripts/cards/render_card.gd")
const CARD_SIZE := HandView.CARD_SIZE
const ENEMY_IMAGE_SIZE := Vector2(300, 300)
const LUNGE_DISTANCE := 40.0  # px toward the target
const LUNGE_TIME := 0.06  # out to the target; the hit flashes when it gets there
const LUNGE_BACK_TIME := 0.1
const SHAKE_AMOUNT := 8.0  # px, the first jolt; later ones get smaller
const SHAKE_STEPS := 6
const SHAKE_TIME := 0.15

var combat: CombatState
var selected: BaseCard = null
var _units: Array[CombatUnit] = []  # grid and cell clicked for each grid action so far
var _cells: Array[Vector2i] = []
var _rotations: Array[int] = []  # rotation chosen for each of those clicks
var _rotation := 0  # 60° clockwise steps for the next grid action, kept between clicks
signal _choice_confirmed
var _choice := {}  # what the card being played asks the player to pick (see CombatState.chooser); empty if nothing
var _picks: Array[BaseCard] = []  # cards picked for _choice, from the hand or the discard pile
var _pile_picking := false  # the pile viewer is open for _choice

var _enemy_views: Array[HealthGridView] = []
var _enemy_images: Array[TextureRect] = []  # one per enemy, same order as _enemy_views
var _intent_labels: Array[Label] = []

@onready var _top_bar: TopBar = %TopBar
@onready var _floor_background: TextureRect = %FloorBackground
var _hover_info := HoverInfo.new()  # keywords of cards in the pile viewer and card rewards
@onready var _status_label: Label = %StatusLabel
@onready var _hint_label: Label = %HintLabel
@onready var _player_view: HealthGridView = %PlayerGrid
@onready var _player_image: PlayerImage = %PlayerImage
@onready var _enemies_box: HBoxContainer = %Enemies
@onready var _hand: HandView = %Hand
@onready var _deck_button: Button = %DeckButton
@onready var _draw_button: Button = %DrawPileButton
@onready var _exhaust_button: Button = %ExhaustButton
@onready var _discard_button: Button = %DiscardButton
@onready var _pick_buttons: Control = %PickButtons
@onready var _confirm_button: Button = %ConfirmButton

@onready var _pile_viewer: ColorRect = %PileViewer
@onready var _pile_title: Label = %PileTitle
@onready var _pile_grid: GridContainer = %PileGrid
@onready var _pile_confirm_button: Button = %PileConfirmButton
@onready var _close_pile_button: Button = %CloseButton

@onready var _reward_panel: Control = %RewardPanel
@onready var _gold_button: Button = %GoldButton
@onready var _exp_button: Button = %ExpButton
@onready var _card_button: Button = %CardButton
@onready var _card_choice_panel: Control = %CardChoicePanel
@onready var _card_choices: HBoxContainer = %CardChoices
@onready var _defeat_panel: Control = %DefeatPanel

var _rewards: CombatRewards
var _over := false  # won or lost: ignore combat input
var _busy := false  # a card or a turn is playing out: ignore combat input until it's done


func _ready() -> void:
	if RunState.deck.is_empty():
		RunState.start_new_run()
	_floor_background.texture = RunState.combat_background()
	_hover_info.is_blocked = _top_bar.is_modal_open
	add_child(_hover_info)
	combat = RunState.start_combat()
	for enemy in _enemies_for(_room_type()):
		combat.enemies.append(enemy)

	_hand.card_clicked.connect(_on_card_clicked)
	_hand.card_cast.connect(_on_card_cast)
	_player_view.setup(combat.player, true)
	_player_view.cell_clicked.connect(_on_cell_clicked)
	combat.player.blocked.connect(_on_player_blocked)
	for enemy in combat.enemies:
		var view := HealthGridView.new()
		view.setup(enemy, true)
		view.cell_clicked.connect(_on_cell_clicked)
		var intent_label := Label.new()
		intent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var box := VBoxContainer.new()
		box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		box.add_child(view)
		box.add_child(intent_label)
		# Enemy image on the left, its health grid on the right.
		var side := HBoxContainer.new()
		side.add_theme_constant_override("separation", 24)
		# The image sits in a plain slot, so it can lunge and shake without the HBox putting it back.
		var slot := Control.new()
		slot.custom_minimum_size = ENEMY_IMAGE_SIZE
		slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var image := TextureRect.new()
		image.texture = enemy.sprite
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slot.add_child(image)
		side.add_child(slot)
		side.add_child(box)
		_enemies_box.add_child(side)
		_enemy_views.append(view)
		_enemy_images.append(image)
		_intent_labels.append(intent_label)

	combat.animator = _animate
	combat.chooser = _choose
	_busy = true
	await combat.start_turn()
	_busy = false
	_refresh()


# --- Input -------------------------------------------------------------------

func _on_card_clicked(card: BaseCard) -> void:
	if not _choice.is_empty():
		_toggle_pick(card)
		return
	if _over or _busy:
		return
	if selected == card:
		_select(null)
	elif not combat.can_play(card):
		_hint_label.text = "Not enough energy."
		return
	elif card.grid_actions.is_empty():
		_hint_label.text = "Drag it to the middle of the screen to play."
		return
	else:
		_select(card)
		if card.clicks(combat.energy) == 0:  # an X-cost card with no energy left
			_play_selected()
			return
	_refresh()


## A card with no grid actions, dropped in the middle of the screen.
func _on_card_cast(card: BaseCard) -> void:
	if _over or _busy:
		return
	_select(null)
	if not combat.can_play(card):
		_hint_label.text = "Not enough energy."
		_refresh()
		return
	_select(card)
	_play_selected()


func _on_cell_clicked(unit: CombatUnit, cell: Vector2i) -> void:
	if _over or _busy:
		return
	if selected == null:
		_hint_label.text = "Select a card first."
		return
	if (unit == combat.player) != _targets_player():
		_hint_label.text = "This card targets %s." % ("your grid" if _targets_player() else "an enemy")
		return
	if not selected.grid_action(_cells.size()).can_place(unit, cell, _rotation):
		_hint_label.text = "Every tile of this pattern must land on an undamaged tile."
		return
	_units.append(unit)
	_cells.append(cell)
	_rotations.append(_rotation)
	if _cells.size() < selected.clicks(combat.energy): #store intents in _cells, when all grid has been chosen, this condition reeturn false
		_refresh()
		return
	_play_selected()


func _on_confirm_pressed() -> void:
	if not _choice.is_empty() and _picked_count() == _choice.count:
		_choice_confirmed.emit()


## combat.chooser: shows what to pick, waits for Confirm, and returns the picks.
func _choose(request: Dictionary) -> Array:
	_choice = request
	_picks.clear()
	_refresh()
	await _choice_confirmed
	var picked: Array = _picks.duplicate()
	_choice = {}
	_picks.clear()
	_refresh()
	return picked


func _toggle_pick(card: BaseCard) -> void:
	if _choice.is_empty() or card not in _choice.cards:
		return
	if card in _picks:
		_picks.erase(card)
	elif _picks.size() < _choice.count:
		_picks.append(card)
	_refresh()


## Plays the selected card at the cells clicked so far.
func _play_selected() -> void:
	# Deselect first so the preview is gone while the card plays out.
	var card := selected
	var units := _units.duplicate()
	var cells := _cells.duplicate()
	var rotations := _rotations.duplicate()
	_select(null)
	_refresh()
	_busy = true
	if card.type == Enum.CardType.ATTACK:
		_player_image.show_pose(PlayerImage.ATTACK)
	await combat.play_card(card, units, cells, rotations)
	_busy = false
	_refresh()
	_check_combat_end()


func _picked_count() -> int:
	return _picks.size()


func _on_end_turn_pressed() -> void:
	if _over or _busy:
		return
	_select(null)
	_refresh()
	_busy = true
	await combat.end_turn()
	_busy = false
	_refresh()
	_check_combat_end()


## Only enemy hits count, not the player's own Poison at turn start.
func _on_player_blocked(_coords: Vector2i) -> void:
	if not combat.player.in_turn:
		_player_image.show_pose(PlayerImage.GUARD)


func _on_deck_pressed() -> void:
	_show_pile("Deck", RunState.deck)


func _on_draw_pile_pressed() -> void:
	_show_pile("Draw pile", combat.draw_pile, true)


func _on_discard_pressed() -> void:
	_show_pile("Discard pile", combat.discard_pile)


func _on_exhaust_pressed() -> void:
	_show_pile("Exhausted", combat.exhaust_pile)


func _on_close_pile_pressed() -> void:
	_close_pile()


## While picking from the discard pile, only Confirm closes it.
func _close_pile() -> void:
	if not _pile_picking:
		_pile_viewer.hide()


## Clicking the dark background outside the panel closes the viewer.
func _on_pile_viewer_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_close_pile()

func _on_win_combat_pressed()->void:
	_end_combat()
	_rewards = CombatRewards.roll(_room_type())
	_refresh_rewards()
	_reward_panel.show()

## _input, not _unhandled_input: the grids and this root stop mouse events, so right-clicks never arrive unhandled.
func _input(event: InputEvent) -> void:
	if _over or _busy or _top_bar.is_modal_open():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if _pile_viewer.visible:
			_close_pile()
		elif selected:
			_select(null)
			_refresh()
		else:
			return
		get_viewport().set_input_as_handled()
	elif selected and _choice.is_empty() and not _pile_viewer.visible and _rotation_step(event) != 0:
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

## combat.animator: shows the new state, then plays the batch and waits for it. If the batch hits
## the other side, the acting unit lunges at it first. On impact every change flashes at once,
## and every unit that took damage shakes: an enemy's sprite, or the player's grid.
func _animate(batch: Array[Dictionary]) -> void:
	_refresh()
	var attacker := combat.acting_unit()
	var target: CombatUnit = null  # first unit on the other side that was hit or blocked a hit
	var damaged: Array[CombatUnit] = []
	for change in batch:
		var unit: CombatUnit = change.unit
		if change.kind == Enum.Change.DAMAGE and unit not in damaged:
			damaged.append(unit)
		if target == null and attacker and unit.is_player != attacker.is_player \
				and change.kind in [Enum.Change.DAMAGE, Enum.Change.BLOCK]:
			target = unit
	if target:
		var sprite := _sprite_for(attacker)
		_lunge(sprite, _center(_sprite_for(target)) - _center(sprite))
		await get_tree().create_timer(LUNGE_TIME).timeout
	for change in batch:
		_view_for(change.unit).flash(change.cell, change.kind, change.effect)
	for unit in damaged:
		if unit == combat.player:
			_shake(_player_view, "shake")
		else:
			_shake(_sprite_for(unit), "position")
	await get_tree().create_timer(HealthGridView.FLASH_TIME).timeout


## Moves node LUNGE_DISTANCE toward a point, then back. node rests at ZERO inside its slot.
func _lunge(node: Control, toward: Vector2) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(node, "position", toward.normalized() * LUNGE_DISTANCE, LUNGE_TIME).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", Vector2.ZERO, LUNGE_BACK_TIME).set_ease(Tween.EASE_IN_OUT)


## Jolts a Vector2 property that rests at ZERO in random directions, smaller each time, then back to ZERO.
func _shake(node: Object, property: String) -> void:
	var step := SHAKE_TIME / (SHAKE_STEPS + 1)
	var tween := create_tween()
	for i in SHAKE_STEPS:
		var amount := SHAKE_AMOUNT * (1.0 - float(i) / SHAKE_STEPS)
		tween.tween_property(node, property, Vector2.from_angle(randf() * TAU) * amount, step)
	tween.tween_property(node, property, Vector2.ZERO, step)


func _sprite_for(unit: CombatUnit) -> Control:
	if unit == combat.player:
		return _player_image
	return _enemy_images[combat.enemies.find(unit)]


func _center(control: Control) -> Vector2:
	return control.global_position + control.size / 2.0


func _refresh() -> void:
	_top_bar.refresh()
	_status_label.text = "Turn %d    Energy %d/%d" % [combat.turn, combat.energy, combat.max_energy]
	_deck_button.text = "Deck (%d)" % RunState.deck.size()
	_draw_button.text = "Draw pile (%d)" % combat.draw_pile.size()
	_exhaust_button.text = "Exhausted (%d)" % combat.exhaust_pile.size()
	_discard_button.text = "Discard (%d)" % combat.discard_pile.size()
	var choosing := not _choice.is_empty()
	var discard_picking: bool = choosing and not _choice.in_hand
	var hand_picking: bool = choosing and _choice.in_hand
	_pick_buttons.visible = choosing and not discard_picking
	if choosing:
		_confirm_button.disabled = _picked_count() < _choice.count
		_hint_label.text = _choice.prompt
	elif selected:
		var step := ""
		if selected.clicks(combat.energy) > 1:
			step = " (pattern %d/%d)" % [_cells.size() + 1, selected.clicks(combat.energy)]
		if _next_grid_action() is RandomGridAction:
			_hint_label.text = "Click %s%s. Right-click to cancel." % ["your grid" if _targets_player() else "an enemy", step]
		else:
			_hint_label.text = "Click a cell on %s%s. Q/E or scroll to rotate. Right-click to cancel." % ["your grid" if _targets_player() else "the enemy", step]
	else:
		_hint_label.text = "Click a card to select it."

	if discard_picking:
		_show_pile(_choice.prompt.trim_suffix("."), _choice.cards, false, true)
	elif _pile_picking:
		_pile_viewer.hide()
	_pile_picking = discard_picking

	_hand.picking = hand_picking
	if hand_picking:
		_hand.set_hand(combat.hand, selected, func(_card: BaseCard) -> bool: return true, _picks)
	else:
		_hand.set_hand(combat.hand, selected, combat.can_play)

	# Only the grid action the next click places is previewed.
	var pattern: Dictionary[Vector2i, BaseActionTile] = {}
	var next := _next_grid_action()
	if next:
		pattern = next.rotated(_rotation)
	var none: Dictionary[Vector2i, BaseActionTile] = {}
	var on_player := selected != null and _targets_player()
	# A random grid action has no pattern: every grid it can go on flickers instead.
	var random_tile: BaseActionTile = next.tiles[0] if next is RandomGridAction else null
	for view in _enemy_views:
		view.preview = none if on_player else pattern
		view.random_target = null if on_player else random_tile
		view.refresh()
	_player_view.preview = pattern if on_player else none
	_player_view.random_target = random_tile if on_player else null

	# Grid actions already clicked flicker where they will land.
	for view in _enemy_views:
		view.placed = []
	_player_view.placed = []
	for i in _cells.size():
		_view_for(_units[i]).placed.append({cell = _cells[i], tiles = selected.grid_action(i).rotated(_rotations[i])})

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


## The selected card's grid action the next click places, or null.
func _next_grid_action() -> GridAction:
	if selected and _cells.size() < selected.clicks(combat.energy):
		return selected.grid_action(_cells.size())
	return null


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
	if _cells.size() < selected.clicks(combat.energy):
		target = selected.grid_action(_cells.size()).target
	return target == Enum.TargetType.PLAYER


## A card wrapped in a Control so containers can lay it out (Card.tscn's root is a Node2D).
func _card_slot(card: BaseCard) -> Control:
	var slot := Control.new()
	slot.custom_minimum_size = CARD_SIZE
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(RenderCard.create_card(card))
	return slot


# --- Pile viewer -------------------------------------------------------------

## picking: clicking a card picks it for the selected card, and Close becomes Cancel.
func _show_pile(title: String, cards: Array[BaseCard], hide_order := false, picking := false) -> void:
	_pile_title.text = "%s (%d)" % [title, cards.size()]
	_pile_confirm_button.visible = picking
	_pile_confirm_button.disabled = picking and _picks.size() < _choice.count
	_close_pile_button.visible = not picking
	_hover_info.clear()
	for child in _pile_grid.get_children():
		child.queue_free()
	var shown := cards.duplicate()
	if hide_order:
		shown.sort_custom(func(a: BaseCard, b: BaseCard) -> bool: return a.card_name < b.card_name)
	for card in shown:
		var slot := _card_slot(card)
		var panel: Panel = slot.get_child(0).get_node("Panel")
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if picking:
			slot.mouse_filter = Control.MOUSE_FILTER_STOP
			slot.gui_input.connect(_on_pile_card_input.bind(card))
			if card in _picks:
				var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
				style.border_color = HandView.COLOR_PICKED
				style.set_border_width_all(6)
		_pile_grid.add_child(slot)
		_hover_info.add_card(slot, card, _pile_grid.get_parent())
	if shown.is_empty():
		var empty := Label.new()
		empty.text = "Empty"
		_pile_grid.add_child(empty)
	_pile_viewer.show()


func _on_pile_card_input(event: InputEvent, card: BaseCard) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_pick(card)


# --- Room, end of combat and rewards ----------------------------------------

func _room_type() -> Enum.RoomType:
	if RunState.current_room and RunState.current_room.is_combat():
		return RunState.current_room.type
	return Enum.RoomType.NORMAL_COMBAT


## Placeholder line-ups until there are more enemies.
func _enemies_for(room_type: Enum.RoomType) -> Array[CombatUnit]:
	var enemies: Array[CombatUnit] = []
	if room_type == Enum.RoomType.BOSS_COMBAT:
		enemies.append(RunState.floor_boss())
		return enemies
	var count := 2 if room_type == Enum.RoomType.ELITE_COMBAT else 1
	for i in count:
		enemies.append(Slime.new())
	return enemies


func _check_combat_end() -> void:
	if _over:
		return
	if combat.is_lost():
		_end_combat()
		_defeat_panel.show()
	elif combat.is_won():
		_end_combat()
		_rewards = CombatRewards.roll(_room_type())
		_refresh_rewards()
		_reward_panel.show()


func _end_combat() -> void:
	_over = true
	_select(null)
	_pile_viewer.hide()
	_hand.hide()
	_hand.set_process_input(false)
	RunState.end_combat()


func _refresh_rewards() -> void:
	_top_bar.refresh()
	_gold_button.text = "%d Coins" % _rewards.gold
	_exp_button.text = "%d EXP" % _rewards.exp_points
	_gold_button.visible = not _rewards.gold_taken
	_exp_button.visible = not _rewards.exp_taken
	_card_button.visible = not _rewards.card_taken


func _on_gold_reward_pressed() -> void:
	_rewards.take_gold(RunState)
	_refresh_rewards()


func _on_exp_reward_pressed() -> void:
	_rewards.take_exp(RunState)
	_refresh_rewards()


func _on_card_reward_pressed() -> void:
	_hover_info.clear()
	for child in _card_choices.get_children():
		child.queue_free()
	for card in _rewards.cards:
		var slot := _card_slot(card)
		var panel: Control = slot.get_child(0).get_node("Panel")
		panel.gui_input.connect(_on_reward_card_input.bind(card))
		_card_choices.add_child(slot)
		_hover_info.add_card(slot, card)
	_card_choice_panel.show()


func _on_reward_card_input(event: InputEvent, card: BaseCard) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_rewards.take_card(RunState, card)
		_card_choice_panel.hide()
		_refresh_rewards()


func _on_skip_card_pressed() -> void:
	_rewards.take_card(RunState, null)
	_card_choice_panel.hide()
	_refresh_rewards()


func _on_card_choice_back_pressed() -> void:
	_card_choice_panel.hide()


## Coins and EXP left on the table are collected on the way out; an unpicked card is lost.
func _on_continue_pressed() -> void:
	_rewards.take_gold(RunState)
	_rewards.take_exp(RunState)
	RunState.leave_room()


func _on_new_run_pressed() -> void:
	RunState.start_new_run()
	get_tree().change_scene_to_file(RunState.COMBAT_SCENE)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(RunState.MENU_SCENE)
