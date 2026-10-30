extends Control


const RenderCard := preload("res://scripts/cards/render_card.gd")

@onready var _grid: GridContainer = %Grid


func _ready() -> void:
	for card_class in CardPool.CARDS:
		var slot := Control.new()
		slot.custom_minimum_size = RenderCard.CARD_SIZE
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(RenderCard.create_card(card_class.new()))
		_grid.add_child(slot)
