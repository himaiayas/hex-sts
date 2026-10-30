class_name ShieldPlayer
extends BaseCard


func _init() -> void:
	card_name = "Shield"
	cost = 1
	type = Enum.CardType.DEFENSE
	target = Enum.TargetType.PLAYER
	description = "{render:0}\nShield a tile on your grid."
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ShieldTile.new(Vector2i(0,0)),
		]),
	]
