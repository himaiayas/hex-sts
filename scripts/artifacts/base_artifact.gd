@abstract class_name BaseArtifact
extends Resource

## A relic the player keeps for the whole run (RunState.artifacts).
## Reacts to the player's triggers, like a power that never runs out. Override the hooks it needs;
## each is called on every artifact the player owns. Pick it up with RunState.add_artifact().

var name: String
var description: String
var rarity: Enum.ArtifactRarity
var image: Texture2D  # shown wherever the artifact is (256x256)

const PLACEHOLDER_IMAGE := preload("res://assets/artifacts/placeholder.png")
const DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]

func _init(_name: String, _description: String, _rarity: Enum.ArtifactRarity,
		_image: Texture2D = PLACEHOLDER_IMAGE) -> void:
	name = _name
	description = _description
	rarity = _rarity
	image = _image


## {keyword:Plate} (or {keyword:Exhaust|Exhausted}) in a description: shown coloured, with a hover
## panel explaining it. See Keywords.markup.
const COLOR_KEYWORD := Color(1, 0.831373, 0.352941)  # as on cards (RenderCard.COLOR_KEYWORD)


## description with each {keyword:X} as plain X, for tooltips and Labels.
func plain_description() -> String:
	return Keywords.markup(description)


## description as BBCode for a RichTextLabel, keywords coloured as on cards.
func bbcode_description() -> String:
	return Keywords.markup(description, "[color=#%s]" % COLOR_KEYWORD.to_html(false), "[/color]")


## HoverInfo entries: the artifact itself, then each keyword in its description.
func hover_entries() -> Array:
	var entries := [[name, plain_description(), null]]
	var seen: Array[String] = []
	for keyword in Keywords.names_in(description):
		var text := Keywords.describe(keyword)
		if keyword not in seen and not text.is_empty():
			seen.append(keyword)
			entries.append([keyword, text, null])
	return entries


## Just the keyword entries, for places that already show the description.
func keyword_entries() -> Array:
	return hover_entries().slice(1)


## Once, when the player gets it (RunState.add_artifact).
func on_pickup() -> void:
	pass


## unit is always the player. cell is the tile hit/blocked on ON_HIT/ON_BLOCK. Awaited on turn
## triggers, so it may ask the player to pick (combat.choose_cards).
func on_trigger(_trigger: Enum.Trigger, _combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	pass


## After each card the player plays has resolved. combat.played_this_turn already holds it.
func on_card_played(_combat: CombatState, _card: BaseCard) -> void:
	pass


## Extra times card runs when played (Echo Bell). Asked after its first run.
func extra_plays(_combat: CombatState, _card: BaseCard) -> int:
	return 0


## Whenever a card is exhausted. combat.exhausted_this_combat already counts it.
func on_card_exhausted(_combat: CombatState, _card: BaseCard) -> void:
	pass


## A player tile got a tile effect it didn't have.
func on_tile_effect_gained(_combat: CombatState, _cell: Vector2i, _effect: BaseTileEffect) -> void:
	pass


## A power the player is about to gain; change it in place (Spiked Gauntlet).
func modify_power(_power: BaseEffect) -> void:
	pass


## At the end of the player's turn, before the hand is discarded. Awaited.
func before_discard(_combat: CombatState) -> void:
	pass


## After one of the player's attacks: landed = [unit, cell] of its damage tiles on the grid.
## Returns the extra cells it damaged (Eagle Eye).
func on_attack_landed(_combat: CombatState, _landed: Array) -> Array[Vector2i]:
	return []


## The player just lost their last tile. True if this saved them (Phoenix Feather).
func revive(_combat: CombatState, _unit: CombatUnit) -> bool:
	return false


## The fight is won; combat.player.health is about to become the run's.
func on_combat_end(_combat: CombatState) -> void:
	pass


## The player's cells whose tile passes keep, shuffled.
static func player_cells(combat: CombatState, keep: Callable) -> Array:
	var cells := combat.player.health.keys().filter(func(c: Vector2i) -> bool: return keep.call(combat.player.health[c]))
	cells.shuffle()
	return cells


## [enemy, cell] of every living enemy's tile that passes keep, shuffled.
static func enemy_cells(combat: CombatState, keep: Callable) -> Array:
	var pool := []
	for enemy in combat.enemies:
		if enemy.is_dead():
			continue
		for cell: Vector2i in enemy.health:
			if keep.call(enemy.health[cell]):
				pool.append([enemy, cell])
	pool.shuffle()
	return pool


static func undamaged(tile: HealthTile) -> bool:
	return tile.hp != Enum.HealthTileEnum.DAMAGED
