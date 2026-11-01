@abstract class_name BasePower

extends BaseEffect

## A power on a unit (CombatUnit.statuses), shown as a badge under its grid.
## amount = stacks: applying a power the unit already has adds to it.

var amount := 1

func _init(_name: String, _description: String, _amount := 1, _turns := -1) -> void:
	super(_name, _description, _turns)
	amount = _amount


@abstract func get_color() -> Color

## Badge art. ponytail: placeholder until each power has its own icon.
func get_icon() -> Texture2D:
	return preload("res://icon.svg")


func copy() -> BaseEffect:
	var power := super() as BasePower
	power.amount = amount
	return power


func stack(other: BaseEffect) -> void:
	super(other)
	amount += (other as BasePower).amount
