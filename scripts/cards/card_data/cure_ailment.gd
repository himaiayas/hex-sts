class_name CureAilment
extends BaseCard


func _init() -> void:
	card_name = "Cure Ailment"
	cost = 1
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	description = "[Self] {render:0}\n"
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			CleanseTile.new(Vector2i(0,0)),
			CleanseTile.new(Vector2i(-1,0)),
			CleanseTile.new(Vector2i(0,1)),
			CleanseTile.new(Vector2i(1,-1))		
		]),
	]
