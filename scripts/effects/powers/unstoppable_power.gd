class_name UnstoppablePower
extends BasePower

## At the start of its owner's turn, gives them amount Strength (stacks: two Unstoppables give 2).


func _init(_amount := 1) -> void:
	super("Unstoppable", "At the start of your turn, gain 1 Strength per Unstoppable.", _amount)


func get_description() -> String:
	return "At the start of your turn, gain %d Strength." % amount


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_START:
		unit.add_power(combat, StrengthPower.new(amount))


func get_color() -> Color:
	return Color("#e0503c")
