class_name Mend
extends BaseCard


func _init() -> void:
	card_name = "Mend"
	cost = 1
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	exhaust = true
	description = "{render:0}\n{keyword:Exhaust}."
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			HealTile.new(Vector2i(0,0)),
			HealTile.new(Vector2i(1,0))
		]),
	]
