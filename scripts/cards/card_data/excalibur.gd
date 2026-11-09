class_name Excalibur
extends BaseCard


func _init() -> void:
	card_name = "EXCALIBUR"
	cost = 2
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.RARE
	description = "{keyword:Pierce} the whole row."
	image = preload("res://assets/cards/cards/excalibur.png")
	grid_actions = [
		LineGridAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO, true)),
	]
