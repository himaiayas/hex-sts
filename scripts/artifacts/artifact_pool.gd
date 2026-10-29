class_name ArtifactPool

## Every artifact that can drop. Add new artifact classes here.
static var ARTIFACTS: Array = [
	GlowingOrb,
	CrimsonShard,
	RedLantern,
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
		if RARITY_WEIGHTS.get(artifact.rarity, 0) > 0:
			by_rarity.get_or_add(artifact.rarity, []).append(artifact)
	var total := 0
	for rarity in by_rarity:
		total += RARITY_WEIGHTS[rarity]
	if total == 0:
		return null
	var roll := randi_range(1, total)
	for rarity in by_rarity:
		roll -= RARITY_WEIGHTS[rarity]
		if roll <= 0:
			return by_rarity[rarity].pick_random()
	return null
