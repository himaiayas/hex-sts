class_name Mend
extends BaseCard


func _init() -> void:
	card_name = "Mend"
	cost = 1
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	exhaust = true
	pick_tiles = 2
	pick_tile = HealTile.new(Vector2i.ZERO)
	description = "{keyword:Heal} 2 of your tiles.\n{keyword:Exhaust}."
