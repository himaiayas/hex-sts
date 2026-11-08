extends Control

## Blacksmith: OFFER_COUNT random augments (repeats allowed), each bought with coins and
## applied to a card straight away. An augment no card in the deck can take can't be bought.

const OFFER_COUNT := 4
const OFFER_SIZE := Vector2(280, 380)
const ICON_SIZE := 112.0

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
	var fits := RunState.deck.any(func(card: BaseCard) -> bool: return augment.can_apply(card))
	var info := ShopOffer.make_info_column(augment.icon, ICON_SIZE, augment.name, augment.description)
	return ShopOffer.make(OFFER_SIZE, info, RunState.shop_price(augment.price), augment in _sold, _on_buy_pressed.bind(augment),
		"" if fits else "No card in your deck can take this.")


func _on_buy_pressed(augment: BaseAugment) -> void:
	RunState.gold -= RunState.shop_price(augment.price)
	_buying = augment
	_top_bar.refresh()
	_modal.open(augment)


func _on_augment_applied(card: BaseCard) -> void:
	if card:
		_sold.append(_buying)
		_hint.text = "%s put on %s." % [_buying.name, card.card_name]
	else:  # nothing could take it after all
		RunState.gold += RunState.shop_price(_buying.price)
	_buying = null
	_refresh()


func _on_leave_pressed() -> void:
	RunState.leave_room()
