class_name ShoulderCharge
extends BaseCard


func _init() -> void:
	card_name = "Shoulder Charge"
	cost = 1
	type = Enum.CardType.ATTACK
	pick_tiles = 1
	pick_tile = SacrificeTile.new(Vector2i.ZERO)
	description = "{keyword:Sacrifice} 1.\n{render:0}"
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(-2,1)),
			DamageTile.new(Vector2i(-1,0)),
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(2,0)),
			DamageTile.new(Vector2i(1,1)),
			DamageTile.new(Vector2i(0,1)),
			DamageTile.new(Vector2i(-1,1)),
		]),
	]
