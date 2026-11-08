class_name XSlash
extends BaseCard


func _init() -> void:
	card_name = "X Slash"
	cost = 2
	max_augments = 2
	type = Enum.CardType.ATTACK
	description = "{render:0}\nThis card can equip 2 augments."
	image = preload("res://assets/cards/cards/x_slash.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(0,1)),
			DamageTile.new(Vector2i(0,2)),
			DamageTile.new(Vector2i(0,-1)),
			DamageTile.new(Vector2i(0,-2)),
			DamageTile.new(Vector2i(1,-1)),
			DamageTile.new(Vector2i(2,-2)),
			DamageTile.new(Vector2i(-1,1)),
			DamageTile.new(Vector2i(-2,2)),
		]),
	]
