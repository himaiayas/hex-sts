class_name MapState
extends RefCounted

## The map's data: placed rooms, where the player is, and steps left.
## Rooms are flat-top hexes in axial coordinates (q, r).

const START_STEPS := 50
const BUILD_COST := 3
const START_DOORS := 3
const OPTION_COUNT := 3
const MIN_DOOR_CHANCE := 0.1  # a door's chance never drops below this, however crowded the map
## Crowding: the more open spots (frontier) the map already has, the fewer doors new rooms get.
## Each open spot beyond FREE_SPOTS (not counting the one being built) cuts each extra door's chance
## by SPOT_FALLOFF. Opening doors everywhere leads to dead ends; aiming them where you want to go doesn't.
const FREE_SPOTS := 4
## Doors each room type rolls, [min, max] counting the one it's entered by, before crowding
## (door_chance). Good rooms get fewer: taking one tends to close that branch, so a crowded map (from
## opening doors everywhere) mostly offers them as dead ends. Types not listed roll 2-4.
const DOOR_RANGE := {
	Enum.RoomType.NORMAL_COMBAT: Vector2i(3, 4),
	Enum.RoomType.ELITE_COMBAT: Vector2i(2, 3),
	Enum.RoomType.EVENT: Vector2i(2, 3),
	Enum.RoomType.MERCHANT: Vector2i(1, 2),
	Enum.RoomType.BLACKSMITH: Vector2i(1, 2),
	Enum.RoomType.CAMPFIRE: Vector2i(1, 1),
	Enum.RoomType.TREASURE: Vector2i(1, 1),
	Enum.RoomType.INTERSECTION: Vector2i(6, 6),
}
## Rooms that keep every door they roll: crowding (door_chance) doesn't remove any.
## Only a neighbour with no door back still blocks a side.
const KEEPS_DOORS := [Enum.RoomType.INTERSECTION]
const SPOT_FALLOFF := 0.2


const ROOM_WEIGHTS := {
	Enum.RoomType.NORMAL_COMBAT: 30,
	Enum.RoomType.ELITE_COMBAT: 10,
	Enum.RoomType.BOSS_COMBAT: 0, # not drafted; reserved for the end of the floor
	Enum.RoomType.CAMPFIRE: 10,
	Enum.RoomType.MERCHANT: 10,
	Enum.RoomType.BLACKSMITH: 10,
	Enum.RoomType.TREASURE: 10,
	Enum.RoomType.EVENT: 0,
	Enum.RoomType.INTERSECTION: 10,
}

const DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]

var rooms: Dictionary[Vector2i, MapRoom] = {}
var current := Vector2i.ZERO
var steps := START_STEPS


static func opposite(dir: int) -> int:
	return (dir + 3) % 6


## The map's own random numbers, seeded per floor from the run seed (RunState.floor_seed): the same
## seed gives the same drafts for the same choices, whatever happens in fights. Saved with the run.
var rng := RandomNumberGenerator.new()


## map_seed: the floor's seed (RunState.floor_seed); random if not given (tests).
func start(map_seed: int = randi()) -> void:
	rng.seed = map_seed
	rooms.clear()
	steps = START_STEPS
	current = Vector2i.ZERO
	rooms[current] = MapRoom.new(current, Enum.RoomType.START, _random_doors(START_DOORS))


## True if room at cell and its neighbour in dir both have doors facing each other.
func connected(cell: Vector2i, dir: int) -> bool:
	var other: Vector2i = cell + DIRS[dir]
	return rooms.has(cell) and rooms.has(other) \
		and rooms[cell].has_door(dir) and rooms[other].has_door(opposite(dir))


## Empty cells behind a door: where a new room can be built.
func frontier() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in rooms:
		for dir in rooms[cell].doors:
			var next: Vector2i = cell + DIRS[dir]
			if not rooms.has(next) and next not in result:
				result.append(next)
	return result


## How to get to cell from the current room. Empty if unreachable.
## { target, path (rooms entered, excluding the current one), build, door, cost }
## For a new room, door is the side of the new room that must face the room it's entered from.
func plan_to(cell: Vector2i) -> Dictionary:
	if cell == current:
		return {}
	var bfs := _bfs()
	var dist: Dictionary = bfs.dist
	if rooms.has(cell):
		if not dist.has(cell):
			return {}
		return {target = cell, path = _path(bfs.prev, cell), build = false, door = -1, cost = dist[cell]}

	var best_room := Vector2i.ZERO
	var best_door := -1
	for dir in 6:
		var from: Vector2i = cell + DIRS[dir]
		if rooms.has(from) and rooms[from].has_door(opposite(dir)) and dist.has(from):
			if best_door == -1 or dist[from] < dist[best_room]:
				best_room = from
				best_door = dir
	if best_door == -1:
		return {}
	return {target = cell, path = _path(bfs.prev, best_room), build = true, door = best_door,
		cost = dist[best_room] + BUILD_COST}


## Spend one step per room entered and end up in the last one.
func walk(path: Array[Vector2i]) -> void:
	if path.is_empty():
		return
	steps -= path.size()
	current = path.back()


## Rooms to choose from for cell, entered through door. They never have a door toward a
## neighbouring room that has no door back, have fewer doors on a crowded map (door_chance), and
## at least one of them keeps a spot to build (_ensure_exit).
func draft_options(cell: Vector2i, door: int) -> Array[MapRoom]:
	var keep := door_chance(cell)
	var allowed := _allowed_doors(cell)
	var options: Array[MapRoom] = []
	var used_types := {}
	var seen := {}
	var attempts := 0
	while options.size() < OPTION_COUNT and attempts < 50:
		attempts += 1
		var type := random_room_type(used_types if attempts < 30 else {})
		var door_range: Vector2i = DOOR_RANGE.get(type, Vector2i(2, 4))
		var doors := _random_doors(rng.randi_range(door_range.x, door_range.y), door, allowed)
		if type not in KEEPS_DOORS:
			doors = doors.filter(func(d: int) -> bool: return d == door or rng.randf() < keep)
		var key := str([type, doors])
		if seen.has(key):
			continue
		seen[key] = true
		used_types[type] = true
		options.append(MapRoom.new(cell, type, doors))
	# Guaranteed exit: if every option would leave nowhere to build, one of them (the one with the
	# most doors already) gets another. Only one, so a dead end there still ends the floor early.
	if not options.is_empty() and not options.any(func(o: MapRoom) -> bool: return _has_spot_after(cell, o.doors)):
		var widest := options[0]
		for option in options:
			if option.doors.size() > widest.doors.size():
				widest = option
		_ensure_exit(cell, widest.doors, allowed)
	return options


## Weighted random room type, skipping types in `exclude` (unless nothing else is left).
func random_room_type(exclude := {}) -> Enum.RoomType:
	var total := 0
	for type in ROOM_WEIGHTS:
		if not exclude.has(type):
			total += ROOM_WEIGHTS[type]
	if total <= 0:
		return random_room_type() if not exclude.is_empty() else Enum.RoomType.NORMAL_COMBAT
	var roll := rng.randi_range(1, total)
	for type in ROOM_WEIGHTS:
		if exclude.has(type):
			continue
		roll -= ROOM_WEIGHTS[type]
		if roll <= 0:
			return type
	return Enum.RoomType.NORMAL_COMBAT


## Chance a new room at cell keeps each door other than its entry door: how crowded with open
## spots the map is (at least MIN_DOOR_CHANCE).
func door_chance(cell: Vector2i) -> float:
	return maxf(crowding_chance(cell), MIN_DOOR_CHANCE)


## 1 with up to FREE_SPOTS other open spots, less for each one beyond.
func crowding_chance(cell: Vector2i) -> float:
	var others := frontier().filter(func(c: Vector2i) -> bool: return c != cell).size()
	return clampf(1.0 - SPOT_FALLOFF * (others - FREE_SPOTS), 0.0, 1.0)


## Guaranteed exit: if a room at cell with these doors would leave no spot to build anywhere,
## adds a door toward a random empty neighbour (when cell has one). Changes doors in place.
func _ensure_exit(cell: Vector2i, doors: Array[int], allowed: Array[int]) -> void:
	if _has_spot_after(cell, doors):
		return
	var open := allowed.filter(func(d: int) -> bool: return d not in doors and not rooms.has(cell + DIRS[d]))
	if open.is_empty():
		return
	doors.append(open[rng.randi_range(0, open.size() - 1)])
	doors.sort()


## Whether some empty cell would still be behind a door after a room with doors goes at cell.
## Neighbours' doors toward cell don't count: they connect to it or get closed (place).
func _has_spot_after(cell: Vector2i, doors: Array[int]) -> bool:
	for dir in doors:
		if not rooms.has(cell + DIRS[dir]):
			return true
	for c in rooms:
		for dir in rooms[c].doors:
			var next: Vector2i = c + DIRS[dir]
			if next != cell and not rooms.has(next):
				return true
	return false


## Sides of cell a new room may have a door on: toward empty cells, and toward rooms with a door back.
func _allowed_doors(cell: Vector2i) -> Array[int]:
	var result: Array[int] = []
	for dir in 6:
		var next: Vector2i = cell + DIRS[dir]
		if not rooms.has(next) or rooms[next].has_door(opposite(dir)):
			result.append(dir)
	return result


## Also closes neighbours' doors that face the new room where it has no door back.
func place(room: MapRoom) -> void:
	for dir in 6:
		var next: Vector2i = room.coord + DIRS[dir]
		if rooms.has(next) and not room.has_door(dir):
			rooms[next].doors.erase(opposite(dir))
	room.number = rooms.size()  # the entrance is rooms[0], so the first built room is 1
	rooms[room.coord] = room
	steps -= BUILD_COST
	current = room.coord


## count doors (fewer if allowed runs out), always including required.
func _random_doors(count: int, required := -1, allowed: Array[int] = [0, 1, 2, 3, 4, 5]) -> Array[int]:
	var pool := allowed.duplicate()
	_shuffle(pool)
	var result: Array[int] = []
	if required >= 0:
		result.append(required)
		pool.erase(required)
	while result.size() < count and not pool.is_empty():
		result.append(pool.pop_back())
	result.sort()
	return result


func _bfs() -> Dictionary:
	var dist := {current: 0}
	var prev := {}
	var queue: Array[Vector2i] = [current]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for dir in 6:
			if not connected(cell, dir):
				continue
			var next: Vector2i = cell + DIRS[dir]
			if dist.has(next):
				continue
			dist[next] = dist[cell] + 1
			prev[next] = cell
			queue.append(next)
	return {dist = dist, prev = prev}


func _path(prev: Dictionary, target: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var cell := target
	while cell != current:
		path.push_front(cell)
		cell = prev[cell]
	return path


## Array.shuffle(), but with this map's rng so it follows the seed.
func _shuffle(array: Array) -> void:
	for i in range(array.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = array[i]
		array[i] = array[j]
		array[j] = tmp
