class_name RuneArmorPower
extends WardPower

## Ward under the Magic Golem's name: at the start of its turn, shields amount random tiles of its own.


func _init(_amount := 1) -> void:
	super(_amount)
	name = "Rune Armor"
	description = "At the start of its turn, Shield 1 random tile of its own per Rune Armor."
