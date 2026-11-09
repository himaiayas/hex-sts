extends Control

## Blacksmith: OFFER_COUNT random augments (repeats allowed), each bought with coins and
## applied to a card straight away. An augment no card in the deck can take can't be bought.
## The stock is kept on the room (MapRoom.stock), so walking back in shows the same augments.

const OFFER_COUNT := 4
const OFFER_SIZE := Vector2(280, 380)
const ICON_SIZE := 112.0

@onready var _top_bar: TopBar = %TopBar
@onready var _hint: Label = %Hint
@onready var _offers: HBoxContainer = %Offers
@onready var _modal = %AugmentModal

var _stock: Array[BaseAugment] = []
var _sold: Array[BaseAugment] = []
var _hover_info := HoverInfo.new()  # keyword panels of the augment under the mouse
var _buying: BaseAugment = null  # bought, waiting for the modal; refunded if it couldn't be used


func _ready() -> void:
	if RunState.deck.is_empty():
		RunState.start_new_run()
	_modal.finished.connect(_on_augment_applied)
	_hover_info.is_blocked = func() -> bool: return _top_bar.is_modal_open() or _modal.visible
	add_child(_hover_info)
	var room := RunState.current_room
	if room and room.stock.has("augments"):  # been here before
		_stock.assign(room.stock.augments)
		for i: int in room.stock.sold:
			_sold.append(_stock[i])
	else:
		_stock = AugmentPool.random_augments(OFFER_COUNT)
	_store_stock()
	_refresh()


## Keeps the offers and what's sold on the room for the next visit (sold as indexes, so it survives saving).
func _store_stock() -> void:
	var room := RunState.current_room
	if room:
		room.stock = {augments = _stock, sold = range(_stock.size()).filter(func(i: int) -> bool: return _stock[i] in _sold)}


func _refresh() -> void:
	_hover_info.clear()
	for child in _offers.get_children():
		_offers.remove_child(child)
		child.queue_free()
	for augment in _stock:
		var offer := _make_offer(augment)
		_offers.add_child(offer)
		_hover_info.add(offer, augment.keyword_entries(), true)
	_top_bar.refresh()


func _make_offer(augment: BaseAugment) -> Control:
	var fits := RunState.deck.any(func(card: BaseCard) -> bool: return augment.can_apply(card))
	var info := ShopOffer.make_info_column(augment.icon, ICON_SIZE, augment.name, augment.description)
	return ShopOffer.make(OFFER_SIZE, info, RunState.shop_price(augment.price), augment in _sold, _on_buy_pressed.bind(augment),
		"" if fits else "No card in your deck can take this.")


func _on_buy_pressed(augment: BaseAugment) -> void:
	Sfx.play("coins")
	RunState.gold -= RunState.shop_price(augment.price)
	_buying = augment
	_top_bar.refresh()
	_modal.open(augment)


func _on_augment_applied(card: BaseCard) -> void:
	if card:
		_sold.append(_buying)
		_store_stock()
		_hint.text = "%s put on %s." % [_buying.name, card.card_name]
	else:  # nothing could take it after all
		RunState.gold += RunState.shop_price(_buying.price)
	_buying = null
	_refresh()


func _on_leave_pressed() -> void:
	RunState.leave_room()
