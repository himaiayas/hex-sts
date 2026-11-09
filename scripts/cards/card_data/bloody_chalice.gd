class_name BloodyChalice
extends BaseCard


func _init() -> void:
	card_name = "Bloody Chalice"
	cost = 1
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.RARE
	target = Enum.TargetType.PLAYER
	description = "The first time you lose a health tile during your turn, gain 1 Energy."
	image = preload("res://assets/cards/cards/bloody_chalice.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, BloodyChalicePower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
