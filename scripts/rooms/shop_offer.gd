class_name ShopOffer

## The look of one item for sale, shared by the Blacksmith and the Merchant:
## a dark panel holding the item, with a coin price button below it.

const COIN := preload("res://assets/icons/coin.png")
const COLOR_BG := Color(0.0784314, 0.0862745, 0.109804)
const COLOR_BORDER := Color(0.231373, 0.254902, 0.321569)
const COLOR_TEXT_DIM := Color(0.552941, 0.576471, 0.647059)
const COLOR_SOLD := Color(1, 1, 1, 0.45)


## problem: why it can't be bought, besides coins (shown on hover). Empty if nothing stops it.
static func make(offer_size: Vector2, content: Control, price: int, sold: bool, on_buy: Callable,
		problem := "") -> PanelContainer:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.border_color = COLOR_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(20)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = offer_size
	panel.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(content)

	var buy := Button.new()
	buy.custom_minimum_size = Vector2(0, 56)
	buy.add_theme_font_size_override("font_size", 26)
	if sold:
		buy.text = "Sold"
		buy.disabled = true
		panel.modulate = COLOR_SOLD
	else:
		buy.text = str(price)
		buy.icon = COIN
		buy.expand_icon = true
		buy.add_theme_constant_override("icon_max_width", 32)
		if not problem.is_empty():
			buy.tooltip_text = problem
		elif RunState.gold < price:
			buy.tooltip_text = "Not enough coins."
		buy.disabled = not buy.tooltip_text.is_empty()
		buy.pressed.connect(on_buy)
	box.add_child(buy)
	return panel


## Icon above a centred name and description.
static func make_info_column(icon: Texture2D, icon_size: float, title: String, description: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	box.add_child(_make_icon(icon, icon_size))
	box.add_child(_make_text(title, description, HORIZONTAL_ALIGNMENT_CENTER))
	return box


## Icon beside a name, for a shorter panel.
static func make_name_row(icon: Texture2D, icon_size: float, title: String) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	box.add_child(_make_icon(icon, icon_size))
	var title_label := Label.new()
	title_label.text = title
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 26)
	box.add_child(title_label)
	return box


static func _make_icon(texture: Texture2D, icon_size: float) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return icon


static func _make_text(title: String, description: String, alignment: HorizontalAlignment) -> Control:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = alignment
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 26)
	box.add_child(title_label)
	var description_label := Label.new()
	description_label.text = description
	description_label.horizontal_alignment = alignment
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.modulate = COLOR_TEXT_DIM
	description_label.add_theme_font_size_override("font_size", 20)
	box.add_child(description_label)
	return box
