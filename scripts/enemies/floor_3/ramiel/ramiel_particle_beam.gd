class_name RamielParticleBeam
extends BaseEnemyAction

## Hit 30 with Pierce, on the target its Charges locked: it shares their pattern.


func _init(charge: RamielCharge) -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Particle Beam", 1.0)
	heavy_impact = true
	description = "Hit 30 tiles in a 3x10 band with Pierce."
	hit_vfx = preload("res://assets/enemies/floor_3/ramiel_beam.png")
	parts = [charge.parts[0]]


func plan(_combat: CombatState, _owner: CombatUnit) -> void:
	pass  # already aimed by the Charges


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	await GridAction.new(Enum.TargetType.PLAYER, parts[0].tiles).execute(combat, combat.player, parts[0].cell)
