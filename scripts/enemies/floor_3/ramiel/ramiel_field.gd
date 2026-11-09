class_name RamielField
extends EnemyField

## Ramiel's Absolute Terror Field: tops its Shields back up (EnemyField) and puts AT Field on its most
## central undamaged tile that doesn't have one yet, so the protected core grows each time. That tile
## is planned with the Shields, so it shows on Ramiel's grid with the intent.


func _init(_name: String, _amount: int) -> void:
	super(_name, _amount)
	description = "Shield its own tiles until it has %d Shields, and put AT Field on its most central tile without one." % amount


func plan(combat: CombatState, owner: CombatUnit) -> void:
	super(combat, owner)
	var center := central_tile(owner)
	if center != Vector2i.MAX:
		parts[0].tiles.append(ApplyEffectTile.new(center, AtFieldTileEffect.new()))


## The undamaged tile without AT Field nearest the middle of unit's whole shape, or Vector2i.MAX if none.
static func central_tile(unit: CombatUnit) -> Vector2i:
	var middle := Vector2.ZERO
	for cell: Vector2i in unit.health:
		middle += HealthGridView.axial_to_pixel(cell, 1.0)
	middle /= unit.health.size()
	var best := Vector2i.MAX
	var best_distance := INF
	for cell: Vector2i in unit.health:
		if unit.health[cell].hp == Enum.HealthTileEnum.DAMAGED or unit.health[cell].has_effect(AtFieldTileEffect):
			continue
		var distance := HealthGridView.axial_to_pixel(cell, 1.0).distance_squared_to(middle)
		if distance < best_distance:
			best_distance = distance
			best = cell
	return best


## At the start of the fight (no combat yet to record it): AT Field on the most central tile.
static func field_start(unit: CombatUnit) -> void:
	var center := central_tile(unit)
	if center != Vector2i.MAX:
		unit.health[center].status_effects.append(AtFieldTileEffect.new())
