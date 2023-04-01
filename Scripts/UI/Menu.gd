extends Control

var first_scene
var game_saver = load("res://Scripts/Utilities/GameSaver.gd").new()
var settings_saver = load("res://Scripts/Utilities/SettingsSaver.gd").new()

func _ready():
	if settings_saver.check_settings():
		$SettingsPanel/FullscreenCheckButton.pressed = settings_saver.get_fullscreen_state()
		OS.window_fullscreen = $SettingsPanel/FullscreenCheckButton.pressed
		if(!$SettingsPanel/FullscreenCheckButton.pressed):
			OS.window_size = Vector2(800, 600)
		
		$SettingsPanel/MuteCheckButton.pressed = settings_saver.get_mute_state()
		AudioServer.set_bus_mute(0, $SettingsPanel/MuteCheckButton.pressed)
		
		$SettingsPanel/AutoreloadCheckButton.pressed = settings_saver.get_autoreload_state()
		
		$SettingsPanel/ShowActionsCheckButton.pressed = settings_saver.get_show_actions_state()
		
		$SettingsPanel/ShowTrailsCheckButton.pressed = settings_saver.get_show_trails_state()
	
# warning-ignore:unused_argument
func _input(event):
	if Input.is_key_pressed(KEY_F1):
			$HelpPanel.show()
	
func save_settings():
	settings_saver.save($SettingsPanel/FullscreenCheckButton.pressed, \
	$SettingsPanel/MuteCheckButton.pressed, \
	$SettingsPanel/AutoreloadCheckButton.pressed, \
	$SettingsPanel/ShowActionsCheckButton.pressed, \
	$SettingsPanel/ShowTrailsCheckButton.pressed)
	
# Main Panel
func _on_PlayButton_button_down():
	$AudioStreamPlayer.play()
	
	$MainPanel.hide()
	$PlayPanel.show()
	
	var last_completed_level = 0
	
	for i in range(3):
		if game_saver.is_level_complete(i):
			last_completed_level = i
	
	last_completed_level += 1
	
	for i in range(last_completed_level):
		get_node(NodePath("PlayPanel/Level" + var2str(i) + "Button")).disabled = false
	
func _on_HelpOKButton_button_down():
	$AudioStreamPlayer.play()
	
	$HelpPanel.hide()
	
func _on_SettingsButton_button_down():
	$AudioStreamPlayer.play()
	
	$MainPanel.hide()
	$SettingsPanel.show()
	
func _on_QuitButton_button_down():
	$AudioStreamPlayer.play()
	
	get_tree().quit(0)
	
func _on_BackButton_button_down():
	$AudioStreamPlayer.play()
	
	$PlayPanel.hide()
	$SettingsPanel.hide()
	$MainPanel.show()
	
func _on_AcceptButton_button_down():
	$AudioStreamPlayer.play()
	
	$SettingsPanel.hide()
	$MainPanel.show()
	
# Play Panel
func _on_Level1Button_button_down():
	$AudioStreamPlayer.play()
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level1.tscn"))
	
func _on_Level2Button_button_down():
	$AudioStreamPlayer.play()
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level2.tscn"))
	
func _on_Level3Button_button_down():
	$AudioStreamPlayer.play()
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level3.tscn"))
	
func _on_LoadButton_button_down():
	$AudioStreamPlayer.play()
	
#	$PlayPanel/FileDialog.popup()
	$PlayPanel/LoadPanel.show()
	
	
func _on_FileDialog_file_selected(path):
	$AudioStreamPlayer.play()
	
	if path.get_extension() == "tscn":
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(load(path))
	else:
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(load("res://Scenes/Menu.tscn"))
	
func _on_FullscreenCheckButton_button_up():
	$AudioStreamPlayer.play()
	
	OS.window_fullscreen = $SettingsPanel/FullscreenCheckButton.pressed
	if(!$SettingsPanel/FullscreenCheckButton.pressed):
		OS.window_size = Vector2(800, 600)
	save_settings()
	
func _on_MuteCheckButton_button_up():
	$AudioStreamPlayer.play()
	
	AudioServer.set_bus_mute(0, $SettingsPanel/MuteCheckButton.pressed)
	save_settings()
	
func _on_AutoreloadCheckButton_button_up():
	$AudioStreamPlayer.play()
	
	save_settings()
	
func _on_ShowActionsCheckButton_button_up():
	$AudioStreamPlayer.play()
	
	save_settings()
	
func _on_ShowTrailsCheckButton_button_up():
	$AudioStreamPlayer.play()
	
	save_settings()
