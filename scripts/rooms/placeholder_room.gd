extends Control

## Temporary scene for rooms that aren't built yet: shows the room's name and a Leave button.
## Shared by several room scenes; each scene sets its own body text.

@onready var _title: Label = %Title


func _ready() -> void:
	if RunState.current_room:
		_title.text = RunState.current_room.display_name()


func _on_leave_pressed() -> void:
	RunState.leave_room()
