class_name StatusStrike
extends BaseCard


func _init() -> void:
	card_name = "StatusStrike"
	cost = 3
	type = CardType.ATTACK
	description = "{render:0}\nDeal damage and apply {keyword:Poison}."
	grid_actions = [
		GridAction.new(BaseAction.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			ApplyEffectTile.new(Vector2i(1,2), PoisonTileEffect.new())
		]),
	]
