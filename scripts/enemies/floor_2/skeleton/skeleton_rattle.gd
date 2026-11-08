class_name SkeletonRattle
extends EnemyShieldSelf

## Block 7 + Retaliate 3: shields 7 random tiles of its own, then each hit those Shields absorb
## before its next turn damages a random tile of the attacker 3 times.

const RETALIATE := 3


func _init() -> void:
	super("Rattle", 7, "Shield 7 random tiles of its own and gain Retaliate 3.")


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await super(combat, owner)
	owner.add_power(combat, RetaliatePower.new(RETALIATE))
	await combat.flush()
