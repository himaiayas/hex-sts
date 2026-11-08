class_name ShiverPower
extends BasePower

## A debuff from the Lil Ghost: its owner's next card costs 1 more (CombatState.cost_of; an X-cost card
## gets 1 less X, CombatState.x_energy), then it goes away. Also gone when its owner's turn ends. Doesn't stack.


func _init(_amount := 1) -> void:
	super("Shiver", "Your next card costs 1 more.", _amount)


func on_trigger(trigger: Enum.Trigger, _combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_END:
		unit.statuses.erase(self)


func stack(_other: BaseEffect) -> void:
	pass


func get_color() -> Color:
	return Color("#8fb8de")
