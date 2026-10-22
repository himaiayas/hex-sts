class_name SlimeHarden
extends BaseEnemyAction
## Shields three cells of the slime's own grid.
func _init(_probability: float) -> void:
	super(BaseEnemyActionEnum.DEFEND, "Harden", _probability)
	parts = [
		EnemyActionPart.new(EnemyActionPart.Side.SELF, [
			ShieldTile.new(Vector2i(0,0)),
			ShieldTile.new(Vector2i(1,0)),
			ShieldTile.new(Vector2i(0,1)),
		]),
	]

func execute(combat: CombatState, owner: CombatUnit) -> void:
	GridAction.new(BaseAction.TargetType.ENEMY, parts[0].tiles).execute(combat, owner, parts[0].cell)
