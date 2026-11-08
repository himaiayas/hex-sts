class_name FirewallPower
extends BasePower

## The Hacker AI's passive: debuff tile effects (Poison, Fracture) can't be put on its tiles (ApplyEffectTile).


func _init(_amount := 1) -> void:
	super("Firewall", "Immune to debuffs: Poison and Fracture can't be put on it.", _amount)
	show_amount = false


func get_color() -> Color:
	return Color("#4fd18b")
