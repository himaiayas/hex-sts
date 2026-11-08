class_name EchoPower
extends BasePower

## The owner's next amount Attacks this turn are played twice, on the same cells and rotations
## (CombatState.play_card). Removed at the end of the owner's turn.


func _init(_amount := 1) -> void:
	super("Echo", "Your next Attack this turn is played twice.", _amount)


func get_description() -> String:
	return "Your next %s this turn %s played twice." % ["Attack" if amount == 1 else "%d Attacks" % amount, "is" if amount == 1 else "are"]


func on_trigger(trigger: Enum.Trigger, _combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_END:
		unit.statuses.erase(self)


## Uses up one stack of unit's Echo. False if it has none.
static func use(unit: CombatUnit) -> bool:
	for power in unit.statuses:
		if power is EchoPower:
			power.amount -= 1
			if power.amount <= 0:
				unit.statuses.erase(power)
			return true
	return false


func get_color() -> Color:
	return Color("#7fd6ff")
