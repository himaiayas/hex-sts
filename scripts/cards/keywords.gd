class_name Keywords
extends RefCounted

## Keyword -> description, read from every non-abstract BaseEffect subclass,
## so a new effect's keyword works without registering it anywhere.
## Keywords that aren't effects are listed in NOT_EFFECTS.

const NOT_EFFECTS: Dictionary[String, String] = {
	"Shield": "Absorbs the next hit on this tile.",
	"Exhaust": "Removed from this combat after it's played. It comes back next combat.",
	"Retain": "Not discarded at the end of your turn.",
	"Sacrifice": "Destroy your own tiles as a cost. You choose which.",
}

static var _descriptions: Dictionary[String, String] = {}


static func describe(keyword: String) -> String:
	if _descriptions.is_empty():
		_load()
	if not _descriptions.has(keyword):
		push_warning("Unknown keyword: %s" % keyword)
		_descriptions[keyword] = ""  # only warn once
	return _descriptions[keyword]


static func _load() -> void:
	_descriptions.merge(NOT_EFFECTS)
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
