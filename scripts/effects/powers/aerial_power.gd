class_name AerialPower
extends BasePower

## The first amount hits on its owner's live tiles each opponent turn miss, even on a Shield or with
## Pierce, and flash like a block. Hits during the owner's own turn always land.

var left := 0  # misses left this turn


func _init(_amount := 1) -> void:
	super("Aerial", "The first hit on it each of your turns misses, plus one more per extra Aerial. Shield and Pierce don't matter.", _amount)
	left = _amount


func get_description() -> String:
	return "Each of your turns, the first %s on it miss%s, even on a Shield or with Pierce." % [plural(amount, "hit"), "es" if amount == 1 else ""]


func on_trigger(trigger: Enum.Trigger, _combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_END:
		left = amount  # the opponent's turn comes next


## Uses one up.
func dodges(_combat: CombatState, unit: CombatUnit) -> bool:
	if left <= 0 or unit.in_turn:
		return false
	left -= 1
	return true


func get_color() -> Color:
	return HealthGridView.COLOR_SHIELDED
