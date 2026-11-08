extends Control

## Combat screen: hand, piles, energy, end turn, and health grids.
## Click a card to select it, then click a cell for each of its grid actions to play it.
## A card with no grid actions is played by dragging it to the middle of the screen.
## A card that picks cards (from hand or the discard pile) or tiles of yours (e.g. Heal) then waits for
## the player to pick them and press Confirm. Picking from the discard pile happens in the pile viewer.

const RenderCard := preload("res://scripts/cards/render_card.gd")
const CARD_SIZE := HandView.CARD_SIZE
const LUNGE_DISTANCE := 40.0  # px toward the target
const LUNGE_TIME := 0.1  # out to the target; the hit flashes when it gets there
const LUNGE_BACK_TIME := 0.15
const VFX_SCALE := 1.25  # an enemy move's hit image, relative to its area
const RIPPLES := 3
const RIPPLE_GAP := 0.2  # seconds between rings
const RIPPLE_TIME := 1.0  # each ring, from RIPPLE_START to full size
const RIPPLE_START := 0.3
const RIPPLE_WIDTH := 1800.0  # px, a ring at full size
const AIM_SIZE := Vector2(200, 200)
const AIM_DRIFT := 30.0  # px the sight wanders from the middle of the player's sprite
const AIM_LOOP_TIME := 3.0
const SHAKE_AMOUNT := 8.0  # px, the first jolt; later ones get smaller
const SHAKE_STEPS := 6
const SHAKE_TIME := 0.25
const PROJECTILE_WIDTH := 200.0  # px; its height keeps the texture's aspect
const PROJECTILE_SPEED := 2400.0  # px per second, steady
const SPRITE_FLASH := Color(2.5, 2.5, 2.5)  # a sprite's brightest, fading back over the hex flash

var combat: CombatState
var selected: BaseCard = null
var _units: Array[CombatUnit] = []  # grid and cell clicked for each grid action so far
var _cells: Array[Vector2i] = []
var _rotations: Array[int] = []  # rotation chosen for each of those clicks
var _rotation := 0  # 60° clockwise steps for the next grid action, kept between clicks
var _picking := false  # every grid action is placed; picking cards in hand or tiles of yours until Confirm
var _picks: Array[BaseCard] = []  # cards picked, from hand or the discard pile
var _pile_picking := false  # the pile viewer is open for picking from the discard pile
var _tile_picks: Array[Vector2i] = []  # tiles of yours picked for selected.pick_tile

var _enemy_views: Array[HealthGridView] = []
var _enemy_images: Array[UnitImage] = []  # one per enemy, same order as _enemy_views
var _intent_labels: Array[Label] = []
var _aim: TextureRect  # an enemy's sight on the player's sprite, while a move with aim_vfx is in its intent

@onready var _top_bar: TopBar = %TopBar
@onready var _floor_background: TextureRect = %FloorBackground
@onready var _status_label: Label = %StatusLabel
@onready var _hint_label: Label = %HintLabel
@onready var _player_view: HealthGridView = %PlayerGrid
@onready var _player_image: UnitImage = %PlayerImage
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
	if testing and _room_type() != Enum.RoomType.BOSS_COMBAT and _floor_of(testing) > 0:
		_floor_background.texture = RunState.FLOOR_COMBAT_BACKGROUNDS[_floor_of(testing) - 1]  # the test monster's floor
	combat = RunState.start_combat()
	for enemy in _enemies_for(_room_type()):
		combat.enemies.append(enemy)

	_hand.card_clicked.connect(_on_card_clicked)
	_hand.card_cast.connect(_on_card_cast)
	_hand.cost_of = combat.cost_of
	_player_view.setup(combat.player, true)
	_player_view.cell_clicked.connect(_on_cell_clicked)
	combat.player.blocked.connect(_on_player_blocked)
	combat.enemy_spawned.connect(_on_enemy_spawned)
	for enemy in combat.enemies:
		_add_enemy(enemy)

	combat.animator = _animate
	_busy = true
	await combat.start_turn()
	_busy = false
	_refresh()


## Builds an enemy's sprite slot, grid and intent label, at its place in combat.enemies.
func _add_enemy(enemy: BaseEnemy) -> void:
	var view := HealthGridView.new()
	view.setup(enemy, true)
	view.cell_clicked.connect(_on_cell_clicked)
	view.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# The intent hangs under the grid, as wide as it, and grows down only,
	# so a longer or shorter intent never moves the enemy.
	var intent_label := Label.new()
	intent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intent_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intent_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.add_child(intent_label)
	intent_label.anchor_top = 1.0
	intent_label.anchor_bottom = 1.0
	intent_label.anchor_right = 1.0
	intent_label.grow_vertical = Control.GROW_DIRECTION_END
	# Enemy image on the left, its health grid on the right.
	var side := HBoxContainer.new()
	side.add_theme_constant_override("separation", 24)
	# The image sits in a plain slot, so it can lunge and shake without the HBox putting it back.
	var slot := Control.new()
	slot.custom_minimum_size = enemy.image_size
	slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var image := UnitImage.new()
	image.idle_frames = enemy.idle_frames
	if image.idle_frames.is_empty():
		image.idle_frames = [enemy.sprite]
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	slot.add_child(image)
	side.add_child(slot)
	side.add_child(view)
	var i := combat.enemies.find(enemy)
	_enemies_box.add_child(side)
	_enemies_box.move_child(side, i)
	_enemy_views.insert(i, view)
	_enemy_images.insert(i, image)
	_intent_labels.insert(i, intent_label)


## A spawned enemy takes in_place_of's place on screen, with a flash.
func _on_enemy_spawned(enemy: CombatUnit, in_place_of: CombatUnit) -> void:
	_add_enemy(enemy)
	_view_for(in_place_of).get_parent().hide()
	_flash_sprite(_sprite_for(enemy))


# --- Input -------------------------------------------------------------------

func _on_card_clicked(card: BaseCard) -> void:
	if _over or _busy:
		return
	if _picking:
		_toggle_pick(card)
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
		if card.clicks(combat.x_energy()) == 0:  # an X-cost card with no energy left
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
	if _picking:
		_toggle_tile_pick(unit, cell)
		return
	if selected == null:
		_hint_label.text = "Select a card first."
		return
	if (unit == combat.player) != _targets_player():
		_hint_label.text = "This card targets %s." % ("your grid" if _targets_player() else "an enemy")
		return
	_units.append(unit)
	_cells.append(cell)
	_rotations.append(_rotation)
	if _cells.size() < selected.clicks(combat.x_energy()): #store intents in _cells, when all grid has been chosen, this condition reeturn false
		_refresh()
		return
	_play_selected()


func _on_confirm_pressed() -> void:
	if _over or _busy:
		return
	_play_selected()


func _on_cancel_pressed() -> void:
	_select(null)
	_refresh()


func _toggle_pick(card: BaseCard) -> void:
	if card not in _pick_pool():
		return
	if card in _picks:
		_picks.erase(card)
	elif _picks.size() < _pick_count():
		_picks.append(card)
	_refresh()


func _toggle_tile_pick(unit: CombatUnit, cell: Vector2i) -> void:
	if selected.pick_tiles == 0 or unit != combat.player:
		return
	if cell in _tile_picks:
		_tile_picks.erase(cell)
		# e.g. a Plated tile can't stay picked for Sacrifice once an open tile is unpicked
		_tile_picks.assign(_tile_picks.filter(func(c: Vector2i) -> bool: return selected.pick_tile.can_pick(unit, c, _tile_picks)))
	elif _tile_picks.size() < _pick_count() and selected.pick_tile.can_pick(unit, cell, _tile_picks):
		_tile_picks.append(cell)
	_refresh()


## Plays the selected card at the cells clicked so far. A card that exhausts cards from hand
## goes to the pick step first, and plays when Confirm calls this again.
func _play_selected() -> void:
	if not _picking and _pick_count() > 0:
		_picking = true
		_refresh()
		return
	# Deselect first so the preview is gone while the card plays out.
	var card := selected
	var units := _units.duplicate()
	var cells := _cells.duplicate()
	var rotations := _rotations.duplicate()
	var picks := _picks.duplicate()
	var tile_picks := _tile_picks.duplicate()
	_select(null)
	_refresh()
	_busy = true
	if card.type == Enum.CardType.ATTACK:
		_player_image.show_pose(UnitImage.PLAYER_ATTACK)
	await combat.play_card(card, units, cells, rotations, picks, tile_picks)
	_busy = false
	_refresh()
	_check_combat_end()


## Cards or tiles to pick: the selected card's pick_tiles, pick_from_discard or exhaust_from_hand,
## or every one there is if there are fewer.
func _pick_count() -> int:
	if selected.pick_tiles > 0:
		var open := combat.player.health.keys().filter(func(c: Vector2i) -> bool: return selected.pick_tile.can_inflict(combat.player, c))
		return mini(selected.pick_tiles, open.size())
	var wanted := selected.pick_from_discard if selected.pick_from_discard > 0 else selected.exhaust_from_hand
	return mini(wanted, _pick_pool().size())


## Cards the selected card can pick from: the discard pile, or the rest of the hand.
func _pick_pool() -> Array:
	if selected.pick_from_discard > 0:
		return combat.discard_pile
	if selected.exhaust_from_hand > 0:
		return combat.hand.filter(func(c: BaseCard) -> bool: return c != selected)
	return []


func _picked_count() -> int:
	return _tile_picks.size() if selected.pick_tiles > 0 else _picks.size()


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
		_player_image.show_pose(UnitImage.PLAYER_GUARD)


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


## Closing the viewer while picking from the discard pile cancels the card.
func _close_pile() -> void:
	_pile_viewer.hide()
	if _pile_picking:
		_select(null)
		_refresh()


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
	elif selected and not _picking and not _pile_viewer.visible and _rotation_step(event) != 0:
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
## the other side, the acting unit lunges at it first, in its move's pose if it has one. On impact
## the move's hit image fades over the target's grid, every change flashes at once,
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
	var enemy := attacker as BaseEnemy
	var action: BaseEnemyAction = enemy.acting_action if enemy else null
	if target:
		var sprite := _sprite_for(attacker)
		if action and action.pose:
			sprite.show_pose(action.pose)
		_lunge(sprite, _center(_sprite_for(target)) - _center(sprite))
		await get_tree().create_timer(LUNGE_TIME).timeout
		if action and action.projectile_vfx:
			await _shoot(action.projectile_vfx, sprite, _sprite_for(target))
		if action and action.hit_vfx:
			var area := enemy.hit_vfx_area if enemy.hit_vfx_area.has_area() else _view_for(target).get_global_rect()
			_show_vfx(action.hit_vfx, area)
	if action and action.ripple_vfx and batch.any(func(c: Dictionary) -> bool: return c.unit == attacker):
		_ripple(action.ripple_vfx, _center(_sprite_for(attacker)))
	for change in batch:
		_view_for(change.unit).flash(change.cell, change.kind, change.effect)
		if change.effect is MultiHeadPower or change.effect is RisePower:  # a Hydra head was cut, a Zombie rose
			_flash_sprite(_sprite_for(change.unit))
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


## Fades an enemy move's hit image out, as long as the hex flash. It's drawn VFX_SCALE times the
## size of area (global coords), centered on it.
func _show_vfx(texture: Texture2D, area: Rect2) -> void:
	var size := area.size * VFX_SCALE
	var vfx := _add_vfx(texture, Rect2(area.get_center() - size / 2.0, size))
	var tween := vfx.create_tween()
	tween.tween_property(vfx, "modulate:a", 0.0, HealthGridView.FLASH_TIME)
	tween.tween_callback(vfx.queue_free)


## Flies texture left at PROJECTILE_SPEED, from from's left edge until its tip passes to's right edge,
## at a random height both sprites share.
func _shoot(texture: Texture2D, from: Control, to: Control) -> void:
	var size := Vector2(PROJECTILE_WIDTH, PROJECTILE_WIDTH * texture.get_height() / texture.get_width())
	var a := from.get_global_rect()
	var b := to.get_global_rect()
	var top := maxf(a.position.y, b.position.y)
	var bottom := maxf(top, minf(a.end.y, b.end.y) - size.y)
	var start := Vector2(a.position.x - size.x, randf_range(top, bottom))
	var vfx := _add_vfx(texture, Rect2(start, size))
	var tween := vfx.create_tween()
	tween.tween_property(vfx, "global_position:x", b.end.x, absf(start.x - b.end.x) / PROJECTILE_SPEED)
	tween.tween_callback(vfx.queue_free)
	await tween.finished


## RIPPLES rings of texture spreading out from center (global coords) like water: each grows from
## RIPPLE_START to RIPPLE_WIDTH wide and fades, RIPPLE_GAP after the last. Drawn under the arena.
func _ripple(texture: Texture2D, center: Vector2) -> void:
	var size := Vector2(RIPPLE_WIDTH, RIPPLE_WIDTH * texture.get_height() / texture.get_width())
	for i in RIPPLES:
		var ring := _add_vfx(texture, Rect2(center - size / 2.0, size), true)
		ring.pivot_offset = size / 2.0
		ring.scale = Vector2.ONE * RIPPLE_START
		ring.modulate.a = 0.0  # hidden until its turn
		var tween := ring.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_interval(RIPPLE_GAP * i)
		tween.tween_property(ring, "modulate:a", 1.0, 0.0)
		tween.tween_property(ring, "scale", Vector2.ONE, RIPPLE_TIME)
		tween.parallel().tween_property(ring, "modulate:a", 0.0, RIPPLE_TIME)
		tween.tween_callback(ring.queue_free)


## An image over rect (global coords), above the arena but under the top bar and panels,
## or just above the floor under the whole arena.
func _add_vfx(texture: Texture2D, rect: Rect2, under_arena := false) -> TextureRect:
	var vfx := TextureRect.new()
	vfx.texture = texture
	vfx.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vfx.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vfx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vfx)
	move_child(vfx, $Margin.get_index() + (0 if under_arena else 1))
	vfx.size = rect.size
	vfx.global_position = rect.position
	return vfx


## Shows texture as a sight wandering over the player's sprite (a figure 8, AIM_DRIFT px out),
## or removes it when texture is null.
func _set_aim(texture: Texture2D) -> void:
	if texture == null:
		if _aim:
			_aim.queue_free()
			_aim = null
		return
	if _aim:
		_aim.texture = texture
		return
	var aim := TextureRect.new()
	aim.texture = texture
	aim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	aim.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	aim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aim.size = AIM_SIZE
	_player_image.add_child(aim)
	var tween := aim.create_tween().set_loops()
	tween.tween_method(func(t: float) -> void:
		aim.position = (_player_image.size - AIM_SIZE) / 2.0 + Vector2(sin(t), sin(2.0 * t) * 0.6) * AIM_DRIFT, 0.0, TAU, AIM_LOOP_TIME)
	_aim = aim


## Brightens a unit's sprite to SPRITE_FLASH and fades it back, as long as the hex flash.
func _flash_sprite(sprite: Control) -> void:
	sprite.self_modulate = SPRITE_FLASH
	sprite.create_tween().tween_property(sprite, "self_modulate", Color.WHITE, HealthGridView.FLASH_TIME)


## Jolts a Vector2 property that rests at ZERO in random directions, smaller each time, then back to ZERO.
func _shake(node: Object, property: String) -> void:
	var step := SHAKE_TIME / (SHAKE_STEPS + 1)
	var tween := create_tween()
	for i in SHAKE_STEPS:
		var amount := SHAKE_AMOUNT * (1.0 - float(i) / SHAKE_STEPS)
		tween.tween_property(node, property, Vector2.from_angle(randf() * TAU) * amount, step)
	tween.tween_property(node, property, Vector2.ZERO, step)


func _sprite_for(unit: CombatUnit) -> UnitImage:
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
	var discard_picking := _picking and selected.pick_from_discard > 0
	_pick_buttons.visible = _picking and not discard_picking
	if _picking:
		var count := _pick_count()
		_confirm_button.disabled = _picked_count() < count
		if selected.pick_tiles > 0:
			_hint_label.text = "Pick %d tile%s of yours to %s. Right-click to cancel." % [count, "" if count == 1 else "s", selected.pick_tile.display_name().to_lower()]
		elif discard_picking:
			_hint_label.text = "Pick %d card%s from your discard pile. Right-click to cancel." % [count, "" if count == 1 else "s"]
		else:
			_hint_label.text = "Pick %d card%s in your hand to exhaust. Right-click to cancel." % [count, "" if count == 1 else "s"]
	elif selected:
		var step := ""
		if selected.clicks(combat.x_energy()) > 1:
			step = " (pattern %d/%d)" % [_cells.size() + 1, selected.clicks(combat.x_energy())]
		if _next_grid_action() is RandomGridAction:
			_hint_label.text = "Click %s%s. Right-click to cancel." % ["your grid" if _targets_player() else "an enemy", step]
		else:
			_hint_label.text = "Click a cell on %s%s. Q/E or scroll to rotate. Right-click to cancel." % ["your grid" if _targets_player() else "the enemy", step]
	else:
		_hint_label.text = "Click a card to select it."

	if discard_picking:
		var count := _pick_count()
		_show_pile("Pick %d card%s to put on top of your draw pile" % [count, "" if count == 1 else "s"], combat.discard_pile, false, true)
	elif _pile_picking:
		_pile_viewer.hide()
	_pile_picking = discard_picking

	_hand.picking = _picking
	if _picking:
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
	_player_view.pick_tile = selected.pick_tile if _picking and selected.pick_tiles > 0 else null
	_player_view.picked = _tile_picks

	# Intents blink on the grid each part targets: attacks on the player, shields on the enemy itself.
	var player_intents: Array = []
	var aim: Texture2D = null
	for i in combat.enemies.size():
		var enemy := combat.enemies[i] as BaseEnemy
		var actions: Array[BaseEnemyAction] = []
		if enemy:
			actions = enemy.intent_actions
		var self_intents: Array = []
		_intent_labels[i].text = "\n".join(PackedStringArray(actions.map(func(a: BaseEnemyAction) -> String: return a.intent_text())))
		for action in actions:
			if action.aim_vfx:
				aim = action.aim_vfx
			for part in action.parts:
				var intent := {cell = part.cell, tiles = part.tiles}
				if part.side == Enum.Side.PLAYER:
					player_intents.append(intent)
				else:
					self_intents.append(intent)
		_enemy_views[i].intents = self_intents
		_enemy_views[i].refresh()
		if enemy:
			_enemy_images[i].modulate = enemy.tint
	_player_view.intents = player_intents
	_set_aim(aim)
	_player_view.refresh()


## The selected card's grid action the next click places, or null.
func _next_grid_action() -> GridAction:
	if selected and _cells.size() < selected.clicks(combat.x_energy()):
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
	_picking = false
	_picks.clear()
	_tile_picks.clear()


## Whether the next click goes on the player's grid: the current grid action's target, or the card's.
func _targets_player() -> bool:
	var target := selected.target
	if _cells.size() < selected.clicks(combat.x_energy()):
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
	_pile_confirm_button.disabled = picking and _picks.size() < _pick_count()
	_close_pile_button.text = "Cancel" if picking else "Close"
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


## The enemy being built, fought in every normal and elite room (and on F6) until it's done.
## null = the usual line-ups.
static var testing: Script = Warewolf

## Each floor's monsters: NORMALS[0] / ELITES[0] are floor 1. Floors past the end reuse the last one.
static var NORMALS: Array = [
	[Slime, Goblin, Vermin, Hound, Ogre, MagicGolem, DarkElf, Griffin],
	[Skeleton, Bat, Zombie, JackOLantern, LilGhost, Mummy, Warewolf],
]
static var ELITES: Array = [[Hydra], [Frangenstein]]


## The floor whose monster lists have script, or 0.
func _floor_of(script: Script) -> int:
	for i in NORMALS.size():
		if script in NORMALS[i] or script in ELITES[i]:
			return i + 1
	return 0


func _enemies_for(room_type: Enum.RoomType) -> Array[CombatUnit]:
	var enemies: Array[CombatUnit] = []
	if room_type == Enum.RoomType.BOSS_COMBAT:
		enemies.append(RunState.floor_boss())
		return enemies
	if testing:
		enemies.append(testing.new())
		return enemies
	var pools: Array = ELITES if room_type == Enum.RoomType.ELITE_COMBAT else NORMALS
	enemies.append(pools[mini(RunState.dungeon_floor, pools.size()) - 1].pick_random().new())
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
	for child in _card_choices.get_children():
		child.queue_free()
	for card in _rewards.cards:
		var slot := _card_slot(card)
		var panel: Control = slot.get_child(0).get_node("Panel")
		panel.gui_input.connect(_on_reward_card_input.bind(card))
		_card_choices.add_child(slot)
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
