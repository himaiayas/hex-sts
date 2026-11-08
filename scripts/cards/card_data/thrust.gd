class_name Thrust
extends BaseCard


func _init() -> void:
	card_name = "Thrust"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{render:0}"
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i.ZERO, true),
			DamageTile.new(Vector2i(1,0), true)			
		]),
	]
