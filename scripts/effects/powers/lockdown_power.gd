class_name LockdownPower
extends ShiverPower

## Shiver under the Hacker AI's name: its owner's next card costs 1 more.


func _init(_amount := 1) -> void:
	super(_amount)
	name = "Lockdown"
