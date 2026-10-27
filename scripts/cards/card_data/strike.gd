class_name Strike
extends BaseCard


func _init() -> void:
	card_name = "Strike"
	cost = 1
	type = CardType.ATTACK
	description = "{render:0}\nDeal damage."
	grid_actions = [
		GridAction.new(BaseAction.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(0,1))
		]),
	]
