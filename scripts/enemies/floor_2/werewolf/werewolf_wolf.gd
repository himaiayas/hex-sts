class_name WerewolfWolf
extends EnemyHit

## Wolf form: Howl (gain 1 Strength), then Hit 8 in a 2 x 4 block.

const HOWL := 1


func _init() -> void:
	var maul: Array[BaseActionTile] = []
	for r in 2:
		for q in 4:
			maul.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))  # rows line up, not slant
	super("Howl & Maul", "Gain 1 Strength, then hit 8 tiles in a 2x4 block.", maul)
	extra_types = [Enum.BaseEnemyActionEnum.BUFF]


func execute(combat: CombatState, owner: CombatUnit) -> void:
	owner.add_power(combat, StrengthPower.new(HOWL))
	await combat.flush()
	await super(combat, owner)
