extends Control

## End of a run, won or lost (RunState.finish_run): a big Victory / Defeated title, where it ended
## (and what killed you), a summary of the run, the artifacts collected, then New Run / Main Menu.

const TITLE_FONT := preload("res://assets/fonts/PirataOne-Regular.ttf")
const BACKGROUND := preload("res://assets/main_menu/background.jpg")
const COLOR_WON := Color("#ffd45a")
const COLOR_LOST := Color("#ff6b6b")
const COLOR_DIM := Color("#8d93a5")
const ARTIFACT_SIZE := 64.0


func _ready() -> void:
	var result := RunState.last_result
	var won: bool = result.get("won", false)

	var background := TextureRect.new()
	background.texture = BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.78)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 22)
	center.add_child(box)

	var title := _label("Victory" if won else "Defeated", 140, COLOR_WON if won else COLOR_LOST)
	title.add_theme_font_override("font", TITLE_FONT)
	box.add_child(title)
	var subtitle := "You defeated %s and escaped the spire." % result.get("killer", "the final boss") if won \
		else "Slain by %s on %s." % [result.get("killer", "an enemy"), result.get("where", "the map")]
	box.add_child(_label(subtitle, 32, Color.WHITE))

	var stats := GridContainer.new()
	stats.columns = 4
	stats.add_theme_constant_override("h_separation", 48)
	stats.add_theme_constant_override("v_separation", 10)
	box.add_child(_centered(stats))
	for entry in [
		["Floors cleared", str(result.get("floors_cleared", 0))],
		["Rooms built", str(result.get("rooms_built", 0))],
		["Fights won", str(result.get("fights_won", 0))],
		["Level", str(result.get("level", 0))],
		["Cards in deck", str(result.get("deck", 0))],
		["Artifacts", str(result.get("artifacts", []).size())],
		["Gold", str(result.get("gold", 0))],
		["Seed", str(result.get("seed", 0))],
	]:
		var cell := VBoxContainer.new()
		cell.add_child(_label(entry[1], 40, Color.WHITE))
		cell.add_child(_label(entry[0], 22, COLOR_DIM))
		stats.add_child(cell)

	var artifacts: Array = result.get("artifacts", [])
	if not artifacts.is_empty():
		var row := HFlowContainer.new()
		row.alignment = FlowContainer.ALIGNMENT_CENTER
		row.custom_minimum_size.x = 900
		row.add_theme_constant_override("h_separation", 8)
		for artifact: BaseArtifact in artifacts:
			var icon := TextureRect.new()
			icon.texture = artifact.image
			icon.tooltip_text = "%s\n%s" % [artifact.name, artifact.plain_description()]
			icon.custom_minimum_size = Vector2.ONE * ARTIFACT_SIZE
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			row.add_child(icon)
		box.add_child(row)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 24)
	box.add_child(buttons)
	for entry in [["New Run", _on_new_run_pressed], ["Main Menu", _on_main_menu_pressed]]:
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(260, 64)
		button.add_theme_font_size_override("font_size", 30)
		button.pressed.connect(entry[1])
		buttons.add_child(button)


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _centered(control: Control) -> CenterContainer:
	var holder := CenterContainer.new()
	holder.add_child(control)
	return holder


func _on_new_run_pressed() -> void:
	SaveGame.delete()
	RunState.start_new_run()
	get_tree().change_scene_to_file(RunState.MAP_SCENE)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(RunState.MENU_SCENE)
