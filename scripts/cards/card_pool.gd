class_name CardPool

static var CARDS: Array = [
	Strike,
	StatusStrike,
	ShieldPlayer,
	WomboCombo,
	Thrust,
	DivineMercy,
	RapidFire,
	ArrowRain,
	Enhance,
	LastLight,
	SteadyGuard,
	Kindling,
	CinderStrike,
	Mend,
	BloodPrice,
	SpikedGuard,
	Lance,
]

static func random_cards(count: int) -> Array[BaseCard]:
	var pool := CARDS.duplicate()
	pool.shuffle()
	var result: Array[BaseCard] = []
	for card_class in pool.slice(0, count):
		result.append(card_class.new())
	return result
