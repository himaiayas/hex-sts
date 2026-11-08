class_name CardPool

static var CARDS: Array = [
	Slash,
	CrushingCombo,
	Guard,
	ShoulderCharge,
	TowerStrike,
	Thrust,
	DivineMercy,
	Enhance,
	Smash,
	Sidestep,
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
]

static func random_cards(count: int) -> Array[BaseCard]:
	var pool := CARDS.duplicate()
	pool.shuffle()
	var result: Array[BaseCard] = []
	for card_class in pool.slice(0, count):
		result.append(card_class.new())
	return result
