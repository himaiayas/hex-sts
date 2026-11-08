class_name RegenPower
extends BasePower

## At the start of its owner's turn, heals amount random damaged tiles of its own. With a guard,
## it skips the heal if the owner lost guard or more tiles since its last turn.

var guard := 0  # 0 = always heals
var lost := 0  # tiles lost since the owner's last turn


func _init(_amount := 1, _guard := 0) -> void:
	super("Regen", "At the start of its turn, heals 1 damaged tile per Regen.", _amount)
	guard = _guard
	if guard > 0:
		description += " Not if it lost %d or more tiles since its last turn." % guard


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	match trigger:
		Enum.Trigger.ON_HIT:
			if not unit.in_turn:
				lost += 1
		Enum.Trigger.TURN_START:
			if guard == 0 or lost < guard:
				var heal := HealTile.new(Vector2i.ZERO)
				var cells := unit.health.keys().filter(func(c: Vector2i) -> bool: return heal.can_inflict(unit, c))
				cells.shuffle()
				for cell in cells.slice(0, amount):
					heal.inflict(combat, unit, cell)
			lost = 0


func get_color() -> Color:
	return HealthGridView.COLOR_HEAL
