class_name HallowedKnightPower
extends BasePower

## The first Attack costing 2 or more (printed cost) the owner plays each turn cleanses amount of
## their random tiles that have a debuff (CleanseTile).

var used := false  # already cleansed this turn


func _init(_amount := 1) -> void:
	super("Hallowed Knight", "The first time you play an Attack costing 2 or more each turn, Cleanse 1 random tile per Hallowed Knight.", _amount)


func get_description() -> String:
	return "The first time you play an Attack costing 2 or more each turn, Cleanse %s.%s" % [
		plural(amount, "random tile"), " (Used this turn.)" if used else ""]


func on_trigger(trigger: Enum.Trigger, _combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_START:
		used = false


func on_card_played(combat: CombatState, unit: CombatUnit, card: BaseCard) -> void:
	if used or card.type != Enum.CardType.ATTACK or card.cost < 2:
		return
	used = true
	var cleanse := CleanseTile.new(Vector2i.ZERO)
	var cells := unit.health.keys().filter(func(c: Vector2i) -> bool: return cleanse.can_inflict(unit, c))
	cells.shuffle()
	for cell in cells.slice(0, amount):
		cleanse.inflict(combat, unit, cell)


func get_color() -> Color:
	return Color("#f2e6a0")
