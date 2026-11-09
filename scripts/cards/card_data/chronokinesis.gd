class_name Chronokinesis
extends BaseCard


func _init() -> void:
	card_name = "Chronokinesis"
	cost = 3
	type = Enum.CardType.SKILL
	rarity = Enum.CardRarity.RARE
	target = Enum.TargetType.PLAYER
	description = "Next turn, your Attacks deal Piercing damage. End your turn, then take an extra turn."
	image = preload("res://assets/cards/cards/chronokinesis.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	combat.player.add_power(combat, PiercingPower.new())
	await combat.flush()
	combat.extra_turns += 1
	combat.end_turn_requested = true
	return hits
