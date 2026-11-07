class_name SlimeAttack1 # this is just placeholder
extends BaseEnemyAction
func _init(_probability: float) -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Slime Attack 1", _probability)
	description = "Hit 2 tiles in a row."
	parts = [
		EnemyActionPart.new(Enum.Side.PLAYER, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
		]),
	]

func execute(combat: CombatState, _owner: CombatUnit) -> void:
	await GridAction.new(Enum.TargetType.PLAYER, parts[0].tiles).execute(combat, combat.player, parts[0].cell)
