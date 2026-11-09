@abstract class_name BaseCard
extends Resource


var card_name: String
var cost: int
var x_cost := false  # spends all your energy (cost is ignored); its one grid action is placed once per energy spent
var type: Enum.CardType
var target := Enum.TargetType.ENEMY  # ENEMY (default) or PLAYER
var image: Texture2D
var description: String
var rarity: Enum.CardRarity = Enum.CardRarity.COMMON
var exhaust := false  # goes to the exhaust pile after it's played, gone until the next fight
var retain := false  # stays in hand at the end of the turn
var to_draw_top := false  # goes on top of the draw pile after it's played, instead of the discard pile
var repeat := false  # its effect runs twice each time it's played (Duplication Augment)
var grid_actions: Array[BaseAction] = []  # each a GridAction, or a RepeatAction around one; drawn with {render:N}
var augments: Array[BaseAugment] = []  # applied upgrades, shown as icons above the card
var max_augments := 1  # raise for cards that say they hold more
var free_until_played := false  # costs 0 until it's played once (Mason's Trowel)
var free_on_turn := -1  # costs 0 on this combat turn (Sacred Blessing); see CombatState.cost_of


## units[i], cells[i], rotations[i] = the grid, cell and rotation chosen for grid_action(i), in order.
## Runs every grid action at its own cell and returns hits[i], the cells grid_action(i) changed.
## Override and call super() to add other actions, e.g. one that depends on the hits.
func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits := []
	for i in cells.size():
		hits.append(await grid_action(i).execute(combat, units[i], cells[i], rotations[i]))
	return hits


## Card-specific rule for playing it, checked on top of energy and placement (CombatState.can_play).
## Override for cards that need something, e.g. another card in hand to exhaust.
## The card itself is still in combat.hand while this is checked.
func can_play(_combat: CombatState) -> bool:
	return true


## Called on every card in the fight whenever a card is exhausted (combat.exhausted_this_combat).
## A card whose look changes should call emit_changed() so the hand redraws it.
func on_card_exhausted(_combat: CombatState) -> void:
	pass


## This fight's copy of a deck card, keeping what augments changed (cost, exhaust, repeat, added
## tiles). Resource.duplicate() would rebuild it from _init, since script vars aren't stored.
## Arrays are copied, but the GridActions in them are shared: combat replaces them, never edits them.
func copy() -> BaseCard:
	var result: BaseCard = get_script().new()
	for property in get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var value: Variant = get(property.name)
			result.set(property.name, value.duplicate() if value is Array or value is Dictionary else value)
	return result


## The grid action click i places: placements()[i], or the only one, again, on an X-cost card.
func grid_action(i: int) -> GridAction:
	return pattern(0) if x_cost else placements()[i]


## The pattern of grid_actions[i]: the action itself, or the GridAction a RepeatAction repeats.
func pattern(i: int) -> GridAction:
	var action := grid_actions[i]
	return action.action if action is RepeatAction else action


## Clicks it takes to play with energy left: one per placement, or one per energy on an X-cost card.
func clicks(energy: int) -> int:
	return energy if x_cost else placements().size()


## grid_actions in click order, with each RepeatAction's action listed once per repeat.
func placements() -> Array[GridAction]:
	var result: Array[GridAction] = []
	for i in grid_actions.size():
		var times: int = grid_actions[i].times if grid_actions[i] is RepeatAction else 1
		for t in times:
			result.append(pattern(i))
	return result


## description, kept in step with exhaust and repeat when an augment changed them: a closing
## "{keyword:Exhaust}." is added or removed, and "{keyword:Repeat}." added.
func get_description() -> String:
	var text := description
	var exhaust_line := _EXHAUST_END.search(text)
	if exhaust_line and not exhaust:
		text = text.substr(0, exhaust_line.get_start())
	elif exhaust and not exhaust_line:
		text += "\n{keyword:Exhaust}."
	if repeat:
		text += "\n{keyword:Repeat}."
	return text


## A description's closing "{keyword:Exhaust}." (the card's own Exhaust), with the space or line before it.
static var _EXHAUST_END := RegEx.create_from_string("\\s*\\{keyword:Exhaust\\}\\.$")
