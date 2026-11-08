class_name DragonFireBreath
extends BaseEnemyAction

## Hit 14 in a cone, narrow end up-right toward the Dragon. In P2 it's Inferno, which pierces.


func _init(pierce := false) -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Inferno" if pierce else "Fire Breath", 1.0)
	description = "Hit 14 tiles in a cone with Pierce." if pierce else "Hit 14 tiles in a cone."
	pose = preload("res://assets/enemies/floor_1/dragon_attack_fire_breath.png")
	var cone: Array[BaseActionTile] = []
	# One diagonal per width, 2 to 5 tiles.
	for q in 4:
		for r in q + 2:
			cone.append(DamageTile.new(Vector2i(-q, r), pierce))
	parts = [EnemyActionPart.new(Enum.Side.PLAYER, cone)]


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	await GridAction.new(Enum.TargetType.PLAYER, parts[0].tiles).execute(combat, combat.player, parts[0].cell)
