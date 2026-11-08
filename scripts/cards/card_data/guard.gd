class_name Guard
extends BaseCard


func _init() -> void:
	card_name = "Guard"
	cost = 1
	type = Enum.CardType.DEFENSE
	target = Enum.TargetType.PLAYER
	description = "{render:0}"
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ShieldTile.new(Vector2i(0,0)),
			ShieldTile.new(Vector2i(1,0)),
		]),
	]
