extends Control


func _on_start_pressed() -> void:
	RunState.start_new_run()
	get_tree().change_scene_to_file(RunState.MAP_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_toggled() -> void:
	$Credits.visible = not $Credits.visible
	$Logo.visible = not $Credits.visible
	$Menu.visible = not $Credits.visible
