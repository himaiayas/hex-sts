class_name Smash
extends BaseCard


func _init() -> void:
	card_name = "Smash"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{render:0}"
	image = preload("res://assets/cards/cards/smash.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(0,1))
		]),
	]
