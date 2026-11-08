extends Control

## Merchant: CARD_COUNT random cards and ARTIFACT_COUNT random artifacts, bought with coins.
## Prices depend on rarity; tune them here.

const RenderCard := preload("res://scripts/cards/render_card.gd")

const CARD_COUNT := 6
const ARTIFACT_COUNT := 3
const ARTIFACT_OFFER_SIZE := Vector2(360, 0)
const ARTIFACT_ICON_SIZE := 96.0

const CARD_PRICES := {
	Enum.CardRarity.COMMON: 30,
	Enum.CardRarity.UNCOMMON: 45,
	Enum.CardRarity.RARE: 70,
	Enum.CardRarity.LEGENDARY: 110,
}
const ARTIFACT_PRICES := {
	Enum.ArtifactRarity.COMMON: 60,
	Enum.ArtifactRarity.UNCOMMON: 90,
	Enum.ArtifactRarity.RARE: 140,
	Enum.ArtifactRarity.LEGENDARY: 220,
}

@onready var _top_bar: TopBar = %TopBar
@onready var _hint: Label = %Hint
@onready var _card_offers: HBoxContainer = %CardOffers
@onready var _artifact_offers: HBoxContainer = %ArtifactOffers

var _cards: Array[BaseCard] = []
var _artifacts: Array[BaseArtifact] = []
var _sold: Array[Resource] = []
var _hover_info := HoverInfo.new()


func _ready() -> void:
	if RunState.deck.is_empty():
		RunState.start_new_run()
	_hover_info.is_blocked = _top_bar.is_modal_open
	add_child(_hover_info)
	_cards = CardPool.random_cards(CARD_COUNT)
	_artifacts = ArtifactPool.random_artifacts(ARTIFACT_COUNT, RunState.artifacts)
	_refresh()


func _refresh() -> void:
	_hover_info.clear()
	for row in [_card_offers, _artifact_offers]:
		for child in row.get_children():
			row.remove_child(child)
			child.queue_free()
	for card in _cards:
		var card_offer := ShopOffer.make(RenderCard.CARD_SIZE, _make_card_slot(card), RunState.shop_price(CARD_PRICES[card.rarity]),
			card in _sold, _on_card_bought.bind(card))
		_hover_info.add_card(card_offer, card)
		_card_offers.add_child(card_offer)
	for artifact in _artifacts:
		var info := ShopOffer.make_name_row(artifact.image, ARTIFACT_ICON_SIZE, artifact.name)
		var offer := ShopOffer.make(ARTIFACT_OFFER_SIZE, info, RunState.shop_price(ARTIFACT_PRICES[artifact.rarity]),
			artifact in _sold, _on_artifact_bought.bind(artifact))
		_hover_info.add(offer, [[artifact.name, artifact.description]], true)
		_artifact_offers.add_child(offer)
	_top_bar.refresh()


func _make_card_slot(card: BaseCard) -> Control:
	var slot := Control.new()
	slot.custom_minimum_size = RenderCard.CARD_SIZE
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var view := RenderCard.create_card(card)
	view.get_node("Panel").mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(view)
	return slot


func _on_card_bought(card: BaseCard) -> void:
	RunState.gold -= RunState.shop_price(CARD_PRICES[card.rarity])
	RunState.deck.append(card)
	_sell(card, "%s added to your deck." % card.card_name)


func _on_artifact_bought(artifact: BaseArtifact) -> void:
	RunState.gold -= RunState.shop_price(ARTIFACT_PRICES[artifact.rarity])
	RunState.add_artifact(artifact)
	_sell(artifact, "You got %s." % artifact.name)


func _sell(item: Resource, message: String) -> void:
	_sold.append(item)
	_hint.text = message
	_refresh.call_deferred()  # the pressed button is still handling its click


func _on_leave_pressed() -> void:
	RunState.leave_room()
