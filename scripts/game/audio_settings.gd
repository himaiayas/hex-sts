class_name AudioSettings

## Volume channels (audio buses) and their saved levels, shared by Music and Sfx.
## Each level is 0 to 1, kept in user://settings.cfg under [audio].

const PATH := "user://settings.cfg"


## Makes the bus if the project has none of that name.
static func ensure_bus(bus: String) -> void:
	if AudioServer.get_bus_index(bus) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)


static func load_level(key: String, default: float) -> float:
	var settings := ConfigFile.new()
	if settings.load(PATH) != OK:
		return default
	return clampf(settings.get_value("audio", key, default), 0.0, 1.0)


static func save_level(key: String, level: float) -> void:
	var settings := ConfigFile.new()
	settings.load(PATH)  # keep the other settings
	settings.set_value("audio", key, level)
	settings.save(PATH)


static func apply(bus: String, level: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	if index == -1:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(level, 0.0001)))
	AudioServer.set_bus_mute(index, level <= 0.0)
