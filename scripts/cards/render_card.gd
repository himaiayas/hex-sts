extends Node

const CARD_SCENE := preload("res://scenes/Card.tscn")
const TYPE_COLORS := {
	BaseCard.CardType.ATTACK: Color("8c2f2f"),
	BaseCard.CardType.DEFENSE: Color("2f6f4f"),
	BaseCard.CardType.SKILL: Color("2f5f8c"),
	BaseCard.CardType.POWER: Color("6a3a8c"),
}
const COLOR_KEYWORD := Color(1, 0.831373, 0.352941)
const FONT_SIZE := 13

## {keyword:Poison} in a description.
static var _keyword_regex := RegEx.create_from_string("\\{keyword:([^}]+)\\}")

var card_data: BaseCard = Strike.new()


func _ready() -> void:
	var card := create_card(card_data)
	add_child(card)
	card.position = get_viewport().get_visible_rect().size / 2 - Vector2(70, 95)


static func create_card(data: BaseCard) -> Node2D:
	var card: Node2D = CARD_SCENE.instantiate()
	card.get_node("%CostLabel").text = str(data.cost)
	card.get_node("%NameLabel").text = data.card_name
	card.get_node("%TypeLabel").text = BaseCard.CardType.keys()[data.type].capitalize()
	_fill_description(card.get_node("%Description"), data)
	if data.image:
		card.get_node("%CardImage").texture = data.image

	# Panel colour by type; duplicate so cards don't share one StyleBox.
	var panel: PanelContainer = card.get_node("Panel")
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	style.bg_color = TYPE_COLORS.get(data.type, Color.DIM_GRAY)
	panel.add_theme_stylebox_override("panel", style)
	return card


## Keywords used in a description, in order, without repeats.
static func keywords_in(description: String) -> PackedStringArray:
	var found := PackedStringArray()
	for m in _keyword_regex.search_all(description):
		if m.get_string(1) not in found:
			found.append(m.get_string(1))
	return found


## One row per line: a line that is just {render} draws the card's tiles, anything else is text.
static func _fill_description(box: VBoxContainer, data: BaseCard) -> void:
	var keyword_bbcode := "[b][color=#%s]$1[/color][/b]" % COLOR_KEYWORD.to_html(false)
	for line in data.get_description().split("\n"):
		if line.strip_edges() == "{render}":
			box.add_child(PatternView.new(data.tiles))
			continue
		var label := RichTextLabel.new()
		label.bbcode_enabled = true
		label.fit_content = true
		label.scroll_active = false
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("normal_font_size", FONT_SIZE)
		label.add_theme_font_size_override("bold_font_size", FONT_SIZE)
		label.text = _keyword_regex.sub(line, keyword_bbcode, true)
		box.add_child(label)
