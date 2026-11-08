class_name MultiHeadPower
extends BasePower

## amount = heads left. Losing CUT tiles during one opponent turn cuts off a head, at most one a turn.
## The owner reads amount for how many times it attacks; the badge flashes when a head goes.

const CUT := 10

var lost := 0  # tiles lost during the opponent's turn so far
var cut := false  # a head already went this turn


func _init(_amount := 1) -> void:
	super("Multi-head", "Attacks once per head. Losing %d tiles in one of your turns cuts off a head, once a turn." % CUT, _amount)


func get_description() -> String:
	return "%s left: attacks once per head. Losing %d tiles in one of your turns cuts one off, once a turn." % [plural(amount, "head"), CUT]


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	match trigger:
		Enum.Trigger.TURN_END:  # the opponent's turn comes next
			lost = 0
			cut = false
		Enum.Trigger.ON_HIT:
			if unit.in_turn:
				return
			lost += 1
			if lost >= CUT and not cut and amount > 0:
				amount -= 1
				cut = true
				combat.record(unit, Vector2i.ZERO, Enum.Change.POWER, self)


func get_color() -> Color:
	return HealthGridView.COLOR_PREVIEW
