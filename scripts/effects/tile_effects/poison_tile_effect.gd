class_name PoisonTileEffect
extends BaseTileEffect

func _init() -> void:
    super("Poison", "Inflicts poison on the target.")   

func get_color() -> Color:
    return Color("#00ff00")  # Green color for poison