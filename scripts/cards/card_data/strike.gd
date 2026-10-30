class_name Strike
extends BaseCard


func _init() -> void:
	card_name = "Strike"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{render:0}\nDeal damage."
	image = preload("res://assets/cards/cards/strike.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(0,1))
		]),
	]
