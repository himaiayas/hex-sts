class_name Jab
extends BaseCard


func _init() -> void:
	card_name = "Jab"
	cost = 0
	type = Enum.CardType.ATTACK
	to_draw_top = true
	description = "{render:0}\nPut this on top of your draw pile."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
		]),
	]
