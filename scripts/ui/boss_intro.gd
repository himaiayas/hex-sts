extends CanvasLayer

## Boss transition: fade to black, show the boss name in big white text, switch to the
## combat scene behind it, then fade back in. Lives on the tree root so it survives the
## scene change, and blocks clicks until it's gone.

const FADE_TO_BLACK := 1.0  # seconds
const NAME_FADE_IN := 0.6
const NAME_HOLD := 1.5
const FADE_FROM_BLACK := 0.8

@onready var _black: ColorRect = %Black
@onready var _name: Label = %BossName


func play(boss_name: String, scene_path: String) -> void:
	_name.text = boss_name
	_black.modulate.a = 0.0
	_name.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(_black, "modulate:a", 1.0, FADE_TO_BLACK)
	tween.tween_property(_name, "modulate:a", 1.0, NAME_FADE_IN)
	tween.tween_interval(NAME_HOLD)
	await tween.finished

	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame  # let the combat scene load behind the black
	await get_tree().process_frame

	tween = create_tween().set_parallel()
	tween.tween_property(_name, "modulate:a", 0.0, FADE_FROM_BLACK)
	tween.tween_property(_black, "modulate:a", 0.0, FADE_FROM_BLACK)
	await tween.finished
	queue_free()
