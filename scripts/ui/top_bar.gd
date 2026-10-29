class_name TopBar
extends Control

## Run info shown on top of the screen: Health, Gold, Deck and Artifacts icons (all but Gold open
## a modal) and the EXP bar. Hover an icon or the bar for its numbers.
## Reads everything from RunState; call refresh() after it changes.

const RenderCard := preload("res://scripts/cards/render_card.gd")
const CARD_SIZE := HandView.CARD_SIZE

@onready var _health_button: Button = %HealthButton
@onready var _gold_display: Button = %GoldDisplay
@onready var _deck_button: Button = %DeckButton
@onready var _artifact_button: Button = %ArtifactButton
@onready var _exp: Control = %Exp
@onready var _exp_bar: ProgressBar = %ExpBar

@onready var _health_modal: Control = %HealthModal
@onready var _health_grid: HealthGridView = %HealthGrid
@onready var _deck_modal: Control = %DeckModal
@onready var _deck_title: Label = %DeckTitle
@onready var _deck_grid: GridContainer = %DeckGrid
@onready var _artifact_modal: Control = %ArtifactModal
@onready var _artifact_list: VBoxContainer = %ArtifactList


func _ready() -> void:
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
		_exp.tooltip_text = "Level %d  (MAX)" % RunState.level
	else:
		_exp_bar.max_value = RunState.xp_to_next()
		_exp_bar.value = RunState.xp
		_exp.tooltip_text = "Level %d  %d / %d EXP" % [RunState.level, RunState.xp, RunState.xp_to_next()]


func is_modal_open() -> bool:
	return _health_modal.visible or _deck_modal.visible or _artifact_modal.visible


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
	_deck_modal.show()


func _on_artifacts_pressed() -> void:
	_close_modals()
	for child in _artifact_list.get_children():
		child.queue_free()
	for artifact in RunState.artifacts:
		var row := Label.new()
		row.text = "%s (%s)\n%s" % [artifact.name,
			Enum.ArtifactRarity.keys()[artifact.rarity].capitalize(), artifact.description]
		row.add_theme_font_size_override("font_size", 26)
		_artifact_list.add_child(row)
	if RunState.artifacts.is_empty():
		var empty := Label.new()
		empty.text = "No artifacts yet."
		empty.add_theme_font_size_override("font_size", 26)
		_artifact_list.add_child(empty)
	_artifact_modal.show()


func _on_close_pressed() -> void:
	_close_modals()
