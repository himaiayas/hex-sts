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
const IDLE_LOOP_TIME := 0.75  # seconds per idle loop, however many frames it has
const POSE_TIME := 0.5

var idle_frames: Array[Texture2D] = PLAYER_IDLE

var _time := 0.0
var _pose: Texture2D
var _pose_left := 0.0


func _ready() -> void:
	_process(0.0)  # show the first frame right away, not one frame late


func _process(delta: float) -> void:
	_time += delta
	if _pose_left > 0.0:
		_pose_left -= delta
		return
	if _pose:
		_pose = null
		queue_redraw()
	texture = idle_frames[int(_time / IDLE_LOOP_TIME * idle_frames.size()) % idle_frames.size()]


func show_pose(pose: Texture2D) -> void:
	_pose = pose
	texture = null  # _draw() shows the pose instead
	_pose_left = POSE_TIME
	queue_redraw()


## A pose is drawn at the idle frame's pixel scale and right-aligned with it, so a wider pose
## (the Dragon's fire breath) keeps the body in place and spills left toward the player.
func _draw() -> void:
	if _pose == null:
		return
	var idle := idle_frames[0].get_size()
	var scale := minf(size.x / idle.x, size.y / idle.y)
	var pose_size := _pose.get_size() * scale
	var right := (size.x + idle.x * scale) / 2.0
	draw_texture_rect(_pose, Rect2(Vector2(right - pose_size.x, (size.y - pose_size.y) / 2.0), pose_size), false)
