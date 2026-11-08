class_name ChronicSunburn
extends BaseCard


func _init() -> void:
	card_name = "Chronic Sunburn"
	cost = 1
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.LEGENDARY
	target = Enum.TargetType.PLAYER
	description = "At the start of your turn, apply Fracture to 1 random enemy tile."
	image = preload("res://assets/cards/cards/chronic_sunburn.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, ChronicSunburnPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
