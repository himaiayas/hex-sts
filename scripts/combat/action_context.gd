class_name ActionContext
extends RefCounted


# passed with action to privide context
var combat: CombatState
var caster: CombatUnit
var target: CombatUnit  # unit whose health grid is aimed at
var target_cell: Vector2i  # cell on the target's health grid
var card: BaseCard  # null for enemy actions


func _init(_combat: CombatState, _caster: CombatUnit, _target: CombatUnit, _target_cell: Vector2i, _card: BaseCard = null) -> void:
	combat = _combat
	caster = _caster
	target = _target
	target_cell = _target_cell
	card = _card
