class_name CombatUnit
extends RefCounted


var display_name: String
var health: Dictionary[Vector2i, HealthTile]  #Matrix with element as HealthTile
var statuses: Array[BaseEffect] = []
var is_player := false


func _init(_name: String, _health: Dictionary[Vector2i, HealthTile], _is_player := false) -> void:
	display_name = _name
	health = _health
	is_player = _is_player


## hexagon of radius r in a (2r+1)x(2r+1) matrix
static func make_hex_health(coords: Array[Vector2i]) -> Dictionary[Vector2i, HealthTile]:
	var health_dict: Dictionary[Vector2i, HealthTile] = {}
	for coord in coords:
		health_dict[coord] = HealthTile.new()
	return health_dict

func shield_health_tile(coords:Vector2i)->void:
	var tile: HealthTile = health[coords]

	if tile and tile.hp>Enum.HealthTileEnum.DAMAGED:
		tile.hp = Enum.HealthTileEnum.SHIELDED
	

func damage_health_tile(coords:Vector2i)->void:
	# condition check for has health or not, idk we should do on this or on Combat State.
	var tile: HealthTile = health[coords]
	if tile and tile.hp>0:
		tile.hp = tile.hp-1
	
func apply_effect_health_tile(coords:Vector2i, status:BaseTileEffect)->void:
	var tile: HealthTile = health[coords]
	if tile:
		tile.status_effects.append(status) #require rework
# func is_dead() -> bool:
# 	return ???
