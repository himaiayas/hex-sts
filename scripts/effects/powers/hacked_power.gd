class_name HackedPower
extends BasePower

## A debuff from the Hacker AI: right after its owner draws their next hand, a random card in it is
## Exhausted (CombatState.start_turn reads it). It stays until that turn ends. Doesn't stack.


func _init(_amount := 1) -> void:
	super("Hacked", "A random card in your next hand is Exhausted.", _amount)


func on_trigger(trigger: Enum.Trigger, _combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_END:
		unit.statuses.erase(self)


func stack(_other: BaseEffect) -> void:
	pass


func get_color() -> Color:
	return Color("#4fd18b")
