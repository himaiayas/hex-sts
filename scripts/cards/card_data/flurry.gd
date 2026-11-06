class_name Flurry
extends BaseCard


func _init() -> void:
	card_name = "Flurry"
	x_cost = true
	type = Enum.CardType.ATTACK
	description = "{render:0}\nX times."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
		]),
	]
