class_name Boomerang
extends BaseCard


func _init() -> void:
	card_name = "Boomerang"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{render:0} twice."
	image = preload("res://assets/cards/cards/boomerang.png")
	grid_actions = [
		RepeatAction.new(GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
		]), 2),
	]
