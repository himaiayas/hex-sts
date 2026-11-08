extends Control

## Campfire: pick one of two, once per visit. Rest heals every damaged health tile; Purge removes
## up to REMOVE_COUNT cards from the deck. Leaving without picking is allowed.

const RenderCard := preload("res://scripts/cards/render_card.gd")
const REMOVE_COUNT := 2
const PICK_BORDER := 6
const REST_TEXT := "Fully heal all your health tiles."

@onready var _top_bar: TopBar = %TopBar
@onready var _hint: Label = %Hint
@onready var _options: Control = %Options
@onready var _rest_button: Button = %RestButton
@onready var _purge_button: Button = %PurgeButton
@onready var _purge_page: Control = %PurgePage
@onready var _card_grid: GridContainer = %CardGrid
@onready var _back_button: Button = %BackButton
@onready var _confirm_button: Button = %ConfirmButton
@onready var _leave_button: Button = %LeaveButton

var _picks: Array[BaseCard] = []
var _hover_info := HoverInfo.new()


func _ready() -> void:
	if RunState.deck.is_empty():
		RunState.start_new_run()
	_hover_info.is_blocked = _top_bar.is_modal_open
	add_child(_hover_info)
	_show_options()


func _show_options() -> void:
	_hover_info.clear()
	_options.show()
	_purge_page.hide()
	_back_button.hide()
	_confirm_button.hide()
	_leave_button.show()
	_hint.text = "Choose one."
	_rest_button.tooltip_text = REST_TEXT
	_purge_button.disabled = _max_picks() == 0
	_purge_button.tooltip_text = "Remove up to %d cards from your deck." % REMOVE_COUNT 		if _max_picks() > 0 else "Your deck must keep at least one card."


func _damaged_tiles() -> Array[HealthTile]:
	var tiles: Array[HealthTile] = []
	for tile: HealthTile in RunState.health.values():
		if tile.hp == Enum.HealthTileEnum.DAMAGED:
			tiles.append(tile)
	return tiles


## The deck always keeps at least one card.
func _max_picks() -> int:
	return mini(REMOVE_COUNT, RunState.deck.size() - 1)


func _on_rest_pressed() -> void:
	var damaged := _damaged_tiles()
	for tile in damaged:
		tile.hp = Enum.HealthTileEnum.UNDAMAGED
	if damaged.is_empty():
		_finish("You rest. You were already at full health.")
	else:
		_finish("Healed %d tile%s." % [damaged.size(), "" if damaged.size() == 1 else "s"])


func _on_purge_pressed() -> void:
	_picks.clear()
	_options.hide()
	_purge_page.show()
	_back_button.show()
	_confirm_button.show()
	_leave_button.hide()
	_hover_info.clear()
	for child in _card_grid.get_children():
		_card_grid.remove_child(child)
		child.queue_free()
	for card in RunState.deck:
		var slot := Control.new()
		slot.custom_minimum_size = RenderCard.CARD_SIZE
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(RenderCard.create_card(card))
		var panel: Panel = slot.get_child(0).get_node("Panel")
		panel.mouse_filter = Control.MOUSE_FILTER_PASS  # clicks here, wheel still scrolls the list
		panel.gui_input.connect(_on_card_input.bind(card, panel))
		_card_grid.add_child(slot)
		_hover_info.add_card(slot, card, _purge_page)
	_refresh_picks()


func _on_card_input(event: InputEvent, card: BaseCard, panel: Panel) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if card in _picks:
		_picks.erase(card)
	elif _picks.size() < _max_picks():
		_picks.append(card)
	else:
		return
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
	style.border_color = HandView.COLOR_PICKED
	style.set_border_width_all(PICK_BORDER if card in _picks else 0)
	_refresh_picks()


func _refresh_picks() -> void:
	_hint.text = "Choose up to %d cards to remove. (%d chosen)" % [_max_picks(), _picks.size()]
	_confirm_button.disabled = _picks.is_empty()


func _on_confirm_pressed() -> void:
	for card in _picks:
		RunState.deck.erase(card)
	_finish("Removed %s." % " and ".join(PackedStringArray(_picks.map(func(card: BaseCard) -> String: return card.card_name))))


func _on_back_pressed() -> void:
	_show_options()


## The one choice of this visit is made: only Leave remains.
func _finish(message: String) -> void:
	_hover_info.clear()
	_options.hide()
	_purge_page.hide()
	_back_button.hide()
	_confirm_button.hide()
	_leave_button.show()
	_hint.text = message
	_top_bar.refresh()


func _on_leave_pressed() -> void:
	RunState.leave_room()
