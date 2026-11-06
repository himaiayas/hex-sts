class_name Sunder
extends BaseCard


func _init() -> void:
	card_name = "Sunder"
	cost = 2
	type = Enum.CardType.ATTACK
	description = "{render:0}\n{keyword:Pierce} the whole row."
	grid_actions = [
		LineGridAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO, true)),
	]
