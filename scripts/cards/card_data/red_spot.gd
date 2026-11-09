class_name RedSpot
extends BaseCard


func _init() -> void:
	card_name = "Red Spot"
	cost = 2
	type = Enum.CardType.SKILL
	rarity = Enum.CardRarity.UNCOMMON
	description = "{render:0}\n."
	image = preload("res://assets/cards/cards/red_spots.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			ApplyEffectTile.new(Vector2i(0,0), FractureTileEffect.new()),
			ApplyEffectTile.new(Vector2i(2,-1), FractureTileEffect.new()),
			ApplyEffectTile.new(Vector2i(-1,2), FractureTileEffect.new()),
			ApplyEffectTile.new(Vector2i(-1,-1), FractureTileEffect.new()),
		]),
	]
