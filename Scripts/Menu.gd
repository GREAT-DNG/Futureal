extends Control

var first_scene
var game_saver = load("res://Scripts/GameSaver.gd").new()

# Main Panel
func _on_PlayButton_button_down():
	$MainPanel.hide()
	$PlayPanel.show()
	
	var last_completed_level = 0
	
	for i in range(3):
		if game_saver.is_level_complete(i):
			last_completed_level = i
	
	last_completed_level += 1
	
	for i in range(last_completed_level):
		get_node(NodePath("PlayPanel/Level" + var2str(i) + "Button")).disabled = false
	
func _on_SettingsButton_button_down():
	$MainPanel.hide()
	$SettingsPanel.show()
	
func _on_QuitButton_button_down():
	get_tree().quit(0)
	
# Settings Panel
func _on_BackButton_button_down():
	$PlayPanel.hide()
	$SettingsPanel.hide()
	$MainPanel.show()
	
func _on_AcceptButton_button_down():
	$SettingsPanel.hide()
	$MainPanel.show()
	
func _on_Level1Button_button_down():
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level1.tscn"))
	
func _on_Level2Button_button_down():
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level2.tscn"))
	
func _on_Level3Button_button_down():
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level3.tscn"))
	
func _on_LoadButton_button_down():
	$PlayPanel/FileDialog.popup()
	
func _on_FileDialog_file_selected(path):
	if path.get_extension() == "tscn":
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(load(path))
	else:
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(load("res://Scenes/Menu.tscn"))
