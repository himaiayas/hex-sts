extends CanvasLayer

## Applying an augment the player just got: pick a card from the deck, then (Expansion
## Augment) a pattern, an empty cell next to it, and, if its neighbours differ, which action
## to copy. There's no cancel: the augment must go on a card (unless none can take it).
## Usage: add the scene, call open(augment), wait for `finished`.

signal finished(card: BaseCard)  # null if no card could take it

const RenderCard := preload("res://scripts/cards/render_card.gd")
const PREVIEW_SCALE := 1.4
const PREVIEW_OFFSET := Vector2(36, 40)  # room for the cost frame and augment icons sticking out
const COLOR_DIM := Color(1, 1, 1, 0.3)  # cards the augment can't go on

var augment: BaseAugment

var _card: BaseCard = null
var _action: GridAction = null
var _tile: BaseActionTile = null  # placed in _action.tiles while previewing; removed if changed
var _hover_info := HoverInfo.new()  # keywords of the cards shown

@onready var _icon: TextureRect = %AugmentIcon
@onready var _title: Label = %Title
@onready var _hint: Label = %Hint
@onready var _card_page: Control = %CardPage
@onready var _card_grid: GridContainer = %CardGrid
@onready var _edit_page: Control = %EditPage
@onready var _pattern_buttons: HBoxContainer = %PatternButtons
@onready var _editor: PatternEditor = %Editor
@onready var _tile_options: HBoxContainer = %TileOptions
@onready var _preview: Control = %Preview
@onready var _back_button: Button = %BackButton
@onready var _confirm_button: Button = %ConfirmButton


func _ready() -> void:
	add_child(_hover_info)


func open(_augment: BaseAugment) -> void:
	augment = _augment
	_icon.texture = augment.icon
	_title.text = augment.name
	_show_cards()
	show()


# --- Step 1: card --------------------------------------------------------------

func _show_cards() -> void:
	_remove_tile()
	_card = null
	_action = null
	_card_page.show()
	_edit_page.hide()
	_back_button.hide()
	_hover_info.clear()
	_clear(_card_grid)
	var any := false
	for card in RunState.deck:
		var slot := Control.new()
		slot.custom_minimum_size = RenderCard.CARD_SIZE
		var view := RenderCard.create_card(card)
		slot.add_child(view)
		var panel: Control = view.get_node("Panel")
		if augment.can_apply(card):
			any = true
			panel.gui_input.connect(_on_card_input.bind(card))
		else:
			slot.modulate = COLOR_DIM
			panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_card_grid.add_child(slot)
		_hover_info.add_card(slot, card, _card_page)
	_hint.text = "%s\nChoose a card for it." % augment.description if any \
		else "No card in your deck can take this augment."
	_confirm_button.text = "Confirm" if any else "Continue"
	_confirm_button.disabled = any


func _on_card_input(event: InputEvent, card: BaseCard) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if augment is ExpansionAugment:
			_edit(card)
		else:  # nothing more to choose
			_card = card
			_on_confirm_pressed()


# --- Step 2: expansion -----------------------------------------------------------

func _edit(card: BaseCard) -> void:
	_card = card
	_card_page.hide()
	_edit_page.show()
	_back_button.show()
	_clear(_pattern_buttons)
	var patterns := ExpansionAugment.patterns(card)
	if patterns.size() > 1:
		for i in patterns.size():
			var button := Button.new()
			button.text = "Pattern %d" % (i + 1)
			button.toggle_mode = true
			button.custom_minimum_size = Vector2(160, 48)
			button.add_theme_font_size_override("font_size", 22)
			button.pressed.connect(_select_pattern.bind(patterns[i]))
			_pattern_buttons.add_child(button)
	_select_pattern(patterns[0])


func _select_pattern(action: GridAction) -> void:
	_remove_tile()
	_action = action
	var patterns := ExpansionAugment.patterns(_card)
	for i in _pattern_buttons.get_child_count():
		(_pattern_buttons.get_child(i) as Button).set_pressed_no_signal(patterns[i] == action)
	_editor.setup(action, ExpansionAugment.free_cells(action))
	_clear(_tile_options)
	_hint.text = "Click an outlined cell to add a tile there. It copies a tile next to it." \
		+ ("\nThis card has more than one pattern: only one can grow." if patterns.size() > 1 else "")
	_refresh_preview()


func _on_editor_cell_clicked(cell: Vector2i) -> void:
	_remove_tile()
	_editor.new_cell = cell
	_clear(_tile_options)
	var options := ExpansionAugment.tile_options(_action, cell)
	if options.size() == 1:
		_place(options[0])
		return
	_hint.text = "Its neighbours do different things. Choose what the new tile does."
	for tile in options:
		var button := Button.new()
		button.text = tile.display_name()
		button.icon = tile.get_icon()
		button.expand_icon = true
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(180, 56)
		button.add_theme_font_size_override("font_size", 22)
		button.add_theme_constant_override("icon_max_width", 36)
		button.pressed.connect(_on_option_pressed.bind(button, tile))
		_tile_options.add_child(button)
	_editor.queue_redraw()
	_refresh_preview()


func _on_option_pressed(button: Button, tile: BaseActionTile) -> void:
	for other in _tile_options.get_children():
		(other as Button).set_pressed_no_signal(other == button)
	_place(tile)


func _place(tile: BaseActionTile) -> void:
	_remove_tile()
	_tile = tile
	_action.tiles.append(tile)
	_confirm_button.disabled = false
	_editor.queue_redraw()
	_refresh_preview()


## Undo the previewed tile so the card is as it was.
func _remove_tile() -> void:
	if _tile:
		_action.tiles.erase(_tile)
		_tile = null
	_confirm_button.disabled = true


func _refresh_preview() -> void:
	_hover_info.clear()
	_hover_info.add_card(_preview, _card)
	_clear(_preview)
	var view := RenderCard.create_card(_card)
	view.scale = Vector2(PREVIEW_SCALE, PREVIEW_SCALE)
	view.position = PREVIEW_OFFSET
	view.get_node("Panel").mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview.add_child(view)


# --- Done --------------------------------------------------------------------------

func _on_back_pressed() -> void:
	_show_cards()


func _on_confirm_pressed() -> void:
	if _card:
		_card.augments.append(augment)
		_tile = null  # keep it: it's part of the card now
	_hover_info.clear()
	hide()
	finished.emit(_card)


static func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
