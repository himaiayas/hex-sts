class_name RapidFire
extends BaseCard


func _init() -> void:
	card_name = "Rapid Fire"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "Choose an enemy.\nDamage 3 random tiles on it."
	grid_actions = [
		RandomGridAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), 3),
	]
