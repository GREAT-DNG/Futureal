extends FileDialog

func _on_LoadLevelFileDialog_file_selected(path):
	# warning-ignore:return_value_discarded
		get_tree().change_scene_to(load(path))
	
func _on_LoadLevelFileDialog_mouse_entered():
#	set_default_cursor_shape(Control.CURSOR_ARROW)
	pass
	
func _on_LoadLevelFileDialog_mouse_exited():
	pass # Replace with function body.
