class_name HoverPower
extends AerialPower

## Aerial under the Scout Drone's name: the first amount hits on it each opponent turn miss.


func _init(_amount := 1) -> void:
	super(_amount)
	name = "Hover"
	description = "The first hit on it each of your turns misses, plus one more per extra Hover. Shield and Pierce don't matter."
