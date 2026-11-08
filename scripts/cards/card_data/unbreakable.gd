class_name Unbreakable
extends BaseCard


func _init() -> void:
	card_name = "Unbreakable"
	cost = 1
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.RARE
	description = "{render:0} twice.\n{keyword:Exhaust}."
	image = preload("res://assets/cards/cards/unbreakable.png")
	exhaust = true
	grid_actions = [
		RepeatAction.new(GridAction.new(Enum.TargetType.PLAYER, [
            ApplyEffectTile.new(Vector2i(0,0), PlateTileEffect.new()),
            ApplyEffectTile.new(Vector2i(1,0), PlateTileEffect.new()),
            ApplyEffectTile.new(Vector2i(0,1), PlateTileEffect.new()),
		]), 2),
	]
