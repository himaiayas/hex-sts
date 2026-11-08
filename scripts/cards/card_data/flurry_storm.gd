class_name FlurryStorm
extends BaseCard


func _init() -> void:
	card_name = "Flurry Storm"
	x_cost = true
	type = Enum.CardType.ATTACK
	description = "{render:0}\nX times."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0), true),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(-1,0)),

		]),
	]
