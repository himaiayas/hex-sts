class_name ArtifactPool

## Every artifact that can drop. Add new artifact classes here.
static var ARTIFACTS: Array = [
	GlowingOrb,
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

## Relative chance of each rarity (0 = never drops).
const RARITY_WEIGHTS := {
	Enum.ArtifactRarity.COMMON: 50,
	Enum.ArtifactRarity.UNCOMMON: 33,
	Enum.ArtifactRarity.RARE: 15,
	Enum.ArtifactRarity.LEGENDARY: 2,
}


static func random_artifact(owned: Array[BaseArtifact]) -> BaseArtifact:
	var owned_scripts := owned.map(func(a: BaseArtifact) -> Script: return a.get_script())
	var by_rarity := {}
	for artifact_class in ARTIFACTS:
		if artifact_class in owned_scripts:
			continue
		var artifact: BaseArtifact = artifact_class.new()
		if _rarity_weight(artifact.rarity) > 0:
			by_rarity.get_or_add(artifact.rarity, []).append(artifact)
	var total := 0
	for rarity in by_rarity:
		total += _rarity_weight(rarity)
	if total == 0:
		return null
	var roll := randi_range(1, total)
	for rarity in by_rarity:
		roll -= _rarity_weight(rarity)
		if roll <= 0:
			return by_rarity[rarity].pick_random()
	return null


## RARITY_WEIGHTS, with Lucky Charm's bonus for Rare and Legendary.
static func _rarity_weight(rarity: Enum.ArtifactRarity) -> int:
	return RARITY_WEIGHTS.get(rarity, 0) * RunState.luck_factor(rarity >= Enum.ArtifactRarity.RARE)


## Up to count different artifacts the player doesn't own; fewer if the pool runs out.
static func random_artifacts(count: int, owned: Array[BaseArtifact]) -> Array[BaseArtifact]:
	var result: Array[BaseArtifact] = []
	var taken := owned.duplicate()
	for i in count:
		var artifact := random_artifact(taken)
		if artifact == null:
			break
		result.append(artifact)
		taken.append(artifact)
	return result
