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

## count different random cards. Every card is as likely, unless Lucky Charm changes it
## (LuckyCharm.CARD_MULTIPLIERS).
static func random_cards(count: int) -> Array[BaseCard]:
	var pool: Array[BaseCard] = []
	for card_class in CARDS:
		var card: BaseCard = card_class.new()
		if card.rarity != Enum.CardRarity.STARTER:  # starter cards come only in the opening deck
			pool.append(card)
	var result: Array[BaseCard] = []
	while result.size() < count and not pool.is_empty():
		var total := 0.0
		for card in pool:
			total += _weight(card)
		if total <= 0.0:
			break
		var roll := randf() * total
		var picked: BaseCard = pool.back()  # float rounding
		for card in pool:
			roll -= _weight(card)
			if roll < 0.0:
				picked = card
				break
		result.append(picked)
		pool.erase(picked)
	return result


static func _weight(card: BaseCard) -> float:
	return LuckyCharm.CARD_MULTIPLIERS.get(card.rarity, 1.0) if RunState.has_artifact(LuckyCharm) else 1.0
