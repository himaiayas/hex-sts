class_name LivingWallPower
extends BasePower

## Whenever one of the owner's tiles gains Plate (it didn't have it yet), damages amount random
## enemy tiles that aren't damaged, picked from every living enemy together. A shield there blocks it.


func _init(_amount := 1) -> void:
	super("Living Wall", "Whenever you gain Plate, deal damage to 1 random enemy tile per Living Wall.", _amount)


func get_description() -> String:
	return "Whenever you gain Plate, deal damage to %s." % plural(amount, "random enemy tile")


func on_tile_effect_gained(combat: CombatState, _unit: CombatUnit, _cell: Vector2i, effect: BaseTileEffect) -> void:
	if not effect is PlateTileEffect:
		return
	var pool := []  # [enemy, cell]
	for enemy in combat.enemies:
		if enemy.is_dead():
			continue
		for cell: Vector2i in enemy.health:
			if enemy.health[cell].hp != Enum.HealthTileEnum.DAMAGED:
				pool.append([enemy, cell])
	pool.shuffle()
	for pick in pool.slice(0, amount):
		pick[0].damage_health_tile(combat, pick[1])


func get_color() -> Color:
	return Color("#b8b8c8")
