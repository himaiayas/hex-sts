class_name RetaliatePower
extends BasePower

## Each hit a Shield absorbs on the owner's grid, during someone else's turn, damages amount random
## undamaged tiles of the attacker (a Shield there absorbs it as usual; Strength doesn't add to it).
## Removed at the start of the owner's next turn.


func _init(_amount := 1) -> void:
	super("Retaliate", "When your Shield absorbs a hit, damage 1 random tile of the attacker per Retaliate. Ends at the start of your next turn.", _amount)


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	match trigger:
		Enum.Trigger.TURN_START:
			unit.statuses.erase(self)
		Enum.Trigger.ON_BLOCK:
			var attacker := combat.acting_unit()
			if attacker == null or attacker == unit:
				return
			var open := attacker.health.keys().filter(func(c: Vector2i) -> bool:
				return attacker.health[c].hp != Enum.HealthTileEnum.DAMAGED)
			open.shuffle()
			for cell in open.slice(0, amount):
				attacker.damage_health_tile(combat, cell)


func get_color() -> Color:
	return Color("#e0b040")
