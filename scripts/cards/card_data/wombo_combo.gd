class_name WomboCombo
extends BaseCard


func _init() -> void:
	card_name = "Wombo Combo"
	cost = 2
	type = Enum.CardType.ATTACK
	description = "{render:0}\nApply {keyword:Poison}.\n{render:1}\nDeal damage in a line."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			ApplyEffectTile.new(Vector2i(0,0), PoisonTileEffect.new())
		]),
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(2,0))
		]),
	]
