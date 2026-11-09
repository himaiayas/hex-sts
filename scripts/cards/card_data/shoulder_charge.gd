class_name ShoulderCharge
extends BaseCard


func _init() -> void:
	card_name = "Shoulder Charge"
	cost = 1
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.UNCOMMON
	description = "{keyword:Sacrifice} 2.\n{render:1}\n[Self] {render:2}"
	image = preload("res://assets/cards/cards/shoulder_charge.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			SacrificeTile.new(Vector2i(0,0)),
			SacrificeTile.new(Vector2i(1,0))
			], Vector2i.ZERO, true),
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
		GridAction.new(Enum.TargetType.PLAYER, [
			ShieldTile.new(Vector2i(1,0)),
			ShieldTile.new(Vector2i(0,0)),
		]),
	]
