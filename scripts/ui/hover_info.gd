class_name HoverInfo
extends CanvasLayer

## Shows InfoPanels while the mouse rests on a registered control: a card's keywords, an
## artifact's description. Add it as a child, then add()/add_card() what can be hovered.
## Checks rects every frame rather than mouse_entered/exited: moving onto a button inside the
## control counts as leaving it, and most card views ignore the mouse.

const RenderCard := preload("res://scripts/cards/render_card.gd")
const LAYER := 50  # above every modal
const ICON_SIZE := 40.0  # a pattern tile's hex in its panel

## Optional: return true to show nothing (e.g. a modal covers these controls).
var is_blocked := Callable()

var _targets: Dictionary[Control, Dictionary] = {}  # control -> {entries, above, clip, below}
var _box := InfoPanel.make_box()
var _current: Control = null
var _timer := 0.0


func _ready() -> void:
	layer = LAYER
	add_child(_box)


## entries: [title, body] of each panel. above: over the control instead of beside it.
## clip: only hoverable inside this control's rect (the ScrollContainer it scrolls in).
## below: under the control instead of beside it. No entries: the control isn't hoverable any more.
func add(target: Control, entries: Array, above := false, clip: Control = null, below := false) -> void:
	if entries.is_empty():
		_targets.erase(target)
	else:
		_targets[target] = {entries = entries, above = above, clip = clip, below = below}


func add_card(target: Control, card: BaseCard, clip: Control = null) -> void:
	add(target, keyword_entries(card), false, clip)


## Call before freeing the registered controls.
func clear() -> void:
	_hide()
	_targets.clear()


## [title, body, icon tile or null]: each kind of tile in the card's patterns first, with its hex
## as the icon, then the description's keywords that aren't one of those tiles.
static func keyword_entries(card: BaseCard) -> Array:
	var entries := []
	var titles: Array[String] = []
	for i in card.grid_actions.size():
		for t in card.pattern(i).tiles:
			if t.display_name() not in titles and not t.describe().is_empty():
				titles.append(t.display_name())
				entries.append([t.display_name(), t.describe(), t])
	for keyword in RenderCard.keywords_in(card.get_description()):
		var text := Keywords.describe(keyword)
		if not text.is_empty() and keyword not in titles:
			titles.append(keyword)
			entries.append([keyword, text, null])
	return entries


## textures in a row, each icon_size square.
static func icon_row(textures: Array, icon_size: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for texture: Texture2D in textures:
		var rect := TextureRect.new()
		rect.texture = texture
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.custom_minimum_size = Vector2(icon_size, icon_size)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(rect)
	return row


## The panel for one keyword_entries() entry.
static func make_panel(entry: Array) -> PanelContainer:
	var icon: Control = null
	if entry.size() > 2 and entry[2] is BaseActionTile:
		var tiles: Array[BaseActionTile] = [entry[2].copy_at(Vector2i.ZERO)]
		icon = PatternView.new(GridAction.new(Enum.TargetType.ENEMY, tiles), ICON_SIZE, ICON_SIZE)
	elif entry.size() > 2 and entry[2] is Array:  # textures side by side (an enemy intent's type icons)
		icon = icon_row(entry[2], ICON_SIZE)
	return InfoPanel.make(entry[0], entry[1], InfoPanel.COLOR_TITLE, icon)


func _process(delta: float) -> void:
	var target := _target_under_mouse()
	if target != _current:
		_hide()
		_current = target
		_timer = InfoPanel.DELAY
	if _current == null:
		return
	if not _box.visible:
		_timer -= delta
		if _timer > 0.0:
			return
		for entry in _targets[_current].entries:
			_box.add_child(make_panel(entry))
		_box.reset_size()
		_box.show()
	# Every frame, because the box only knows its wrapped height after a layout pass.
	_box.position = _box_position()


func _target_under_mouse() -> Control:
	if is_blocked.is_valid() and is_blocked.call():
		return null
	var mouse := get_viewport().get_mouse_position()
	for target: Control in _targets:
		if not is_instance_valid(target) or not target.is_visible_in_tree():
			continue
		var clip: Control = _targets[target].clip
		if target.get_global_rect().has_point(mouse) and (clip == null or clip.get_global_rect().has_point(mouse)):
			return target
	return null


## Beside the control, left of it near the screen edge; or above or below it. Always on screen.
func _box_position() -> Vector2:
	var rect := _current.get_global_rect()
	var screen := get_viewport().get_visible_rect().size
	var pos := Vector2(rect.end.x + InfoPanel.GAP, rect.position.y)
	if _targets[_current].above:
		pos = Vector2(rect.get_center().x - _box.size.x / 2.0, rect.position.y - _box.size.y - InfoPanel.GAP)
	elif _targets[_current].below:
		pos = Vector2(rect.get_center().x - _box.size.x / 2.0, rect.end.y + InfoPanel.GAP)
	elif pos.x + _box.size.x > screen.x:
		pos.x = rect.position.x - InfoPanel.GAP - _box.size.x
	return pos.clamp(Vector2.ZERO, (screen - _box.size).max(Vector2.ZERO))


func _hide() -> void:
	_current = null
	InfoPanel.clear(_box)
	_box.hide()
