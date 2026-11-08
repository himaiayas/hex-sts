class_name ConsumePower
extends RegenPower

## Regen under the Nano Swarm's name: heals amount random damaged tiles at the start of its turn.


func _init(_amount := 1) -> void:
	super(_amount)
	name = "Consume"
	description = "At the start of its turn, heals 1 damaged tile per Consume."
