extends Node

## Layout, in card pixels (0,0 = top-left of the card). Adjust freely.
const CARD_SIZE := Vector2(234, 334)
const IMAGE_RECT := Rect2(5, 6, 224, 158)  # card image: from the frame's inner edge down into the name frame
const NAME_FILL_RECT := Rect2(12, 143, 210, 41)  # fills the name frame's see-through middle
const NAME_FILL_COLOR := Color.WHITE
const NAME_RECT := Rect2(26, 141, 182, 45)  # name text, inside the name frame
const DESCRIPTION_RECT := Rect2(14, 194, 206, 128)  # text and patterns, lower part
const COST_RECT := Rect2(-25, -35, 90, 96)  # cost frame, upper-left (may stick out)
const STAR_SIZE := 22.0
const STAR_SPACING := 1  # between stars
const STAR_MARGIN := Vector2(6, 1)  # from the card's top-right corner
const AUGMENT_SIZE := 44.0  # augment icons, centred at the top of the card
const AUGMENT_SPACING := 4
const AUGMENT_OFFSET := 18.0  # how far the icons stick out above the card frame
const NAME_FONT_SIZE := 22
const COST_FONT_SIZE := 30
const INLINE_PATTERN_HEIGHT := PatternView.MAX_HEIGHT  # tallest a {render:N} sharing its line with text gets
const INLINE_SPACING := 4  # between text and an inline pattern
const FONT_SIZE :=16  # description
const COLOR_DESCRIPTION := Color(0.117647, 0.117647, 0.137255)  # dark, like the name
const COLOR_RAISED_COST := Color("#ff4a4a")  # a cost raised by a debuff

## Background, name frame and outline images are 1034x1436 with the card drawn in this
## part; it's cropped out so the layers line up.
const ART_REGION := Rect2(167, 218, 700, 1000)

## Per card type. All the same for now.
const BACKGROUNDS := {
	Enum.CardType.ATTACK: preload("res://assets/cards/Card_red.png"),
	Enum.CardType.DEFENSE: preload("res://assets/cards/Card_red.png"),
	Enum.CardType.SKILL: preload("res://assets/cards/Card_red.png"),
	Enum.CardType.POWER: preload("res://assets/cards/Card_red.png"),
}
const OUTLINES := {
	Enum.CardType.ATTACK: preload("res://assets/cards/OutlineR.png"),
	Enum.CardType.DEFENSE: preload("res://assets/cards/OutlineR.png"),
	Enum.CardType.SKILL: preload("res://assets/cards/OutlineR.png"),
	Enum.CardType.POWER: preload("res://assets/cards/OutlineR.png"),
}
const COST_FRAMES := {
	Enum.CardType.ATTACK: preload("res://assets/cards/CostR.png"),
	Enum.CardType.DEFENSE: preload("res://assets/cards/CostR.png"),
	Enum.CardType.SKILL: preload("res://assets/cards/CostR.png"),
	Enum.CardType.POWER: preload("res://assets/cards/CostR.png"),
}
const NAME_FRAME := preload("res://assets/cards/card_name_frame.png")
const STAR := preload("res://assets/cards/rarity_star.png")

const CARD_SCENE := preload("res://scenes/Card.tscn")
const COLOR_KEYWORD := Color(1, 0.831373, 0.352941)

## {keyword:Poison} in a description.
static var _keyword_regex := RegEx.create_from_string("\\{keyword:([^}]+)\\}")
## A line that is just {render:N}.
static var _render_regex := RegEx.create_from_string("^\\{render:(\\d+)\\}$")
## {render:N} anywhere in a line.
static var _inline_render_regex := RegEx.create_from_string("\\{render:(\\d+)\\}")

var card_data: BaseCard = Strike.new()


func _ready() -> void:
	var card := create_card(card_data)
	add_child(card)
	card.position = get_viewport().get_visible_rect().size / 2 - CARD_SIZE / 2


## Layers, bottom to top: background, image, name frame + name, description, outline,
## cost frame + cost, rarity stars.
static func create_card(data: BaseCard) -> Node2D:
	var card: Node2D = CARD_SCENE.instantiate()
	var panel: Panel = card.get_node("Panel")
	panel.size = CARD_SIZE
	panel.pivot_offset = CARD_SIZE * Vector2(0.5, 1)
	# Duplicate so selecting one card doesn't outline them all.
	panel.add_theme_stylebox_override("panel", panel.get_theme_stylebox("panel").duplicate())

	_place(card.get_node("%Background"), Rect2(Vector2.ZERO, CARD_SIZE), _crop(BACKGROUNDS[data.type]))
	_place(card.get_node("%CardImage"), IMAGE_RECT, data.image)
	var name_fill: ColorRect = card.get_node("%NameFill")
	_place(name_fill, NAME_FILL_RECT)
	name_fill.color = NAME_FILL_COLOR
	_place(card.get_node("%NameFrame"), Rect2(Vector2.ZERO, CARD_SIZE), _crop(NAME_FRAME))
	_place(card.get_node("%Outline"), Rect2(Vector2.ZERO, CARD_SIZE), _crop(OUTLINES[data.type]))
	_place(card.get_node("%CostFrame"), COST_RECT, COST_FRAMES[data.type])

	var name_label: Label = card.get_node("%NameLabel")
	_place(name_label, NAME_RECT)
	name_label.text = data.card_name
	name_label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)

	var cost_label: Label = card.get_node("%CostLabel")
	cost_label.text = "X" if data.x_cost else str(data.cost)
	cost_label.add_theme_font_size_override("font_size", COST_FONT_SIZE)

	var description: VBoxContainer = card.get_node("%Description")
	_place(description, DESCRIPTION_RECT)
	_fill_description(description, data)
	description.minimum_size_changed.connect(_fit_description.bind(description))

	# One star per rarity step: Common 1, Uncommon 2, ...
	var stars: HBoxContainer = card.get_node("%Stars")
	stars.add_theme_constant_override("separation", STAR_SPACING)
	for i in data.rarity + 1:
		var star := TextureRect.new()
		star.texture = STAR
		star.custom_minimum_size = Vector2(STAR_SIZE, STAR_SIZE)
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stars.add_child(star)
	var stars_width := (data.rarity + 1) * STAR_SIZE + data.rarity * STAR_SPACING
	_place(stars, Rect2(CARD_SIZE.x - STAR_MARGIN.x - stars_width, STAR_MARGIN.y, stars_width, STAR_SIZE))

	# Augment icons, centred at the top and poking out above the frame.
	var augments: HBoxContainer = card.get_node("%Augments")
	augments.add_theme_constant_override("separation", AUGMENT_SPACING)
	for augment in data.augments:
		var icon := TextureRect.new()
		icon.texture = augment.icon
		icon.tooltip_text = augment.name
		icon.custom_minimum_size = Vector2(AUGMENT_SIZE, AUGMENT_SIZE)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		augments.add_child(icon)
	var augments_width := data.augments.size() * (AUGMENT_SIZE + AUGMENT_SPACING) - AUGMENT_SPACING
	_place(augments, Rect2((CARD_SIZE.x - augments_width) / 2, -AUGMENT_OFFSET, augments_width, AUGMENT_SIZE))
	return card


## Shows cost ("2", "X") on a card made by create_card, in COLOR_RAISED_COST when a debuff raised it (Shiver).
static func set_cost(card: Node2D, cost: String, raised: bool) -> void:
	var cost_label: Label = card.get_node("%CostLabel")
	cost_label.text = cost
	if not cost_label.has_meta("cost_color"):  # Card.tscn's own colour, to go back to
		cost_label.set_meta("cost_color", cost_label.get_theme_color("font_color"))
	cost_label.add_theme_color_override("font_color", COLOR_RAISED_COST if raised else cost_label.get_meta("cost_color"))


## Shrinks the description when it's taller or wider than DESCRIPTION_RECT, keeping it centred.
static func _fit_description(box: VBoxContainer) -> void:
	box.size = DESCRIPTION_RECT.size  # grows back to its minimum size if the content is bigger
	var fit := minf(1.0, minf(DESCRIPTION_RECT.size.x / maxf(1.0, box.size.x),
		DESCRIPTION_RECT.size.y / maxf(1.0, box.size.y)))
	box.scale = Vector2(fit, fit)
	box.position = DESCRIPTION_RECT.position + Vector2((DESCRIPTION_RECT.size.x - box.size.x * fit) / 2.0, 0)


static func _place(node: Control, rect: Rect2, texture: Texture2D = null) -> void:
	node.position = rect.position
	node.size = rect.size
	if texture:
		node.set("texture", texture)


static func _crop(texture: Texture2D) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = ART_REGION
	return atlas


## Keywords used in a description, in order, without repeats.
static func keywords_in(description: String) -> PackedStringArray:
	var found := PackedStringArray()
	for m in _keyword_regex.search_all(description):
		if m.get_string(1) not in found:
			found.append(m.get_string(1))
	return found


## One row per line: a line that is just {render:N} draws grid_actions[N] full width;
## {render:N} inside text draws it small, in a row with the text (that text doesn't wrap).
static func _fill_description(box: VBoxContainer, data: BaseCard) -> void:
	for line in data.get_description().split("\n"):
		var render := _render_regex.search(line.strip_edges())
		if render:
			var action := _grid_action(data, render.get_string(1).to_int())
			if action:
				box.add_child(PatternView.new(action))
			continue
		if not _inline_render_regex.search(line):
			box.add_child(_text_label(line, true))
			continue
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", INLINE_SPACING)
		var start := 0
		for m in _inline_render_regex.search_all(line):
			_add_inline_text(row, line.substr(start, m.get_start() - start))
			var action := _grid_action(data, m.get_string(1).to_int())
			if action:
				var pattern := PatternView.new(action, INLINE_PATTERN_HEIGHT)
				pattern.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				row.add_child(pattern)
			start = m.get_end()
		_add_inline_text(row, line.substr(start))
		box.add_child(row)


static func _grid_action(data: BaseCard, index: int) -> GridAction:
	if index < data.grid_actions.size():
		return data.grid_actions[index]
	push_warning("%s has no grid action %d" % [data.card_name, index])
	return null


static func _add_inline_text(row: HBoxContainer, text: String) -> void:
	if not text.strip_edges().is_empty():
		var label := _text_label(text.strip_edges(), false)
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(label)


## wrap: wraps to the description's width; otherwise as wide as its text.
static func _text_label(text: String, wrap: bool) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	label.add_theme_font_size_override("bold_font_size", FONT_SIZE)
	label.add_theme_color_override("default_color", COLOR_DESCRIPTION)
	label.text = _keyword_regex.sub(text, "[b][color=#%s]$1[/color][/b]" % COLOR_KEYWORD.to_html(false), true)
	return label
