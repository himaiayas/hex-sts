@abstract class_name BasePower

extends BaseEffect

## A power on a unit (CombatUnit.statuses), shown as a badge under its grid.
## amount = stacks: applying a power the unit already has adds to it.

var amount := 1
var show_amount := true  # false: no number on the badge or in the tooltip title (Full Moon)

func _init(_name: String, _description: String, _amount := 1, _turns := -1) -> void:
	super(_name, _description, _turns)
	amount = _amount


@abstract func get_color() -> Color


## The badge tooltip, with this power's amount filled in. description stays the generic
## per-stack text for card keywords.
func get_description() -> String:
	return description


## True if a hit on one of the owner's live tiles misses (Aerial, Ethereal). Asked for every hit.
func dodges(_combat: CombatState, _unit: CombatUnit) -> bool:
	return false


## Called on the player's powers after each card they play finishes.
func on_card_played(_combat: CombatState, _unit: CombatUnit, _card: BaseCard) -> void:
	pass


## Called on the player's powers whenever a card is exhausted (Oblation).
func on_card_exhausted(_combat: CombatState, _unit: CombatUnit, _card: BaseCard) -> void:
	pass


## Called on the owner's powers when one of its tiles gets a tile effect it didn't have (Living Wall).
## No flush: what it changes plays with whatever applied the effect.
func on_tile_effect_gained(_combat: CombatState, _unit: CombatUnit, _cell: Vector2i, _effect: BaseTileEffect) -> void:
	pass


## "1 tile", "3 tiles".
static func plural(n: int, word: String) -> String:
	return "%d %s%s" % [n, word, "" if n == 1 else "s"]

## Badge art: assets/powers/i_<name>.png, named after the script (strength_power.gd -> i_strength.png).
## A power without one shows PLACEHOLDER_ICON. Loaded once per power type.
func get_icon() -> Texture2D:
	var script_path: String = get_script().resource_path
	if not _icons.has(script_path):
		var path := "res://assets/powers/i_%s.png" % script_path.get_file().get_basename().trim_suffix("_power")
		_icons[script_path] = load(path) if ResourceLoader.exists(path) else PLACEHOLDER_ICON
	return _icons[script_path]


const PLACEHOLDER_ICON := preload("res://icon.svg")
static var _icons := {}  # script path -> its badge texture


func copy() -> BaseEffect:
	var power := super() as BasePower
	power.amount = amount
	return power


func stack(other: BaseEffect) -> void:
	super(other)
	amount += (other as BasePower).amount
