class_name Guard
extends BaseCard


func _init() -> void:
	card_name = "Guard"
	cost = 1
	type = Enum.CardType.DEFENSE
	rarity = Enum.CardRarity.STARTER
	target = Enum.TargetType.PLAYER
	description = "{render:0}"
	image = preload("res://assets/cards/cards/guard.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ShieldTile.new(Vector2i(0,0)),
			ShieldTile.new(Vector2i(1,0)),
		]),
	]
