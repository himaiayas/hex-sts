class_name WardPower
extends BasePower

## At the start of the owner's turn, shields amount random undamaged, unshielded tiles. Lasts the whole fight.
## Powers fire before tile effects, so it shields before Poison explodes: a Poisoned tile is pierced anyway,
## but a shielded neighbour absorbs the explosion's hit.


func _init(_amount := 1) -> void:
	super("Ward", "At the start of your turn, Shield 1 random tile per Ward.", _amount)


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger != Enum.Trigger.TURN_START:
		return
	var shield := ShieldTile.new(Vector2i.ZERO)
	var open := unit.health.keys().filter(func(c: Vector2i) -> bool: return shield.can_inflict(unit, c))
	open.shuffle()
	for cell in open.slice(0, amount):
		shield.inflict(combat, unit, cell)


func get_color() -> Color:
	return HealthGridView.COLOR_SHIELDED
