class_name SteadyGuard
extends BaseCard


func _init() -> void:
	card_name = "Steady Guard"
	cost = 1
	type = Enum.CardType.DEFENSE
	target = Enum.TargetType.PLAYER
	retain = true
	description = "{render:0}\n{keyword:Retain}."
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ShieldTile.new(Vector2i(0,0)),
			ShieldTile.new(Vector2i(1,0)),
		]),
	]
