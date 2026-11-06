class_name LastLight
extends BaseCard


func _init() -> void:
	card_name = "Last Light"
	cost = 1
	type = Enum.CardType.ATTACK
	exhaust = true
	description = "{render:0}\n{keyword:Exhaust}."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(0,1)),
			DamageTile.new(Vector2i(1,-1)),
		]),
	]
