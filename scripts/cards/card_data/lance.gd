class_name Lance
extends BaseCard


func _init() -> void:
	card_name = "Lance"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{render:0}\n{keyword:Pierce}."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0), true),
			DamageTile.new(Vector2i(1,0), true),
		]),
	]
