class_name RisePower
extends BasePower

## The first time its owner dies, it heals amount random tiles at once and goes away.


func _init(_amount := 1) -> void:
	super("Rise", "The first time it dies, it comes back with 1 tile per Rise.", _amount)


func get_description() -> String:
	return "The first time it dies, it comes back with %s." % plural(amount, "tile")


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger != Enum.Trigger.ON_HIT or not unit.is_dead():
		return
	unit.statuses.erase(self)
	var cells := unit.health.keys()
	cells.shuffle()
	for cell in cells.slice(0, amount):
		unit.heal_health_tile(combat, cell)
	combat.record(unit, Vector2i.ZERO, Enum.Change.POWER, self)


func get_color() -> Color:
	return HealthGridView.COLOR_HEAL
