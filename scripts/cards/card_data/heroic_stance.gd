class_name HeroicStance
extends BaseCard


func _init() -> void:
	card_name = "Heroic Stance"
	cost = 1
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	description = "[Self] {render:0}\n"
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ApplyEffectTile.new(Vector2i(0,0), HeroicTileEffect.new()),
		]),
	]
