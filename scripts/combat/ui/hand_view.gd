class_name HandView
extends Control

## Lays the hand out as a fan on an arc, like Slay the Spire.
## Hovering a card straightens and enlarges it and pushes its neighbours aside.
## The selected card gets a blue border and bobs up and down.
## Keyword panels show beside the hovered (or else selected) card after a short delay.

signal card_clicked(card: BaseCard)

const RenderCard := preload("res://scripts/cards/render_card.gd")
const CARD_SIZE := Vector2(140, 190)
const CARD_SPACING := 120.0  # distance between card centres
const MAX_HAND_WIDTH := 640.0  # big hands squeeze closer instead of getting wider
const FAN_RADIUS := 1400.0  # radius of the arc the cards sit on
const HOVER_SCALE := 1.4
const HOVER_RAISE := 100.0
const HOVER_PUSH := 50.0
const BOB_HEIGHT := 4
const BOB_PERIOD := 1.2  # seconds per bob
const SPEED := 14.0  # how fast cards ease toward their target
const KEYWORD_DELAY := 0.5  # seconds before keyword panels show
const KEYWORD_WIDTH := 180.0
const KEYWORD_GAP := 8.0

const COLOR_BORDER := Color(0.85098, 0.764706, 0.54902)
const COLOR_SELECTED := Color("#4fa8ff")
const COLOR_UNPLAYABLE := Color(0.55, 0.55, 0.55)
const COLOR_KEYWORD_BG := Color(0.08, 0.08, 0.1, 0.92)

var _cards: Array[BaseCard] = []
var _holders: Dictionary[BaseCard, Node2D] = {}  # pivot at the card's bottom centre
var _selected: BaseCard = null
var _hovered := -1

var _keyword_box := VBoxContainer.new()
var _keyword_card: BaseCard = null  # card the panels are counting down for or showing
var _keyword_timer := 0.0


func _ready() -> void:
	_keyword_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_keyword_box.hide()
	add_child(_keyword_box)


## Keeps existing card nodes so they animate to their new spot instead of being rebuilt.
func set_hand(cards: Array[BaseCard], selected: BaseCard, can_play: Callable) -> void:
	for card in _holders.keys():
		if card not in cards:
			var old := _holders[card]
			remove_child(old)
			old.queue_free()
			_holders.erase(card)

	for card in cards:
		if not _holders.has(card):
			var view := RenderCard.create_card(card)
			view.position = -CARD_SIZE * Vector2(0.5, 1)
			view.get_node("Panel").mouse_filter = Control.MOUSE_FILTER_IGNORE
			var holder := Node2D.new()
			holder.position = Vector2(0, size.y + CARD_SIZE.y)  # slide in from the draw pile side
			holder.add_child(view)
			add_child(holder)
			_holders[card] = holder
		_holders[card].modulate = Color.WHITE if can_play.call(card) else COLOR_UNPLAYABLE
		_set_border(card, card == selected)

	_cards = cards.duplicate()
	_selected = selected
	_hovered = -1
	_update_order()


func _process(delta: float) -> void:
	var hovered := _card_under_mouse()
	if hovered != _hovered:
		_hovered = hovered
		_update_order()

	var weight := 1.0 - exp(-SPEED * delta)
	for i in _cards.size():
		var holder := _holders[_cards[i]]
		var target := _target_for(i)
		holder.position = holder.position.lerp(target.origin, weight)
		holder.rotation = lerp_angle(holder.rotation, target.get_rotation(), weight)
		holder.scale = holder.scale.lerp(target.get_scale(), weight)

	_update_keywords(delta)


## Uses _input because an enlarged card sticks out above this control.
func _input(event: InputEvent) -> void:
	if _hovered == -1:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		card_clicked.emit(_cards[_hovered])


func _target_for(i: int) -> Transform2D:
	var half := (_cards.size() - 1) / 2.0
	var angle := (i - half) * _spacing() / FAN_RADIUS
	var edge_angle := half * _spacing() / FAN_RADIUS
	# Outer cards drop along the arc; the whole fan is lifted so the outermost ones sit on the bottom edge.
	var pos := Vector2(size.x / 2 + FAN_RADIUS * sin(angle), size.y + FAN_RADIUS * (cos(edge_angle) - cos(angle)))
	var card_scale := 1.0
	var bob := 0.0
	if _cards[i] == _selected:
		bob = BOB_HEIGHT * sin(TAU * Time.get_ticks_msec() / 1000.0 / BOB_PERIOD)

	# The selected card keeps its hovered look after the mouse leaves it.
	if i == _hovered or _cards[i] == _selected:
		angle = 0.0
		card_scale = HOVER_SCALE
		pos.y = size.y - HOVER_RAISE + bob
	var focus := _hovered
	if focus == -1 and _selected:
		focus = _cards.find(_selected)
	if focus != -1 and i != focus:
		pos.x += HOVER_PUSH * signf(i - focus)
	return Transform2D(angle, Vector2.ONE * card_scale, 0.0, pos)


func _spacing() -> float:
	if _cards.size() < 2:
		return 0.0
	return minf(CARD_SPACING, MAX_HAND_WIDTH / (_cards.size() - 1))


## Picks the closest slot by x so overlapping, rotated cards don't flicker.
func _card_under_mouse() -> int:
	if _cards.is_empty():
		return -1
	var mouse := get_local_mouse_position()
	var top := 0.0
	if _hovered != -1:
		top = size.y - CARD_SIZE.y * HOVER_SCALE - HOVER_RAISE  # keep hover while on the enlarged card
	elif get_viewport().gui_get_hovered_control() != self:
		return -1
	if mouse.y < top or mouse.y > size.y:
		return -1

	var half := (_cards.size() - 1) / 2.0
	var spacing := _spacing()
	var i := 0
	if spacing > 0.0:
		i = clampi(roundi((mouse.x - size.x / 2) / spacing + half), 0, _cards.size() - 1)
	var centre := size.x / 2 + (i - half) * spacing
	if absf(mouse.x - centre) > CARD_SIZE.x / 2:
		return -1
	return i


## Draw order: hand order, then the selected card, then the hovered one on top.
func _update_order() -> void:
	for i in _cards.size():
		move_child(_holders[_cards[i]], i)
	if _selected and _holders.has(_selected):
		move_child(_holders[_selected], -1)
	if _hovered != -1:
		move_child(_holders[_cards[_hovered]], -1)
	move_child(_keyword_box, -1)


func _set_border(card: BaseCard, selected: bool) -> void:
	var panel: PanelContainer = _holders[card].get_child(0).get_node("Panel")
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
	style.border_color = COLOR_SELECTED if selected else COLOR_BORDER
	style.set_border_width_all(5 if selected else 3)


func _update_keywords(delta: float) -> void:
	var card: BaseCard = _cards[_hovered] if _hovered != -1 else _selected
	if card != _keyword_card:
		_keyword_card = card
		_keyword_timer = KEYWORD_DELAY
		_keyword_box.hide()
	elif card:
		_keyword_timer -= delta
		if _keyword_timer <= 0.0 and _keyword_timer > -INF:
			_keyword_timer = -INF  # build the panels once per card
			_show_keywords(card)

	if _keyword_box.visible:
		# Follow the card as it animates; flip to the left side near the right edge.
		var holder := _holders[_keyword_card]
		var half_width := CARD_SIZE.x * holder.scale.x / 2
		var x := holder.position.x + half_width + KEYWORD_GAP
		if x + KEYWORD_WIDTH > size.x:
			x = holder.position.x - half_width - KEYWORD_GAP - KEYWORD_WIDTH
		_keyword_box.position = Vector2(x, holder.position.y - CARD_SIZE.y * holder.scale.y)


func _show_keywords(card: BaseCard) -> void:
	for child in _keyword_box.get_children():
		_keyword_box.remove_child(child)
		child.queue_free()
	for keyword in RenderCard.keywords_in(card.get_description()):
		var text := Keywords.describe(keyword)
		if text.is_empty():
			continue
		var style := StyleBoxFlat.new()
		style.bg_color = COLOR_KEYWORD_BG
		style.border_color = COLOR_BORDER
		style.set_border_width_all(1)
		style.set_corner_radius_all(6)
		style.set_content_margin_all(8)
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", style)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var rows := VBoxContainer.new()
		var title := Label.new()
		title.text = keyword
		title.add_theme_color_override("font_color", RenderCard.COLOR_KEYWORD)
		var body := Label.new()
		body.text = text
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.custom_minimum_size.x = KEYWORD_WIDTH - 16
		body.add_theme_font_size_override("font_size", 13)
		rows.add_child(title)
		rows.add_child(body)
		panel.add_child(rows)
		_keyword_box.add_child(panel)
	_keyword_box.reset_size()
	_keyword_box.visible = _keyword_box.get_child_count() > 0
