class_name SacredBlessing
extends BaseCard



func _init() -> void:
	card_name = "Sacred Blessing"
	cost = 1
	type = Enum.CardType.SKILL
	rarity = Enum.CardRarity.LEGENDARY
	target = Enum.TargetType.PLAYER
	description = "Add a random Sword of Might, Axe of Resilience or Spear of Destiny to your hand. It costs 0 this turn."
	image = preload("res://assets/cards/cards/sacred_blessing.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	var relics: Array[BaseCard] = [SwordOfMight.new(), AxeOfResilience.new(), SpearOfDestiny.new()]
	var card: BaseCard = relics.pick_random()
	card.free_on_turn = combat.turn
	combat.add_to_hand(card)
	return hits
