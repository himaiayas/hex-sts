extends Control

## Blacksmith: OFFER_COUNT random augments (repeats allowed), each bought with coins and
## applied to a card straight away. An augment no card in the deck can take can't be bought.

const OFFER_COUNT := 4
const OFFER_SIZE := Vector2(280, 380)
const ICON_SIZE := 112.0
const COIN := preload("res://assets/icons/coin.png")

@onready var _top_bar: TopBar = %TopBar
@onready var _hint: Label = %Hint
@onready var _offers: HBoxContainer = %Offers
@onready var _modal = %AugmentModal

var _stock: Array[BaseAugment] = []
var _sold: Array[BaseAugment] = []
var _buying: BaseAugment = null  # bought, waiting for the modal; refunded if it couldn't be used


func _ready() -> void:
	if RunState.deck.is_empty():
		RunState.start_new_run()
	_modal.finished.connect(_on_augment_applied)
	_stock = AugmentPool.random_augments(OFFER_COUNT)
	_refresh()


func _refresh() -> void:
	for child in _offers.get_children():
		_offers.remove_child(child)
		child.queue_free()
	for augment in _stock:
		_offers.add_child(_make_offer(augment))
	_top_bar.refresh()


func _make_offer(augment: BaseAugment) -> Control:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0784314, 0.0862745, 0.109804)
	style.border_color = Color(0.231373, 0.254902, 0.321569)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(20)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = OFFER_SIZE
	panel.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var icon := TextureRect.new()
	icon.texture = augment.icon
	icon.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	box.add_child(icon)
	var title := Label.new()
	title.text = augment.name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 26)
	box.add_child(title)
	var description := Label.new()
	description.text = augment.description
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	description.modulate = Color(0.552941, 0.576471, 0.647059)
	description.add_theme_font_size_override("font_size", 20)
	box.add_child(description)

	var buy := Button.new()
	buy.custom_minimum_size = Vector2(0, 56)
	buy.add_theme_font_size_override("font_size", 26)
	buy.icon = COIN
	buy.expand_icon = true
	buy.add_theme_constant_override("icon_max_width", 32)
	if augment in _sold:
		buy.text = "Sold"
		buy.icon = null
		buy.disabled = true
		panel.modulate = Color(1, 1, 1, 0.45)
	else:
		buy.text = str(augment.price)
		var fits := RunState.deck.any(func(card: BaseCard) -> bool: return augment.can_apply(card))
		buy.disabled = RunState.gold < augment.price or not fits
		if not fits:
			buy.tooltip_text = "No card in your deck can take this."
		elif RunState.gold < augment.price:
			buy.tooltip_text = "Not enough coins."
		buy.pressed.connect(_on_buy_pressed.bind(augment))
	box.add_child(buy)
	return panel


func _on_buy_pressed(augment: BaseAugment) -> void:
	RunState.gold -= augment.price
	_buying = augment
	_top_bar.refresh()
	_modal.open(augment)


func _on_augment_applied(card: BaseCard) -> void:
	if card:
		_sold.append(_buying)
		_hint.text = "%s put on %s." % [_buying.name, card.card_name]
	else:  # nothing could take it after all
		RunState.gold += _buying.price
	_buying = null
	_refresh()


func _on_leave_pressed() -> void:
	RunState.leave_room()
