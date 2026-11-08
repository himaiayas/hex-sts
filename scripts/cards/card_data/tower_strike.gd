class_name TowerStrike
extends BaseCard


func _init() -> void:
	card_name = "Tower Strike"
	cost = 2
	type = Enum.CardType.ATTACK
	description = "{render:0}\n[Self] {render:1}\n."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(0,1)),
			DamageTile.new(Vector2i(-1,1)),
			DamageTile.new(Vector2i(-1,0)),
			DamageTile.new(Vector2i(0,-1)),
			DamageTile.new(Vector2i(1,-1)),
			DamageTile.new(Vector2i(0,2)),
			DamageTile.new(Vector2i(-1,2)),
			DamageTile.new(Vector2i(-2,2))
		]),
		GridAction.new(Enum.TargetType.PLAYER, [
			ApplyEffectTile.new(Vector2i(0,0), PlateTileEffect.new()),
			ApplyEffectTile.new(Vector2i(1,0), PlateTileEffect.new()),
		]),
	]
