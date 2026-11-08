class_name Glock
extends BaseCard


func _init() -> void:
	card_name = "Glock"
	cost = 1
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.LEGENDARY
	description = "{render:0} 9 times."
	grid_actions = [
		RepeatAction.new(GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
		]), 9),
	]
