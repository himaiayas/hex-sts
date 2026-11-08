class_name CurseWrapPower
extends BasePower

## A debuff from the Mummy: its owner's next Defense card places amount fewer Shield or Plate tiles
## (the first ones fizzle), then it goes away. Also gone when its owner's turn ends. Doesn't stack.


func _init(_amount := 1) -> void:
	super("Curse Wrap", "Your next Defense card places 1 fewer Shield or Plate per Curse Wrap.", _amount)


func get_description() -> String:
	return "Your next Defense card places %d fewer Shield or Plate." % amount


## True if a Shield or Plate about to go on unit's tile fizzles. Uses one up.
static func fizzles(combat: CombatState, unit: CombatUnit) -> bool:
	var card := combat.playing
	if card == null or card.type != Enum.CardType.DEFENSE:
		return false
	for power in unit.statuses:
		if power is CurseWrapPower and power.amount > 0:
			power.amount -= 1
			return true
	return false


func on_trigger(trigger: Enum.Trigger, _combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_END:
		unit.statuses.erase(self)


func on_card_played(_combat: CombatState, unit: CombatUnit, card: BaseCard) -> void:
	if card.type == Enum.CardType.DEFENSE:
		unit.statuses.erase(self)


func stack(_other: BaseEffect) -> void:
	pass


func get_color() -> Color:
	return Color("#c9b98a")
