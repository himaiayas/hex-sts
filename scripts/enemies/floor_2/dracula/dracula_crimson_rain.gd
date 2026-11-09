class_name DraculaCrimsonRain
extends BaseEnemyAction

## Hit 6 x3 (P2): three waves on random spots of the player's grid. Each wave is two
## slanted 3-hex lines, like falling rain.


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Crimson Rain", 1.0)
	heavy_impact = true
	description = "Hit 6 tiles 3 times."
	hit_vfx = preload("res://assets/enemies/floor_2/dracula_attack_rain.png")
	for i in 3:
		var drops: Array[BaseActionTile] = []
		for x in [0, 2]:
			for k in 3:
				drops.append(DamageTile.new(Vector2i(x - k, k)))
		parts.append(EnemyActionPart.new(Enum.Side.PLAYER, drops))


func pick_cell(part: EnemyActionPart, target: CombatUnit) -> Vector2i:
	return pick_random_cell(part, target)


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	for part in parts:
		await GridAction.new(Enum.TargetType.PLAYER, part.tiles).execute(combat, combat.player, part.cell)
