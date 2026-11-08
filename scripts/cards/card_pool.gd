class_name CardPool

static var CARDS: Array = [
	Slash,
	CrushingCombo,
	XSlash,
	Guard,
	BurningStab,
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
]

static func random_cards(count: int) -> Array[BaseCard]:
	var pool := CARDS.duplicate()
	pool.shuffle()
	var result: Array[BaseCard] = []
	for card_class in pool.slice(0, count):
		result.append(card_class.new())
	return result
