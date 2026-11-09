extends Control


const RenderCard := preload("res://scripts/cards/render_card.gd")

@onready var _grid: GridContainer = %Grid
@onready var _scroll: ScrollContainer = $Margin/Box/Scroll

var _hover_info := HoverInfo.new()  # keyword panels of the card under the mouse


func _ready() -> void:
	add_child(_hover_info)
	BackToMenu.add_to(self)
	for card_class in CardPool.CARDS:
		var card: BaseCard = card_class.new()
		var slot := Control.new()
		slot.custom_minimum_size = RenderCard.CARD_SIZE
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var view := RenderCard.create_card(card)
		view.get_node("Panel").mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(view)
		_grid.add_child(slot)
		_hover_info.add_card(slot, card, _scroll)
