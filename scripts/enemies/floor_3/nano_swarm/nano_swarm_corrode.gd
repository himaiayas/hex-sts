class_name NanoSwarmCorrode
extends EnemyHit

## Hit 2 x4, scattered. Removes Plate from the tiles each hit covers first, so a Shield there
## still blocks once but won't come back.


func _init() -> void:
	var pair: Array[BaseActionTile] = [DamageTile.new(Vector2i(0, 0)), DamageTile.new(Vector2i(1, 0))]
	super("Corrode", "Hit 2 tiles 4 times and remove their Plate.", pair, 4)


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	for part in parts:
		for t in part.tiles:
			PlateTileEffect.strip(combat, combat.player, part.cell + t.coords)
		await combat.flush()
		await GridAction.new(Enum.TargetType.PLAYER, part.tiles).execute(combat, combat.player, part.cell)
