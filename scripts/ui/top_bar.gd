class_name TopBar
extends Control



const RenderCard := preload("res://scripts/cards/render_card.gd")
const CARD_SIZE := HandView.CARD_SIZE
const ARTIFACT_IMAGE_SIZE := 96.0

@onready var _health_button: Button = %HealthButton
@onready var _gold_display: Button = %GoldDisplay
@onready var _deck_button: Button = %DeckButton
@onready var _artifact_button: Button = %ArtifactButton
@onready var _exp: Control = %Exp
@onready var _exp_bar: ProgressBar = %ExpBar
@onready var _exp_text: Label = %ExpText
@onready var _cur_level: Label = %CurrentLevelLabel
@onready var _next_level: Label = %NextLevelLabel

@onready var _health_modal: Control = %HealthModal
@onready var _health_grid: HealthGridView = %HealthGrid
@onready var _deck_modal: Control = %DeckModal
@onready var _deck_title: Label = %DeckTitle
@onready var _deck_grid: GridContainer = %DeckGrid
@onready var _artifact_modal: Control = %ArtifactModal
@onready var _artifact_list: VBoxContainer = %ArtifactList
@onready var _level_up_modal: Control = %LevelUpModal
@onready var _level_up_title: Label = %LevelUpTitle
@onready var _level_up_hint: Label = %LevelUpHint
@onready var _level_up_grid: HealthGridView = %LevelUpGrid
@onready var _level_up_artifact: RichTextLabel = %LevelUpArtifact
@onready var _level_up_artifact_image: TextureRect = %LevelUpArtifactImage
@onready var _confirm_button: Button = %ConfirmButton

const NEIGHBORS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
	Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1)]

var _hover_info := HoverInfo.new()  # keywords of cards in the Deck modal and of artifacts

## Level-up in progress: a copy of the health grid with the placed tiles, and the artifact on offer.
var _level_up_health: Dictionary[Vector2i, HealthTile] = {}
var _level_up_reward: BaseArtifact = null
var _placing := 0  # tiles this modal places: LEVEL_UP_TILES for a level, or an artifact's tile slots
var _slots_only := false  # opened for RunState.pending_tile_slots, not a level


func _ready() -> void:
	add_child(_hover_info)
	_close_modals()
	refresh()


## Icons show their numbers; EXP only in its hover text.
func refresh() -> void:
	_health_button.text = "%d/%d" % [_alive_tiles(), RunState.health.size()]
	_gold_display.text = str(RunState.gold)
	_deck_button.text = str(RunState.deck.size())
	_artifact_button.text = str(RunState.artifacts.size())
	_health_button.tooltip_text = "Health  %d / %d" % [_alive_tiles(), RunState.health.size()]
	_gold_display.tooltip_text = "Gold  %d" % RunState.gold
	_deck_button.tooltip_text = "Deck  %d cards" % RunState.deck.size()
	_artifact_button.tooltip_text = "Artifacts  %d" % RunState.artifacts.size()
	if RunState.is_max_level():
		_exp_bar.max_value = 1
		_exp_bar.value = 1
		_cur_level.text = "LV%d" % RunState.level
		_next_level.text = "LV%d" % RunState.level
		_exp_text.text = "MAX"
		_exp.tooltip_text = "Level %d  (MAX)" % RunState.level
	else:
		_exp_bar.max_value = RunState.xp_to_next()
		_exp_bar.value = RunState.xp
		_cur_level.text = "LV%d" % RunState.level
		_next_level.text = "LV%d" % [RunState.level+1]
		_exp_text.text = "%d/%d" % [RunState.xp, RunState.xp_to_next()]
		_exp.tooltip_text = "Level %d  %d / %d EXP" % [RunState.level, RunState.xp, RunState.xp_to_next()]
	if (RunState.pending_level_ups > 0 or RunState.pending_tile_slots > 0) and not _level_up_modal.visible:
		_open_level_up()


func is_modal_open() -> bool:
	return _health_modal.visible or _deck_modal.visible or _artifact_modal.visible \
		or _level_up_modal.visible


func _alive_tiles() -> int:
	var alive := 0
	for tile in RunState.health.values():
		if tile.hp > Enum.HealthTileEnum.DAMAGED:
			alive += 1
	return alive


func _close_modals() -> void:
	_health_modal.hide()
	_deck_modal.hide()
	_artifact_modal.hide()


func _on_health_pressed() -> void:
	_close_modals()
	_health_grid.setup(CombatUnit.new("Player", RunState.health, true), false)
	_health_modal.show()


func _on_deck_pressed() -> void:
	_close_modals()
	_deck_title.text = "Deck (%d)" % RunState.deck.size()
	_hover_info.clear()
	for child in _deck_grid.get_children():
		child.queue_free()
	for card in RunState.deck:
		var slot := Control.new()
		slot.custom_minimum_size = CARD_SIZE
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var view := RenderCard.create_card(card)
		view.get_node("Panel").mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(view)
		_deck_grid.add_child(slot)
		_hover_info.add_card(slot, card, _deck_grid.get_parent())
	_deck_modal.show()


func _on_artifacts_pressed() -> void:
	_close_modals()
	_hover_info.clear()
	for child in _artifact_list.get_children():
		child.queue_free()
	for artifact in RunState.artifacts:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 20)
		var image := TextureRect.new()
		image.texture = artifact.image
		image.custom_minimum_size = Vector2(ARTIFACT_IMAGE_SIZE, ARTIFACT_IMAGE_SIZE)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(image)
		var text := RichTextLabel.new()
		text.bbcode_enabled = true
		text.fit_content = true 
		text.text = "[b]%s[/b]\n[color=#8d93a5]%s[/color]" % [artifact.name, artifact.bbcode_description()]
		text.add_theme_font_size_override("normal_font_size", 26)
		text.add_theme_font_size_override("bold_font_size", 26)
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(text)
		_artifact_list.add_child(row)
		_hover_info.add(row, artifact.keyword_entries(), false, _artifact_list.get_parent())
	if RunState.artifacts.is_empty():
		var empty := Label.new()
		empty.text = "No artifacts yet."
		empty.add_theme_font_size_override("font_size", 26)
		_artifact_list.add_child(empty)
	_artifact_modal.show()


func _on_close_pressed() -> void:
	_close_modals()


## One modal per level gained: place LEVEL_UP_TILES health tiles next to the grid, and take an artifact.
func _open_level_up() -> void:
	_close_modals()
	_slots_only = RunState.pending_level_ups == 0
	_placing = RunState.pending_tile_slots if _slots_only else RunState.LEVEL_UP_TILES
	_level_up_title.text = "New health tiles" if _slots_only \
		else "Level %d!" % (RunState.level - RunState.pending_level_ups + 1)
	_level_up_reward = null if _slots_only else ArtifactPool.random_artifact(RunState.artifacts)
	_level_up_artifact.visible = not _slots_only
	_level_up_artifact_image.visible = _level_up_reward != null
	if _level_up_reward:
		_level_up_artifact_image.texture = _level_up_reward.image
		_level_up_artifact.text = "[center][b]%s[/b]\n[color=#8d93a5]%s[/color][/center]" % [
			_level_up_reward.name, _level_up_reward.bbcode_description()]
		_hover_info.clear()
		_hover_info.add(_level_up_artifact, _level_up_reward.keyword_entries())
	else:
		_level_up_artifact.text = "[center]You own every artifact.[/center]"
	if _level_up_grid.unit == null:
		_level_up_grid.setup(CombatUnit.new("Player", RunState.health.duplicate(), true), true)
	_on_level_up_reset_pressed()
	_level_up_modal.show()


func _on_level_up_cell_clicked(_unit: CombatUnit, cell: Vector2i) -> void:
	if _level_up_grid.candidates.has(cell):
		_level_up_health[cell] = HealthTile.new()
		_level_up_grid.new_cells.append(cell)
		_refresh_level_up()


func _on_level_up_reset_pressed() -> void:
	_level_up_health = RunState.health.duplicate()
	_level_up_grid.unit.health = _level_up_health
	_level_up_grid.new_cells.clear()
	_refresh_level_up()


func _on_level_up_confirm_pressed() -> void:
	for cell in _level_up_grid.new_cells:
		RunState.health[cell] = _level_up_health[cell]
	if _level_up_reward:
		RunState.add_artifact(_level_up_reward)
	if _slots_only:
		RunState.pending_tile_slots = 0
	else:
		RunState.pending_level_ups -= 1
	_level_up_modal.hide()
	refresh()  # opens the next level-up, if any


## Empty cells next to the grid are clickable until all tiles are placed.
func _refresh_level_up() -> void:
	var left := _placing - _level_up_grid.new_cells.size()
	_level_up_grid.candidates.clear()
	if left > 0:
		for cell: Vector2i in _level_up_health:
			for offset in NEIGHBORS:
				var next := cell + offset
				if not _level_up_health.has(next) and not _level_up_grid.candidates.has(next):
					_level_up_grid.candidates.append(next)
	_level_up_hint.text = "Place %d more health tile%s" % [left, "" if left == 1 else "s"] \
		if left > 0 else "All tiles placed"
	_confirm_button.disabled = left > 0
	_level_up_grid.refresh()
