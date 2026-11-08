class_name ChronicSunburnPower
extends BasePower

## At the start of its owner's turn, Fractures amount random enemy tiles (undamaged, not Fractured yet),
## picked from every living enemy together.


func _init(_amount := 1) -> void:
	super("Chronic Sunburn", "At the start of your turn, apply Fracture to 1 random enemy tile per Chronic Sunburn.", _amount)


func get_description() -> String:
	return "At the start of your turn, apply Fracture to %s." % plural(amount, "random enemy tile")


func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger != Enum.Trigger.TURN_START:
		return
	var pool := []  # [enemy, cell]
	for enemy in combat.enemies:
		if enemy.is_dead():
			continue
		for cell: Vector2i in enemy.health:
			var tile: HealthTile = enemy.health[cell]
			if tile.hp != Enum.HealthTileEnum.DAMAGED and not tile.has_effect(FractureTileEffect):
				pool.append([enemy, cell])
	pool.shuffle()
	for pick in pool.slice(0, amount):
		pick[0].apply_effect_health_tile(combat, pick[1], FractureTileEffect.new())


func get_color() -> Color:
	return Color("#ff8c42")
