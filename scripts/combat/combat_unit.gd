class_name CombatUnit
extends RefCounted

## The player or an enemy during a fight.

var display_name: String
var health: Array[Array]  #Matrix with element as HealthTile
var statuses: Array[BaseStatus] = []
var is_player := false


func _init(_name: String, _health: Array[Array], _is_player := false) -> void:
	display_name = _name
	health = _health
	is_player = _is_player




func damage_health_tile(coords:Vector2i)->void:
	var tile: HealthTile = health[coords.x][coords.y]
	if tile and tile.hp>0:
		tile.hp = tile.hp-1
	
func apply_status_health_tile(coords:Vector2i, status:BaseTileStatus)->void:
	var tile: HealthTile = health[coords.x][coords.y]
	if tile:
		tile.status_effects.append(status) #require rework
# func is_dead() -> bool:
# 	return ???
