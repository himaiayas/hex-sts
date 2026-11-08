class_name NewMoonPower
extends BasePower

## The Werewolf's Human form. Only a label: it swaps this for Full Moon when it plans a Wolf move.


func _init(_amount := 1) -> void:
	super("New Moon", "Human form. Changes to Full Moon next turn, when your Attack cards hit it harder.", _amount)
	show_amount = false


func get_color() -> Color:
	return Color("#d8d8ff")
