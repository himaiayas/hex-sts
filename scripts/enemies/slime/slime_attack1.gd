class_name SlimeAttack1 # this is just placeholder
extends BaseEnemyAction
func _init(_probability: float) -> void:
	super(BaseEnemyActionEnum.ATTACK, "Slime Attack 1", _probability)
	parts = [
		EnemyActionPart.new(EnemyActionPart.Side.PLAYER, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
		]),
	]

func execute(combat: CombatState, _owner: CombatUnit) -> void:
	GridAction.new(BaseAction.TargetType.PLAYER, parts[0].tiles).execute(combat, combat.player, parts[0].cell)
