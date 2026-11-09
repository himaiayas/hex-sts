class_name Keywords
extends RefCounted

## Keyword -> description, read from every non-abstract BaseEffect subclass,
## so a new effect's keyword works without registering it anywhere.
## Keywords that aren't effects are listed in NOT_EFFECTS.

const NOT_EFFECTS: Dictionary[String, String] = {
	"Shield": "Absorbs the next damage on this tile.",
	"Exhaust": "Removed from this combat after it's played.",
	"Retain": "Not discarded at the end of your turn.",
	"Repeat": "Its effect happens twice.",
	"Sacrifice": "Destroy your own tiles as a cost.",
	"Heal": "Restore damaged tiles.",
	"Cleanse": "Removes every debuff (like Fracture and Poison) from a tile.",
	"Pierce": "Damage this tile, ignore Shield.",
}

static var _descriptions: Dictionary[String, String] = {}

## In descriptions, {keyword:Exhaust} shows "Exhaust"; {keyword:Exhaust|Exhausted} shows
## "Exhausted" but is still the Exhaust keyword (highlight and hover panel).
static var _with_text := RegEx.create_from_string("\\{keyword:([^}|]+)\\|([^}]+)\\}")
static var _plain := RegEx.create_from_string("\\{keyword:([^}|]+)\\}")
static var _name := RegEx.create_from_string("\\{keyword:([^}|]+)")


## text with each keyword tag replaced by its shown words, wrapped in before and after
## (e.g. BBCode colour tags; nothing for plain text).
static func markup(text: String, before := "", after := "") -> String:
	text = _with_text.sub(text, before + "$2" + after, true)
	return _plain.sub(text, before + "$1" + after, true)


## The keywords tagged in text, in order, without repeats.
static func names_in(text: String) -> PackedStringArray:
	var found := PackedStringArray()
	for m in _name.search_all(text):
		if m.get_string(1) not in found:
			found.append(m.get_string(1))
	return found


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
