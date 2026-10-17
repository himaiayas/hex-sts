class_name ActionContext
extends RefCounted


# passed with action to privide context
var combat: CombatState
var caster: CombatUnit
var target_cell: Vector2i
var card: BaseCard  # null for enemy actions


func _init(_combat: CombatState, _caster: CombatUnit, _target_cell: Vector2i, _card: BaseCard = null) -> void:
	combat = _combat
	caster = _caster
	target_cell = _target_cell
	card = _card
