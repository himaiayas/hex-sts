class_name MapState
extends RefCounted

## The map's data: placed rooms, where the player is, and steps left.
## Rooms are flat-top hexes in axial coordinates (q, r).

const START_STEPS := 50
const BUILD_COST := 3
const START_DOORS := 3
const OPTION_COUNT := 3

## Neighbour directions. Opposite of direction d is (d + 3) % 6.
const DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]

var rooms: Dictionary[Vector2i, MapRoom] = {}
var current := Vector2i.ZERO
var steps := START_STEPS


static func opposite(dir: int) -> int:
	return (dir + 3) % 6


func start() -> void:
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


## OPTION_COUNT different rooms for cell, each with a door on side `door`.
func draft_options(cell: Vector2i, door: int) -> Array[MapRoom]:
	var options: Array[MapRoom] = []
	var seen := {}
	var attempts := 0
	while options.size() < OPTION_COUNT and attempts < 50:
		attempts += 1
		var doors := _random_doors(randi_range(2, 4), door)
		var key := str(doors)
		if seen.has(key):
			continue
		seen[key] = true
		options.append(MapRoom.new(cell, Enum.RoomType.COMBAT, doors))
	return options


## Build the chosen room, pay for it and move into it.
func place(room: MapRoom) -> void:
	rooms[room.coord] = room
	steps -= BUILD_COST
	current = room.coord


func _random_doors(count: int, required := -1) -> Array[int]:
	var pool := [0, 1, 2, 3, 4, 5]
	pool.shuffle()
	var result: Array[int] = []
	if required >= 0:
		result.append(required)
		pool.erase(required)
	while result.size() < count:
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
