extends Control

## Combat screen: hand, piles, energy, end turn, and health grids.
## Click a card to select it, then click a cell for each of its grid actions to play it.
## A card with no grid actions is played by dragging it to the middle of the screen.
## A card that has the player pick cards (from hand or the discard pile) asks while it resolves
## (CombatState.chooser): the player picks them and presses Confirm. There's no cancelling then.
## Picking from the discard pile happens in the pile viewer.

const RenderCard := preload("res://scripts/cards/render_card.gd")
const CARD_SIZE := HandView.CARD_SIZE
const LUNGE_DISTANCE := 40.0  # px toward the target
const VFX_SCALE := 1.25  # an enemy move's hit image, relative to its area
const RIPPLES := 3
const RIPPLE_GAP := 0.2  # seconds between rings
const RIPPLE_TIME := 1.0  # each ring, from RIPPLE_START to full size
const RIPPLE_START := 0.3
const RIPPLE_WIDTH := 1800.0  # px, a ring at full size
const AIM_SIZE := Vector2(200, 200)
const AIM_DRIFT := 30.0  # px the sight wanders from the middle of the player's sprite
const AIM_LOOP_TIME := 3.0
const LUNGE_TIME := 0.06  # out to the target; the hit flashes when it gets there
const LUNGE_BACK_TIME := 0.1
const SHAKE_AMOUNT := 8.0  # px, the first jolt; later ones get smaller
const SHAKE_STEPS := 6
const SHAKE_TIME := 0.15
const PROJECTILE_WIDTH := 200.0  # px; its height keeps the texture's aspect
const PROJECTILE_SPEED := 2400.0  # px per second, steady
const SPRITE_FLASH := Color(2.5, 2.5, 2.5)  # a sprite's brightest, fading back over the hex flash
const INTENT_ICON_SIZE := 36.0  # px, the type icons in front of each intent row

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
signal _relocated(cell: Vector2i)
var _relocating := {}  # the enemy part Taunt lets the player move (see CombatState.relocator); empty if none

var _enemy_views: Array[HealthGridView] = []
var _enemy_images: Array[UnitImage] = []  # one per enemy, same order as _enemy_views
var _intent_boxes: Array[VBoxContainer] = []  # one row per planned move: type icons, name and hits
var _aim: TextureRect  # an enemy's sight on the player's sprite, while a move with aim_vfx is in its intent

@onready var _top_bar: TopBar = %TopBar
@onready var _floor_background: TextureRect = %FloorBackground
var _hover_info := HoverInfo.new()  # keywords of cards in the pile viewer and card rewards
var _intent_info := HoverInfo.new()  # each intent row's description; not _hover_info, which the pile viewer clears
@onready var _end_turn_button: Button = %EndTurnButton
@onready var _energy_label: Label = %EnergyLabel
@onready var _hint_label: Label = %HintLabel
@onready var _player_view: HealthGridView = %PlayerGrid
@onready var _player_image: UnitImage = %PlayerImage
@onready var _enemies_box: HBoxContainer = %Enemies
@onready var _arena: HBoxContainer = $Margin/Layout/Arena
@onready var _player_side: HBoxContainer = $Margin/Layout/Arena/Player
@onready var _hand: HandView = %Hand
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
@onready var _artifact_button: Button = %ArtifactRewardButton
@onready var _card_choice_panel: Control = %CardChoicePanel
@onready var _card_choices: HBoxContainer = %CardChoices
@onready var _defeat_panel: Control = %DefeatPanel

var _rewards: CombatRewards
var _over := false  # won or lost: ignore combat input
var _busy := false  # a card or a turn is playing out: ignore combat input until it's done
var _hovered_enemy := -1  # index in combat.enemies under the mouse: only its intents show at full strength


func _ready() -> void:
	if RunState.deck.is_empty():
		RunState.start_new_run()
	_floor_background.texture = RunState.combat_background()
	if testing and _room_type() != Enum.RoomType.BOSS_COMBAT and _floor_of(testing) > 0:
		_floor_background.texture = RunState.FLOOR_COMBAT_BACKGROUNDS[_floor_of(testing) - 1].pick_random()  # the test monster's floor
	if RunState.BACKGROUND_FLICKERS.has(_floor_background.texture):
		_flicker_lights(_floor_background.texture, RunState.BACKGROUND_FLICKERS[_floor_background.texture])
	_hover_info.is_blocked = _top_bar.is_modal_open
	add_child(_hover_info)
	_intent_info.is_blocked = func() -> bool: return _top_bar.is_modal_open() or _pile_viewer.visible or _over
	add_child(_intent_info)
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
	_fit_enemies()

	combat.animator = _animate
	combat.chooser = _choose
	combat.relocator = _relocate
	combat.reshuffled.connect(Sfx.play.bind("shuffle"))
	combat.card_exhausted.connect(func(_card: BaseCard) -> void: Sfx.play("exhaust"))
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
	var intent_box := VBoxContainer.new()
	intent_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.add_child(intent_box)
	intent_box.anchor_top = 1.0
	intent_box.anchor_bottom = 1.0
	intent_box.grow_vertical = Control.GROW_DIRECTION_END  # placed sideways by _place_intents
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
	_intent_boxes.insert(i, intent_box)


func _process(_delta: float) -> void:
	_place_intents()


## Every frame, since grids move as enemies spawn and shrink: each intent list is centred under
## its grid, as wide as the grid or its widest row, but stays NAME_SCREEN_MARGIN inside the screen
## (a Mini Slime's grid is narrower than "Tiny Splat 2").
func _place_intents() -> void:
	var margin := HealthGridView.NAME_SCREEN_MARGIN
	var screen := get_viewport_rect().size.x
	for box in _intent_boxes:
		var view := box.get_parent() as Control
		var width := maxf(box.get_combined_minimum_size().x, view.size.x)
		var x := (view.size.x - width) / 2.0
		box.position.x = clampf(x, margin - view.global_position.x, screen - margin - view.global_position.x - width)
		box.size.x = width


## One row per move under an enemy's grid: its type icons, name and hits ("Gnaw 3x2"),
## each with its own hover panel.
func _set_intent_rows(box: VBoxContainer, actions: Array[BaseEnemyAction]) -> void:
	for row in box.get_children():
		_intent_info.add(row, [])  # forget it before it's freed
		box.remove_child(row)
		row.queue_free()
	for action in actions:
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 6)
		var icons := action.intent_icons()
		if not icons.is_empty():
			row.add_child(HoverInfo.icon_row(icons, INTENT_ICON_SIZE))
		var label := Label.new()
		label.text = (action.intent_text() + " " + action.hit_text()).strip_edges()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(label)
		box.add_child(row)
		if not action.description.is_empty():
			_intent_info.add(row, [[action.intent_text(), action.description, icons]], false, null, true)


## Forever: every 2-5 s the lights flicker 1-3 times, each a quick flash of the flicker image.
func _flicker_lights(lit: Texture2D, flicker: Texture2D) -> void:
	while true:
		await get_tree().create_timer(randf_range(2.0, 5.0)).timeout
		for i in randi_range(1, 3):
			_floor_background.texture = flicker
			await get_tree().create_timer(randf_range(0.06, 0.12)).timeout
			_floor_background.texture = lit
			await get_tree().create_timer(randf_range(0.05, 0.15)).timeout


## Which enemy's sprite or grid is under the mouse; the others' intents on the player's grid fade.
func _update_hovered_enemy() -> void:
	var hovered := -1
	for i in _enemy_views.size():
		var side := _enemy_views[i].get_parent() as Control
		if side.visible and side.get_global_rect().has_point(get_global_mouse_position()):
			hovered = i
	if hovered != _hovered_enemy:
		_hovered_enemy = hovered
		_refresh()


## Shrinks the enemies' grids and sprites by the same factor until the row fits beside the player's side,
## so a crowded fight (summons, Split) never pushes anything off screen. Enemies with shrinks = false
## (the Lich) keep their size.
func _fit_enemies() -> void:
	var margin: MarginContainer = $Margin
	var room := get_viewport_rect().size.x - margin.get_theme_constant("margin_left") - margin.get_theme_constant("margin_right") \
		- _player_side.get_combined_minimum_size().x - 2 * _arena.get_theme_constant("separation")
	var factor := 1.0
	for attempt in 8:  # the grids' padding doesn't scale, so close in over a few tries
		var widths := _enemies_width(factor)  # fixed, shrinking
		if widths.x + widths.y <= room or widths.y <= 0.0:
			break
		factor *= maxf(0.1, (room - widths.x) / widths.y) * 0.98


## The enemy row's width with the shrinking grids and sprites at factor of their own size:
## x = the part that doesn't shrink (fixed enemies, gaps), y = the part that does.
func _enemies_width(factor: float) -> Vector2:
	var widths := Vector2.ZERO
	var shown := 0
	for i in combat.enemies.size():
		var enemy := combat.enemies[i] as BaseEnemy
		var view := _enemy_views[i]
		var slot := _enemy_images[i].get_parent() as Control
		var f := factor if enemy.shrinks else 1.0
		view.scale_factor = enemy.grid_scale * f
		view.refresh()
		slot.custom_minimum_size = enemy.image_size * f
		var side := view.get_parent() as HBoxContainer
		if not side.visible:
			continue
		var width := slot.custom_minimum_size.x + view.custom_minimum_size.x
		if enemy.shrinks:
			widths.y += width
		else:
			widths.x += width
		widths.x += side.get_theme_constant("separation")
		shown += 1
	widths.x += maxi(0, shown - 1) * _enemies_box.get_theme_constant("separation")
	return widths


## A spawned enemy appears with a flash, in in_place_of's place if it has one.
func _on_enemy_spawned(enemy: CombatUnit, in_place_of: CombatUnit) -> void:
	_add_enemy(enemy)
	if in_place_of:
		_view_for(in_place_of).get_parent().hide()
	_fit_enemies()
	_flash_sprite(_sprite_for(enemy))


# --- Input -------------------------------------------------------------------

func _on_card_clicked(card: BaseCard) -> void:
	if not _choice.is_empty():
		_toggle_pick(card)
		return
	if _over or _busy:
		return
	if selected == card:
		_select(null)
		Sfx.play("card_select")
	elif not combat.can_play(card):
		_hint_label.text = _unplayable_hint(card)
		Sfx.play("error")
		return
	elif card.grid_actions.is_empty():
		_hint_label.text = "Drag it to the middle of the screen to play."
		return
	else:
		_select(card)
		Sfx.play("card_select")
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
		_hint_label.text = _unplayable_hint(card)
		Sfx.play("error")
		_refresh()
		return
	_select(card)
	_play_selected()


func _on_cell_clicked(unit: CombatUnit, cell: Vector2i) -> void:
	if not _relocating.is_empty():
		_place_relocated(unit, cell)
		return
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
		Sfx.play("error")
		return
	_units.append(unit)
	_cells.append(cell)
	_rotations.append(_rotation)
	if _cells.size() < selected.clicks(combat.x_energy()): #store intents in _cells, when all grid has been chosen, this condition reeturn false
		_refresh()
		return
	_play_selected()


func _on_confirm_pressed() -> void:
	if not _relocating.is_empty():
		_relocated.emit(_relocating.part.cell)  # keep it where it is
		return
	if not _choice.is_empty() and _picked_count() >= _choice.min:
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


## combat.relocator: the player clicks their grid to move the part there, or Confirm to keep it.
func _relocate(request: Dictionary) -> Vector2i:
	_relocating = request
	_refresh()
	var cell: Vector2i = await _relocated
	_relocating = {}
	_refresh()
	return cell


func _place_relocated(unit: CombatUnit, cell: Vector2i) -> void:
	if unit != combat.player:
		_hint_label.text = "Move the attack on your own grid."
		return
	if combat.part_hits(_relocating.part, cell) < _relocating.min_hits:
		_hint_label.text = "It must still hit at least %d tiles." % _relocating.min_hits
		return
	_relocated.emit(cell)


func _toggle_pick(card: BaseCard) -> void:
	if _choice.is_empty() or card not in _choice.cards:
		return
	if card in _picks:
		_picks.erase(card)
	elif _picks.size() < _choice.count:
		_picks.append(card)
	_refresh()


const PLAY_SOUNDS := {
	Enum.CardType.ATTACK: "play_attack",
	Enum.CardType.DEFENSE: "play_defense",
	Enum.CardType.SKILL: "play_skill",
	Enum.CardType.POWER: "play_power",
}


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
		_player_image.show_pose(UnitImage.PLAYER_ATTACK)
	Sfx.play(PLAY_SOUNDS[card.type])
	await combat.play_card(card, units, cells, rotations)
	_busy = false
	_refresh()
	_check_combat_end()
	if combat.end_turn_requested:  # Chronokinesis
		combat.end_turn_requested = false
		_on_end_turn_pressed()


func _picked_count() -> int:
	return _picks.size()


func _on_end_turn_pressed() -> void:
	if _over or _busy:
		return
	_select(null)
	_refresh()
	_busy = true
	if not combat.hand.is_empty():
		Sfx.play("card_discard")
	await combat.end_turn()
	_busy = false
	_refresh()
	_check_combat_end()
	if not _over:
		Sfx.play("turn_start")


## Only enemy hits count, not the player's own Poison at turn start.
func _on_player_blocked(_coords: Vector2i) -> void:
	if not combat.player.in_turn:
		_player_image.show_pose(UnitImage.PLAYER_GUARD)


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
	if event is InputEventMouseMotion:
		_update_hovered_enemy()
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
		_rotation = _rotation - _rotation % 6 + posmod(_rotation % 6 + _rotation_step(event), 6)  # keeps the flip
		_refresh()
		get_viewport().set_input_as_handled()
	elif selected and _choice.is_empty() and not _pile_viewer.visible and RunState.has_artifact(Mirror) \
			and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F:
		_rotation = (_rotation + 6) % 12  # Mirror: flip the pattern
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
		if action and action.heavy_impact:
			Sfx.play("boss_boom")
			Sfx.play("boss_crash")
	if action and action.ripple_vfx and batch.any(func(c: Dictionary) -> bool: return c.unit == attacker):
		_ripple(action.ripple_vfx, _center(_sprite_for(attacker)))
	for change in batch:
		_view_for(change.unit).flash(change.cell, change.kind, change.effect)
		if change.effect is MultiHeadPower or change.effect is RisePower:  # a Hydra head was cut, a Zombie rose
			_flash_sprite(_sprite_for(change.unit))
	_play_batch_sounds(batch)
	for unit in damaged:
		if unit == combat.player:
			_shake(_player_view, "shake")
		else:
			_shake(_sprite_for(unit), "position")
	await get_tree().create_timer(HealthGridView.FLASH_TIME).timeout
	_hide_departed()


## One sound per kind of change in the batch, as its flashes start.
func _play_batch_sounds(batch: Array[Dictionary]) -> void:
	var heard := {}
	for change in batch:
		var event := ""
		match change.kind:
			Enum.Change.DAMAGE:
				event = "hit_player" if change.unit == combat.player else "hit"
			Enum.Change.BLOCK:
				event = "block"
			Enum.Change.SHIELD:
				event = "shield"
			Enum.Change.HEAL:
				event = "heal"
			Enum.Change.EFFECT, Enum.Change.POWER:
				var debuff: bool = change.effect is BaseTileEffect and change.effect.debuff
				event = "debuff" if debuff else "buff"
		if not event.is_empty() and not heard.has(event):
			heard[event] = true
			Sfx.play(event)


## Takes enemies with leaves_when_dead off the screen once they're dead (the Mimic), after their last
## hit has played. They stay in combat.enemies, dead, so the views keep their order.
func _hide_departed() -> void:
	var changed := false
	for i in combat.enemies.size():
		var enemy := combat.enemies[i] as BaseEnemy
		var side := _enemy_views[i].get_parent() as Control
		if enemy and enemy.leaves_when_dead and enemy.is_dead() and side.visible:
			side.hide()
			changed = true
	if changed:
		_fit_enemies()


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
	_end_turn_button.text = "End Turn %d" % combat.turn
	_energy_label.text = "Energy %d/%d" % [combat.energy, combat.max_energy]
	_draw_button.text = "Draw pile (%d)" % combat.draw_pile.size()
	_exhaust_button.text = "Exhaust (%d)" % combat.exhaust_pile.size()
	_discard_button.text = "Discard (%d)" % combat.discard_pile.size()
	var choosing := not _choice.is_empty()
	var discard_picking: bool = choosing and not _choice.in_hand
	var hand_picking: bool = choosing and _choice.in_hand
	var relocating := not _relocating.is_empty()
	_pick_buttons.visible = (choosing and not discard_picking) or relocating
	if relocating:
		_confirm_button.disabled = false
		_hint_label.text = "Taunt: click your grid to move this attack (it must hit at least %d tiles). Confirm keeps it there." % _relocating.min_hits
	elif choosing:
		_confirm_button.disabled = _picked_count() < _choice.min
		_hint_label.text = _choice.prompt
	elif selected:
		var step := ""
		if selected.clicks(combat.x_energy()) > 1:
			step = " (pattern %d/%d)" % [_cells.size() + 1, selected.clicks(combat.x_energy())]
		if _next_grid_action() is RandomGridAction:
			_hint_label.text = "Click %s%s. Right-click to cancel." % ["your grid" if _targets_player() else "an enemy", step]
		else:
			_hint_label.text = "Click a cell on %s%s. Q/E or scroll to rotate%s. Right-click to cancel." % ["your grid" if _targets_player() else "the enemy", step,
				", F to flip" if RunState.has_artifact(Mirror) else ""]
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
	if relocating:  # the part being moved follows the cursor
		var moving: Dictionary[Vector2i, BaseActionTile] = {}
		for t: BaseActionTile in _relocating.part.tiles:
			moving[t.coords] = t
		_player_view.preview = moving

	# Grid actions already clicked flicker where they will land.
	for view in _enemy_views:
		view.placed = []
	_player_view.placed = []
	for i in _cells.size():
		_view_for(_units[i]).placed.append({cell = _cells[i], tiles = selected.grid_action(i).rotated(_rotations[i])})

	# Intents blink on the grid each part targets: attacks on the player, shields on the enemy itself.
	var player_intents: Array = []
	var aim: Texture2D = null
	for i in combat.enemies.size():
		var enemy := combat.enemies[i] as BaseEnemy
		var actions: Array[BaseEnemyAction] = []
		if enemy:
			actions = enemy.intent_actions
		var self_intents: Array = []
		_set_intent_rows(_intent_boxes[i], actions)
		for action in actions:
			if action.aim_vfx:
				aim = action.aim_vfx
			for part in action.parts:
				var intent := {cell = part.cell, tiles = part.tiles, faded = _hovered_enemy != -1 and _hovered_enemy != i, later = false}
				if action.action_type == Enum.BaseEnemyActionEnum.WIND_UP:
					intent.faded = true  # a wind-up or Charge: it lands on a later turn, not this one
					intent.later = true
				if part.side == Enum.Side.PLAYER:
					if relocating and part == _relocating.part:
						intent.faded = true  # where it is now, while the preview shows where it would go
					player_intents.append(intent)
				else:
					self_intents.append(intent)
		_enemy_views[i].intents = self_intents
		_enemy_views[i].refresh()
		if enemy and not enemy.idle_frames.is_empty():
			_enemy_images[i].idle_frames = enemy.idle_frames  # it can change form (the Werewolf)
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
	_pile_confirm_button.disabled = picking and _picks.size() < _choice.min
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


## The enemy being built, fought in every normal and elite room (and on F6) until it's done.
## null = the usual line-ups.
static var testing: Script = null

## Each floor's monsters: NORMALS[0] / ELITES[0] are floor 1. Floors past the end reuse the last one.
static var NORMALS: Array = [
	[Slime, Goblin, Vermin, Hound, Ogre, MagicGolem, DarkElf, Griffin],
	[Skeleton, Bat, Zombie, JackOLantern, LilGhost, Mummy, Werewolf],
	[ScoutDrone, CleanerBot, CyberHound, PlasmaTurret, AndroidSentinel, NanoSwarm, HackerAI],
]
static var ELITES: Array = [[Hydra], [Frangenstein, Lich], [MechWalker, Terminator]]
## The first EASY_FIGHTS normal fights of each floor only use EASY_NORMALS[floor - 1]
## (picked as the smallest monsters by tile count; edit freely).
static var EASY_NORMALS: Array = [
	[Slime, Vermin, Goblin],
	[Bat, LilGhost, Skeleton],
	[ScoutDrone, PlasmaTurret, CleanerBot],
]
const EASY_FIGHTS := 2
## Each earlier fight with a monster this run multiplies its chance by this (RunState.fought).
const REPEAT_WEIGHT := 0.25


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
		enemies.append_array(enemies[0].companions)
		return enemies
	var pools: Array = NORMALS
	if room_type == Enum.RoomType.ELITE_COMBAT:
		pools = ELITES
	elif RunState.normal_fights_on_floor < EASY_FIGHTS:
		pools = EASY_NORMALS
	if room_type != Enum.RoomType.ELITE_COMBAT:
		RunState.normal_fights_on_floor += 1
	var script := _pick_monster(pools[mini(RunState.dungeon_floor, pools.size()) - 1])
	RunState.fought[script] = RunState.fought.get(script, 0) + 1
	enemies.append(script.new())
	enemies.append_array(enemies[0].companions)
	return enemies


## A random monster from pool, each weighted REPEAT_WEIGHT ^ (times fought this run).
static func _pick_monster(pool: Array) -> Script:
	var weights: Array[float] = []
	var total := 0.0
	for script: Script in pool:
		var weight := pow(REPEAT_WEIGHT, RunState.fought.get(script, 0))
		weights.append(weight)
		total += weight
	var roll := randf() * total
	for i in pool.size():
		roll -= weights[i]
		if roll < 0.0:
			return pool[i]
	return pool.back()  # float rounding


func _check_combat_end() -> void:
	if _over:
		return
	if combat.is_lost():
		_end_combat()
		Sfx.play("lose")
		SaveGame.delete()  # the run is over
		_defeat_panel.show()
	elif combat.is_won():
		_end_combat()
		Sfx.play("win")
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
	_artifact_button.visible = _rewards.artifact != null and not _rewards.artifact_taken
	if _rewards.artifact:
		_artifact_button.text = _rewards.artifact.name
		_artifact_button.tooltip_text = _rewards.artifact.plain_description()
		_artifact_button.icon = _rewards.artifact.image


func _on_artifact_reward_pressed() -> void:
	_rewards.take_artifact(RunState)
	_refresh_rewards()


func _on_gold_reward_pressed() -> void:
	Sfx.play("coins")
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
		Sfx.play("card_select")
		_rewards.take_card(RunState, card)
		_card_choice_panel.hide()
		_refresh_rewards()


func _on_skip_card_pressed() -> void:
	_rewards.take_card(RunState, null)
	_card_choice_panel.hide()
	_refresh_rewards()


func _on_card_choice_back_pressed() -> void:
	_card_choice_panel.hide()


## Coins, EXP and a boss's artifact left on the table are collected on the way out; an unpicked card is lost.
func _on_continue_pressed() -> void:
	_rewards.take_gold(RunState)
	_rewards.take_exp(RunState)
	_rewards.take_artifact(RunState)
	RunState.leave_room()


func _on_new_run_pressed() -> void:
	RunState.start_new_run()
	get_tree().change_scene_to_file(RunState.MAP_SCENE)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(RunState.MENU_SCENE)


func _unplayable_hint(card: BaseCard) -> String:
	if not combat.can_afford(card):
		return "Not enough energy."
	return "Can't play this right now."
