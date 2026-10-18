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


## Test helper: hexagon of radius r in a (2r+1)x(2r+1) matrix, null outside the hexagon.
static func make_hex_health(radius: int) -> Array[Array]:
	var matrix: Array[Array] = []
	for i in 2 * radius + 1:
		var row := []
		for j in 2 * radius + 1:
			var q := i - radius
			var r := j - radius
			if absi(q) <= radius and absi(r) <= radius and absi(q + r) <= radius:
				var tile := HealthTile.new()
				tile.hp = 1
				row.append(tile)
			else:
				row.append(null)
		matrix.append(row)
	return matrix


func has_health_tile(coords: Vector2i) -> bool:
	if coords.x < 0 or coords.x >= health.size():
		return false
	if coords.y < 0 or coords.y >= health[coords.x].size():
		return false
	return health[coords.x][coords.y] != null


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
