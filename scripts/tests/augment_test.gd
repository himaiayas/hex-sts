extends Control

## Test scene: get an Expansion Augment, apply it to a deck card, see the deck. Run with F6.

const RenderCard := preload("res://scripts/cards/render_card.gd")

@onready var _grid: GridContainer = %Grid
@onready var _status: Label = %Status
@onready var _modal = %AugmentModal


func _ready() -> void:
	RunState.start_new_run()
	_modal.finished.connect(_on_augment_finished)
	_show_deck()


func _show_deck() -> void:
	for child in _grid.get_children():
		child.queue_free()
	for card in RunState.deck:
		var slot := Control.new()
		slot.custom_minimum_size = RenderCard.CARD_SIZE
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(RenderCard.create_card(card))
		_grid.add_child(slot)


func _on_get_augment_pressed() -> void:
	_modal.open(ExpansionAugment.new())


func _on_augment_finished(card: BaseCard) -> void:
	_status.text = "Applied to %s." % card.card_name if card else "No card could take it."
	_show_deck()


func _on_reset_pressed() -> void:
	RunState.start_new_run()
	_status.text = ""
	_show_deck()
