extends FileDialog

func _on_LoadLevelFileDialog_file_selected(path: String) -> void:
	var level = load(path)
	if level is PackedScene:
		if SettingsManager.get_setting("cursor"):
			Input.set_custom_mouse_cursor(load("res://Sprites/UI/Cursor.png"))
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(level)
		print("[" + Time.get_time_string_from_system() + "] Singleplayer game (external level) started")

func _on_LoadLevelFileDialog_draw() -> void:
	Input.set_custom_mouse_cursor(null)

func _on_LoadLevelFileDialog_hide() -> void:
	if SettingsManager.get_setting("cursor"):
		Input.set_custom_mouse_cursor(load("res://Sprites/UI/Cursor.png"))
