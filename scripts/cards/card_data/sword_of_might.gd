class_name SwordOfMight
extends BaseCard


func _init() -> void:
	card_name = "Sword of Might"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{keyword:Sacrifice} 1.\n{render:1}."
	image = preload("res://assets/cards/cards/sword_of_might.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [SacrificeTile.new(Vector2i(0,0))], Vector2i.ZERO, true),
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(-1,0)),
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(2,0)),
			DamageTile.new(Vector2i(3,0)),
			DamageTile.new(Vector2i(4,0)),
			DamageTile.new(Vector2i(0,1)),
			DamageTile.new(Vector2i(1,-1)),

		]),
	]
