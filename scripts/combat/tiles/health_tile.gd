class_name HealthTile
extends Resource

var status_effects: Array[BaseTileEffect]
var hp: int # an Enum.HealthTileEnum value: 0 = damaged, 1 = undamaged, 2 = shielded

func _init() -> void:
	status_effects = []
	hp = 1
