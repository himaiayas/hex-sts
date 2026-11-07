class_name SlimeHarden
extends BaseEnemyAction
## Plates three cells of the slime's own grid.
func _init(_probability: float) -> void:
	super(Enum.BaseEnemyActionEnum.DEFEND, "Harden", _probability)
	description = "Plate 3 of its own tiles."
	parts = [
		EnemyActionPart.new(Enum.Side.SELF, [
			ApplyEffectTile.new(Vector2i(0,0), PlateTileEffect.new()),
			ApplyEffectTile.new(Vector2i(1,0), PlateTileEffect.new()),
			ApplyEffectTile.new(Vector2i(0,1), PlateTileEffect.new()),
		]),
	]

func execute(combat: CombatState, owner: CombatUnit) -> void:
	await GridAction.new(Enum.TargetType.ENEMY, parts[0].tiles).execute(combat, owner, parts[0].cell)
