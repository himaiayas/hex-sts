class_name Ethylene
extends BaseCard


func _init() -> void:
	card_name = "Ethylene"
	cost = 1
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.UNCOMMON
	target = Enum.TargetType.ENEMY
	description = "{render:0}\nIf this card hit 6 tiles, Draw 1 card."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(1,1)),
			DamageTile.new(Vector2i(2,-1)),
			DamageTile.new(Vector2i(0,-1)),
			DamageTile.new(Vector2i(-1,1)),
		]),
	]


## Hits: tiles the pattern lands on that aren't damaged yet, shielded ones included (the shield
## takes the hit). Counted before the attack, so Strength's extra tiles don't count.
func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var landed := 0
	for i in cells.size():
		for offset in grid_action(i).rotated(rotations[i]):
			var tile: HealthTile = units[i].health.get(cells[i] + offset)
			if tile and tile.hp != Enum.HealthTileEnum.DAMAGED:
				landed += 1
	var hits: Array = await super(combat, units, cells, rotations)
	if landed >= 6:
		DrawAction.new(Enum.TargetType.PLAYER, 1).execute(combat, combat.player, Vector2i.ZERO)
	return hits
