class_name LivingWall
extends BaseCard


func _init() -> void:
	card_name = "Living Wall"
	cost = 1
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.UNCOMMON
	target = Enum.TargetType.PLAYER
	description = "Whenever you gain Plate, deal damage to 1 random enemy tile."
	image = preload("res://assets/cards/cards/living_wall.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, LivingWallPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
