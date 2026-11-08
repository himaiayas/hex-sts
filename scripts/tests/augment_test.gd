extends Control

## Try every augment: one button per AugmentPool.AUGMENTS entry opens the AugmentModal with it.
## The deck holds one of every card in CardPool, so each augment has cards it can go on.

const RenderCard := preload("res://scripts/cards/render_card.gd")

@onready var _grid: GridContainer = %Grid
@onready var _status: Label = %Status
@onready var _augment_buttons: HBoxContainer = %AugmentButtons
@onready var _modal = %AugmentModal


func _ready() -> void:
	_reset_deck()
	_modal.finished.connect(_on_augment_finished)
	for augment_class in AugmentPool.AUGMENTS:
		var augment: BaseAugment = augment_class.new()
		var button := Button.new()
		button.text = augment.name.trim_suffix(" Augment")
		button.icon = augment.icon
		button.tooltip_text = augment.description
		button.custom_minimum_size = Vector2(0, 56)
		button.add_theme_font_size_override("font_size", 24)
		button.add_theme_constant_override("icon_max_width", 40)
		button.pressed.connect(_on_augment_pressed.bind(augment_class))
		_augment_buttons.add_child(button)
	_show_deck()


func _reset_deck() -> void:
	RunState.start_new_run()
	RunState.deck.clear()
	for card_class in CardPool.CARDS:
		RunState.deck.append(card_class.new())


func _show_deck() -> void:
	for child in _grid.get_children():
		child.queue_free()
	for card in RunState.deck:
		var slot := Control.new()
		slot.custom_minimum_size = RenderCard.CARD_SIZE
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(RenderCard.create_card(card))
		_grid.add_child(slot)


func _on_augment_pressed(augment_class: Script) -> void:
	_modal.open(augment_class.new())


func _on_augment_finished(card: BaseCard) -> void:
	_status.text = "Applied to %s." % card.card_name if card else "No card could take it."
	_show_deck()


func _on_reset_pressed() -> void:
	_reset_deck()
	_status.text = ""
	_show_deck()
