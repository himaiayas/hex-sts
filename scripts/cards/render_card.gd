extends Node

const CARD_SCENE := preload("res://scenes/Card.tscn")
const TYPE_COLORS := {
	BaseCard.CardType.ATTACK: Color("8c2f2f"),
	BaseCard.CardType.DEFENSE: Color("2f6f4f"),
	BaseCard.CardType.SKILL: Color("2f5f8c"),
	BaseCard.CardType.POWER: Color("6a3a8c"),
}

var card_data: BaseCard = Strike.new()


func _ready() -> void:
	var card := create_card(card_data)
	add_child(card)
	card.position = get_viewport().get_visible_rect().size / 2 - Vector2(70, 95)


func create_card(data: BaseCard) -> Node2D:
	var card: Node2D = CARD_SCENE.instantiate()
	card.get_node("%CostLabel").text = str(data.cost)
	card.get_node("%NameLabel").text = data.card_name
	card.get_node("%TypeLabel").text = BaseCard.CardType.keys()[data.type].capitalize()
	card.get_node("%DescriptionLabel").text = data.get_description()
	if data.image:
		card.get_node("%CardImage").texture = data.image

	# Panel colour by type; duplicate so cards don't share one StyleBox.
	var panel: PanelContainer = card.get_node("Panel")
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	style.bg_color = TYPE_COLORS.get(data.type, Color.DIM_GRAY)
	panel.add_theme_stylebox_override("panel", style)
	return card
