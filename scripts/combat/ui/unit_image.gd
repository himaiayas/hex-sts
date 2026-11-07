class_name UnitImage
extends TextureRect

## A unit's sprite. Loops idle_frames, and show_pose() swaps in another
## sprite (attack, guard) for POSE_TIME before going back to idle.
## A single-image enemy just has one idle frame.

const PLAYER_IDLE: Array[Texture2D] = [
	preload("res://assets/characters/char_idle1.png"),
	preload("res://assets/characters/char_idle2.png"),
	preload("res://assets/characters/char_idle3.png"),
]
const PLAYER_ATTACK := preload("res://assets/characters/char_attack.png")
const PLAYER_GUARD := preload("res://assets/characters/char_guard.png")
const IDLE_FRAME_TIME := 0.25  # seconds per idle frame
const POSE_TIME := 0.5

var idle_frames: Array[Texture2D] = PLAYER_IDLE

var _time := 0.0
var _pose_left := 0.0


func _ready() -> void:
	_process(0.0)  # show the first frame right away, not one frame late


func _process(delta: float) -> void:
	_time += delta
	if _pose_left > 0.0:
		_pose_left -= delta
		return
	texture = idle_frames[int(_time / IDLE_FRAME_TIME) % idle_frames.size()]


func show_pose(pose: Texture2D) -> void:
	texture = pose
	_pose_left = POSE_TIME
