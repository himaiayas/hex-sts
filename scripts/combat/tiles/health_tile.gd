class_name HealthTile
extends Resource

enum HealthTileEnum {
	DAMAGED = 0,
	UNDAMAGED = 1,
	SHIELDED = 2,
}

var status_effects: Array[BaseTileEffect]
var hp: int #-1 = empty, 0 = damaged, 1=undamaged, 2=shield

func _init() -> void:
	status_effects = []
	hp = 1
