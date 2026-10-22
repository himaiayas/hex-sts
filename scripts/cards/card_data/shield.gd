class_name ShieldPlayer
extends BaseCard


func _init() -> void:
	card_name = "Shield"
	cost = 1
	type = CardType.DEFENSE
	target = BaseAction.TargetType.PLAYER
	description = "Shield a tile on your grid."
	tiles = [
		ShieldTile.new(Vector2i(0,0)),
	]

func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i)->void:
	GridAction.new(BaseAction.TargetType.PLAYER, tiles).execute(combat, unit, cell)
