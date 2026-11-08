class_name GreatWall
extends BaseCard


func _init() -> void:
	card_name = "Great Wall"
	cost = 2
	type = Enum.CardType.DEFENSE
	rarity = Enum.CardRarity.RARE
	description = "Apply {keyword:Shield} the entire row."
	grid_actions = [
		LineGridAction.new(Enum.TargetType.PLAYER, ShieldTile.new(Vector2i.ZERO)),
	]
