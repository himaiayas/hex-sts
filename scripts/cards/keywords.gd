class_name Keywords
extends RefCounted

## Keyword -> description, read from every non-abstract BaseEffect subclass,
## so a new effect's keyword works without registering it anywhere.

static var _descriptions: Dictionary[String, String] = {}


static func describe(keyword: String) -> String:
	if _descriptions.is_empty():
		_load()
	if not _descriptions.has(keyword):
		push_warning("Unknown keyword: %s" % keyword)
		_descriptions[keyword] = ""  # only warn once
	return _descriptions[keyword]


static func _load() -> void:
	for info in ProjectSettings.get_global_class_list():
		var script: Script = load(info.path)
		if script.is_abstract() or not _is_effect(script):
			continue
		var effect: BaseEffect = script.new()
		_descriptions[effect.name] = effect.description


static func _is_effect(script: Script) -> bool:
	while script:
		if script == BaseEffect:
			return true
		script = script.get_base_script()
	return false
