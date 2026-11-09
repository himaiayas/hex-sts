class_name Slash
extends BaseCard


func _init() -> void:
	card_name = "Slash"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{render:0}"
	image = preload("res://assets/cards/cards/slash.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			# DamageTile.new(Vector2i(0,0)),
			# DamageTile.new(Vector2i(1,0)),
			# DamageTile.new(Vector2i(-1,0)),
			# DamageTile.new(Vector2i(0,1)),
			# DamageTile.new(Vector2i(0,-1)),
			# DamageTile.new(Vector2i(1,-1)),
			# DamageTile.new(Vector2i(-1,1)),

			# DamageTile.new(Vector2i(0,0)),
			# DamageTile.new(Vector2i(1,0)),
			# DamageTile.new(Vector2i(-1,0)),
			# DamageTile.new(Vector2i(0,-1)),
			# DamageTile.new(Vector2i(-1,1)),
			# DamageTile.new(Vector2i(2,0)),
			# DamageTile.new(Vector2i(3,0)),
			# DamageTile.new(Vector2i(4,0))
			

			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(2,0)),
			DamageTile.new(Vector2i(-1,0))


		]),
	]
