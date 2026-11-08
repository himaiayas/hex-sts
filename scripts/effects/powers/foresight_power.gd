class_name ForesightPower
extends BasePower

## At the start of the player's turn, draws amount more cards. Lasts the whole fight.


func _init(_amount := 1) -> void:
	super("Foresight", "At the start of your turn, draw 1 more card per Foresight.", _amount)


func get_description() -> String:
	return "At the start of your turn, draw %d more card%s." % [amount, "" if amount == 1 else "s"]


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_START and unit.is_player:
		combat.draw(amount)


func get_color() -> Color:
	return Color("#b8a4ff")
