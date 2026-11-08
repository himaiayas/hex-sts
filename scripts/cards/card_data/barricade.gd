class_name Barricade
extends BaseCard


func _init() -> void:
	card_name = "Barricade"
	cost = 1
	type = Enum.CardType.DEFENSE
	rarity = Enum.CardRarity.UNCOMMON
	target = Enum.TargetType.PLAYER
	description = "{render:0}\n{render:1}"
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ShieldTile.new(Vector2i(0,0)),
			ShieldTile.new(Vector2i(0,1)),
			ShieldTile.new(Vector2i(-1,0)),
		]),
		GridAction.new(Enum.TargetType.PLAYER, [
			ApplyEffectTile.new(Vector2i(0,0), PlateTileEffect.new()),
		]),
	]
