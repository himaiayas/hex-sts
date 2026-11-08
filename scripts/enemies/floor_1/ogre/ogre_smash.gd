class_name OgreSmash
extends BaseEnemyAction

## Hit 12 in a 3 x 4 block, on the target its Wind-up locked. Removes Plate from every tile it
## covers first, so a Shield there still blocks once but won't come back.


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Smash", 1.0)
	description = "Hit 12 tiles in a 3x4 block and remove their Plate."
	var block: Array[BaseActionTile] = []
	for r in 3:
		for q in 4:
			block.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))  # rows line up, not slant
	parts = [EnemyActionPart.new(Enum.Side.PLAYER, block)]


func plan(_combat: CombatState, _owner: CombatUnit) -> void:
	pass  # already aimed by the Wind-up


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	var player := combat.player
	for t in parts[0].tiles:
		var cell := parts[0].cell + t.coords
		if not player.health.has(cell):
			continue
		for effect in player.health[cell].status_effects.duplicate():
			if effect is PlateTileEffect:
				player.health[cell].status_effects.erase(effect)
				combat.record(player, cell, Enum.Change.EFFECT_LOST, effect)
	await combat.flush()
	await GridAction.new(Enum.TargetType.PLAYER, parts[0].tiles).execute(combat, player, parts[0].cell)
