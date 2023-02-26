extends Panel

func _on_LoadPanel_visibility_changed():
	var directory = Directory.new()
	directory.open(OS.get_executable_path())
	directory.list_dir_begin()
	
	while true:
		var file = directory.get_next()
		if file == "":
			break
		if file.ends_with(".tscn"):
			file.erase(file.find(".tscn"), 5)
			$ItemList.add_item(file)
	
	directory.list_dir_end()
	
func _on_LoadButton_button_down():
# warning-ignore:return_value_discarded
	var executable_path = OS.get_executable_path()
	executable_path.erase(executable_path.find_last("/") + 1, executable_path.length() - executable_path.find_last("/") + 1)
	var file = $ItemList.get_item_text($ItemList.get_selected_items()[0]) + ".tscn"
	get_tree().change_scene_to(load(executable_path + file))
	
func _on_BackButton_button_down():
	hide()
