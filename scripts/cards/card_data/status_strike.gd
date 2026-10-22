class_name StatusStrike
extends BaseCard


func _init() -> void:
	card_name = "StatusStrike"
	cost = 3
	type = CardType.ATTACK
	description = "fdksmfdf."
	tiles = [
		DamageTile.new(Vector2i(0,0)),
		ApplyEffectTile.new(Vector2i(1,2), PoisonTileEffect.new())
	]

func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i)->void:
	GridAction.new(BaseAction.TargetType.ENEMY, tiles).execute(combat, unit, cell)
