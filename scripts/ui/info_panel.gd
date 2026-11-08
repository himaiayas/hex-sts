class_name InfoPanel

## Hover info boxes: a gold title over a description, in a dark bordered panel.
## Used for card keywords (HandView) and health tiles (HealthGridView).

const WIDTH := 300.0
const DELAY := 0.5  # seconds of hovering before panels show
const GAP := 13.0  # between the panels and what they describe
const COLOR_BG := Color(0.08, 0.08, 0.1, 0.92)
const COLOR_BORDER := Color(0.85098, 0.764706, 0.54902)
const COLOR_TITLE := Color(1, 0.831373, 0.352941)
const BODY_FONT_SIZE := 22


## icon: drawn left of the title (a tile's hex, for pattern tiles on cards).
static func make(title: String, body: String, title_color := COLOR_TITLE, icon: Control = null) -> PanelContainer:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.border_color = COLOR_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(13)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rows := VBoxContainer.new()
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_color_override("font_color", title_color)
	var body_label := Label.new()
	body_label.text = body
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.custom_minimum_size.x = WIDTH - 26
	body_label.add_theme_font_size_override("font_size", BODY_FONT_SIZE)
	if icon:
		var title_row := HBoxContainer.new()
		title_row.add_theme_constant_override("separation", 8)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		title_row.add_child(icon)
		title_row.add_child(title_label)
		rows.add_child(title_row)
	else:
		rows.add_child(title_label)
	rows.add_child(body_label)
	panel.add_child(rows)
	return panel


## A column for a stack of panels; empty and hidden until filled.
static func make_box() -> VBoxContainer:
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.hide()
	return box


static func clear(box: VBoxContainer) -> void:
	for child in box.get_children():
		box.remove_child(child)
		child.queue_free()
