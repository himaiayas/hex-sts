class_name Sweep
extends BaseCard


func _init() -> void:
	card_name = "Sweep"
	cost = 1
	type = Enum.CardType.ATTACK
	pick_from_discard = 1
	description = "{render:0}\nPut a card from your discard pile on top of your draw pile."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(-1,0)),

		]),
	]
