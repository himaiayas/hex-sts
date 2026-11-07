class_name DraculaBatSwarm
extends BaseEnemyAction

## Hit 3 x4: four bats, each a 3-hex triangle on a random spot of the player's grid.


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Bat Swarm", 1.0)
	hit_vfx = preload("res://assets/enemies/floor_2/dracula_attack_bat.png")
	for i in 4:
		parts.append(EnemyActionPart.new(Enum.Side.PLAYER, [
			DamageTile.new(Vector2i(0, 0)),
			DamageTile.new(Vector2i(1, 0)),
			DamageTile.new(Vector2i(0, 1)),
		]))


func pick_cell(part: EnemyActionPart, target: CombatUnit) -> Vector2i:
	return pick_random_cell(part, target)


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	for part in parts:
		await GridAction.new(Enum.TargetType.PLAYER, part.tiles).execute(combat, combat.player, part.cell)
