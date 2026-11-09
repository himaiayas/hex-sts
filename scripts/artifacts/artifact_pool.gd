class_name ArtifactPool

## Every artifact that can drop. Add new artifact classes here.
static var ARTIFACTS: Array = [
	CrimsonShard,
	RedLantern,
	WornGauntlet,
	IronRing,
	LuckyCoin,
	OilLantern,
	SpareHex,
	MasonsTrowel,
	EmberPouch,
	ChalkMarker,
	BannerOfThree,
	EagleEye,
	WeightedBoots,
	SpikedGauntlet,
	BastionBrick,
	CinderUrn,
	PhoenixFeather,
	EchoBell,
	ClockworkHeart,
	TitanPlate,
	TradingSigil,
	GiantsKnuckle,
	CursedCrown,
	HeavyCuirass,
	DragonScale,
	LuckyCharm,
	Mirror,
	DragonFang,
]

## Relative chance of each rarity (missing or 0 = never drops). Lucky Charm multiplies these
## (LuckyCharm.ARTIFACT_MULTIPLIERS).
## Treasure, Merchant and level-up artifacts:
const NORMAL_WEIGHTS := {
	Enum.ArtifactRarity.COMMON: 50,
	Enum.ArtifactRarity.UNCOMMON: 35,
	Enum.ArtifactRarity.RARE: 15,
}
## A boss's reward:
const BOSS_WEIGHTS := {
	Enum.ArtifactRarity.RARE: 80,
	Enum.ArtifactRarity.LEGENDARY: 20,
}


## A random artifact the player doesn't own and isn't already offered (RunState.offered_artifacts),
## its rarity rolled from weights (NORMAL_WEIGHTS or BOSS_WEIGHTS). Rarities with nothing left are
## skipped. null when nothing can drop. The result is added to RunState.offered_artifacts.
static func random_artifact(owned: Array[BaseArtifact], weights: Dictionary = NORMAL_WEIGHTS) -> BaseArtifact:
	var taken: Array[BaseArtifact] = owned.duplicate()
	taken.append_array(RunState.offered_artifacts)
	taken.append_array(RunState.shelved_artifacts())
	var artifact := _roll(taken, weights)
	if artifact:
		RunState.offered_artifacts.append(artifact)
	return artifact


static func _roll(owned: Array[BaseArtifact], weights: Dictionary) -> BaseArtifact:
	var owned_scripts := owned.map(func(a: BaseArtifact) -> Script: return a.get_script())
	var by_rarity := {}
	for artifact_class in ARTIFACTS:
		if artifact_class in owned_scripts:
			continue
		var artifact: BaseArtifact = artifact_class.new()
		if _rarity_weight(weights, artifact.rarity) > 0:
			by_rarity.get_or_add(artifact.rarity, []).append(artifact)
	var total := 0.0
	for rarity in by_rarity:
		total += _rarity_weight(weights, rarity)
	if total <= 0.0:
		return null
	var roll := randf() * total
	for rarity in by_rarity:
		roll -= _rarity_weight(weights, rarity)
		if roll < 0.0:
			return by_rarity[rarity].pick_random()
	return by_rarity.values().back().pick_random()  # float rounding


## weights[rarity], times Lucky Charm's multiplier if the player has it.
static func _rarity_weight(weights: Dictionary, rarity: Enum.ArtifactRarity) -> float:
	var weight: float = weights.get(rarity, 0)
	if RunState.has_artifact(LuckyCharm):
		weight *= LuckyCharm.ARTIFACT_MULTIPLIERS.get(rarity, 1.0)
	return weight


## Up to count different artifacts the player doesn't own; fewer if the pool runs out.
static func random_artifacts(count: int, owned: Array[BaseArtifact], weights: Dictionary = NORMAL_WEIGHTS) -> Array[BaseArtifact]:
	var result: Array[BaseArtifact] = []
	var taken := owned.duplicate()
	for i in count:
		var artifact := random_artifact(taken, weights)
		if artifact == null:
			break
		result.append(artifact)
		taken.append(artifact)
	return result
