class_name GridAction
extends BaseAction

var tiles:Array[BaseActionTile]
var anchor: Vector2i

func _init(_target: TargetType, _tiles:Array[BaseActionTile], _anchor: Vector2i=Vector2i.ZERO)->void:
	target = _target
	tiles = _tiles
	anchor = _anchor

func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i)->void:
	for t in tiles:
		t.inflict(combat, unit, cell + t.coords + anchor)
