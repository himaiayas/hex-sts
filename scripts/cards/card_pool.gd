class_name CardPool

static var CARDS: Array = [
	Slash,
	CrushingCombo,
	XSlash,
	Guard,
	BurningStab,
	SpearOfDestiny,
	ShieldBash,
	GreatWall,
	RedSpot,
	Parry,
	Barricade,
	ShoulderCharge,
	LuckyShield,
	ScrapArmor,
	TowerStrike,
	Thrust,
	DivineMercy,
	Unbreakable,
	Enhance,
	Smash,
	Sidestep,
	Boomerang,
	PlateUp,
	DonutBlast,
	OpenVein,
	Kindling,
	CinderStrike,
	Mend,
	SpikedGuard,
	SwordOfMight,
	Excalibur,
	Jab,
	Sweep,
	Whetstone,
	EchoHeart,
	WellPrepared,
	InfiniteWard,
	Crack,
	FlurryStorm,
	Glock,
	DeepBreath,
	CureAilment,
	Burnout,
	Taunt,
	HeroicStance,
	Ethylene,
	Pyre,
	AxeOfResilience,
	SacredBlessing,
	Aegis,
	Maceration,
	BloodlustStrike,
	Chronokinesis,
	Unstoppable,
	ChronicSunburn,
	RevivalChant,
	LivingWall,
	HallowedKnight,
	Oblation,
	BloodyChalice,
	ReservedArmory,
	Duelist,
	SturdySteps,
]

## count different random cards. Every card is as likely, unless Lucky Charm favours Rare and Legendary.
static func random_cards(count: int) -> Array[BaseCard]:
	var pool: Array[BaseCard] = []
	for card_class in CARDS:
		pool.append(card_class.new())
	var result: Array[BaseCard] = []
	while result.size() < count and not pool.is_empty():
		var total := 0
		for card in pool:
			total += _weight(card)
		var roll := randi_range(1, total)
		for card in pool:
			roll -= _weight(card)
			if roll <= 0:
				result.append(card)
				pool.erase(card)
				break
	return result


static func _weight(card: BaseCard) -> int:
	return RunState.luck_factor(card.rarity >= Enum.CardRarity.RARE)
