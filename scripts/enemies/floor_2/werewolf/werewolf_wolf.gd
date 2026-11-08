class_name WerewolfWolf
extends EnemyHit

## Wolf form: Howl (gain 1 Strength), then Hit 12 in a 3 x 4 block.

const HOWL := 1


func _init() -> void:
	var maul: Array[BaseActionTile] = []
	for r in 3:
		for q in 4:
			maul.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))  # rows line up, not slant
	super("Howl & Maul", "Gain 1 Strength, then hit 12 tiles in a 3x4 block.", maul)


func execute(combat: CombatState, owner: CombatUnit) -> void:
	owner.add_power(combat, StrengthPower.new(HOWL))
	await combat.flush()
	await super(combat, owner)
