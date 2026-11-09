class_name SpearOfDestiny
extends BaseCard


func _init() -> void:
	card_name = "Spear of Destiny"
	cost = 3
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.RARE
	target = Enum.TargetType.ENEMY
	description = "{render:0} twice\n{render:1}\nIf this card hit 10 tiles, gain 1 energy."
	image = preload("res://assets/cards/cards/spear_of_destiny.png")
	grid_actions = [
        RepeatAction.new(GridAction.new(Enum.TargetType.ENEMY, [
			ApplyEffectTile.new(Vector2i(0,0), FractureTileEffect.new()),
		]), 2),
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,-1)),
			DamageTile.new(Vector2i(2,-1)),
			DamageTile.new(Vector2i(3,-1)),
			DamageTile.new(Vector2i(4,-1)),
            DamageTile.new(Vector2i(0,1)),
			DamageTile.new(Vector2i(1,1)),
			DamageTile.new(Vector2i(2,1)),
			DamageTile.new(Vector2i(3,1)),
            DamageTile.new(Vector2i(-1,0)),
            DamageTile.new(Vector2i(-2,0)),
            DamageTile.new(Vector2i(-3,0)),
            DamageTile.new(Vector2i(-4,0)),
            DamageTile.new(Vector2i(-5,0)),
            DamageTile.new(Vector2i(-6,0)),

			
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
	if landed >= 10:
		GainEnergyAction.new(Enum.TargetType.PLAYER, 1).execute(combat, combat.player, Vector2i.ZERO)
	return hits
