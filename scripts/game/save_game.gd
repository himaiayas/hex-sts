class_name SaveGame

## Saving the run to disk (Save & Quit) and loading it back (Continue).
## pack() turns the run's objects into plain data, unpack() rebuilds them:
## - A card is rebuilt from its class, then gets back its saved simple variables (cost, exhaust,
##   repeat...), its augments, and its patterns' tiles: each saved tile is a copy of a fresh tile
##   of the same kind moved to the saved cell (how Expansion Augment adds tiles anyway).
## - A map room is rebuilt from its coord, type and doors.
## - Any other object (artifact, augment, effect, health tile, MapState) is made with new() and gets
##   back every script variable, recursively, so counters like Clockwork Heart's survive.
## Not saved: the fight in progress (CombatState) and scene nodes; they come back as null.

const PATH := "user://run.save"
const VERSION := 1


static func exists() -> bool:
	return FileAccess.file_exists(PATH)


static func write(data: Dictionary) -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveGame: can't write %s (%s)" % [PATH, error_string(FileAccess.get_open_error())])
		return
	data.version = VERSION
	file.store_var(data)


## The saved data, or {} if there's none or it's from another version.
static func read() -> Dictionary:
	if not exists():
		return {}
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return {}
	var data: Variant = file.get_var()
	if not data is Dictionary or data.get("version", -1) != VERSION:
		return {}
	return data


static func delete() -> void:
	if exists():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


static func pack(value: Variant) -> Variant:
	if value is Object:
		if value is Script:
			return {"$script": value.resource_path}
		if value is CombatState or value is Node:
			return null
		if value is BaseCard:
			return _pack_card(value)
		if value is MapRoom:
			return {"$room": [value.coord, value.type, value.doors, value.number]}
		var script: Script = value.get_script()
		if script == null:  # an engine resource: a texture, a sound
			return {"$res": value.resource_path} if value is Resource and not value.resource_path.is_empty() else null
		var props := {}
		for property in value.get_property_list():
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				props[property.name] = pack(value.get(property.name))
		return {"$obj": script.resource_path, "props": props}
	if value is Array:
		return value.map(pack)
	if value is Dictionary:
		var result := {}
		for key: Variant in value:
			result[pack(key)] = pack(value[key])
		return result
	return value


static func unpack(value: Variant) -> Variant:
	if value is Array:
		return value.map(unpack)
	if not value is Dictionary:
		return value
	if value.has("$card"):
		return _unpack_card(value)
	if value.has("$room"):
		var r: Array = value["$room"]
		var doors: Array[int] = []
		doors.assign(r[2])
		var room := MapRoom.new(r[0], r[1], doors)
		room.number = r[3]
		return room
	if value.has("$obj"):
		var object: Object = load(value["$obj"]).new()
		for name: String in value.props:
			_assign(object, name, unpack(value.props[name]))
		return object
	if value.has("$res"):
		return load(value["$res"])
	if value.has("$script"):
		return load(value["$script"])
	var result := {}
	for key: Variant in value:
		result[unpack(key)] = unpack(value[key])
	return result


## Simple variables (numbers, flags, text), augments, and each pattern's tiles as [kind, coords].
static func _pack_card(card: BaseCard) -> Dictionary:
	var vars := {}
	for property in card.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE \
				and property.type in [TYPE_INT, TYPE_FLOAT, TYPE_BOOL, TYPE_STRING]:
			vars[property.name] = card.get(property.name)
	var patterns := []
	for i in card.grid_actions.size():
		var tiles := []
		for t in card.pattern(i).tiles:
			tiles.append([t.kind(), t.coords])
		patterns.append(tiles)
	return {"$card": card.get_script().resource_path, "vars": vars, "augments": pack(card.augments),
		"patterns": patterns}


static func _unpack_card(data: Dictionary) -> BaseCard:
	var card: BaseCard = load(data["$card"]).new()
	for name: String in data.vars:
		card.set(name, data.vars[name])
	card.augments.assign(unpack(data.augments))
	var patterns: Array = data.patterns
	for i in mini(patterns.size(), card.grid_actions.size()):
		var fresh := card.pattern(i).tiles.duplicate()
		var tiles: Array[BaseActionTile] = []
		for saved: Array in patterns[i]:
			for template in fresh:
				if template.kind() == saved[0]:
					tiles.append(template.copy_at(saved[1]))
					break
		card.pattern(i).tiles.assign(tiles)
	return card


## Typed arrays and dictionaries are filled in place, keeping their element types.
static func _assign(object: Object, name: String, value: Variant) -> void:
	var current: Variant = object.get(name)
	if current is Array and value is Array:
		current.assign(value)
	elif current is Dictionary and value is Dictionary:
		current.assign(value)
	else:
		object.set(name, value)
