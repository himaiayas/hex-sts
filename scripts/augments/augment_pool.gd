class_name AugmentPool

static var AUGMENTS: Array = [
	ExpansionAugment,
]

static func random_augments(count: int) -> Array[BaseAugment]:
	var result: Array[BaseAugment] = []
	for i in count:
		result.append(AUGMENTS.pick_random().new())
	return result
