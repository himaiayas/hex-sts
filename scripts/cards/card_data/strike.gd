class_name Strike
extends BaseCard


func _init() -> void:
	card_name = "Strike"
	cost = 1
	type = CardType.ATTACK
	description = "Deal 6 damage."
	tiles = [
		DamageTile.new(Vector2i(0,0)),
		DamageTile.new(Vector2i(0,1))
	]

func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i)->void:
	GridAction.new(BaseAction.TargetType.ENEMY, tiles).execute(combat, unit, cell)
