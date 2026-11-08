class_name WrappedPower
extends BasePower

## Every other hit of the first Attack card each opponent turn misses (half its damage, rounded up for
## the attacker), and flashes like a block.

var _first: BaseCard  # the first Attack card this turn
var _hits := 0


func _init(_amount := 1) -> void:
	super("Wrapped", "The first Attack card each of your turns deals half damage to it: every other hit misses.", _amount)


func on_trigger(trigger: Enum.Trigger, _combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_END:  # the opponent's turn comes next
		_first = null
		_hits = 0


func dodges(combat: CombatState, _unit: CombatUnit) -> bool:
	var card := combat.playing
	if card == null or card.type != Enum.CardType.ATTACK:
		return false
	if _first == null:
		_first = card
	if card != _first:
		return false
	_hits += 1
	return _hits % 2 == 0


func get_color() -> Color:
	return Color("#d8c9a0")
