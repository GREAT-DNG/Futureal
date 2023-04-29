extends Control

var first_scene
var settings_saver = load("res://Scripts/Utilities/SettingsSaver.gd").new()

func _ready():
	settings_saver.check_settings()
	
	$SettingsPanel/FullscreenCheckButton.pressed = settings_saver.get_fullscreen_state()
	OS.window_fullscreen = $SettingsPanel/FullscreenCheckButton.pressed
	if(!$SettingsPanel/FullscreenCheckButton.pressed):
		OS.window_size = Vector2(800, 600)
		
	$SettingsPanel/MuteCheckButton.pressed = settings_saver.get_mute_state()
	AudioServer.set_bus_mute(0, $SettingsPanel/MuteCheckButton.pressed)
	
	$SettingsPanel/AutoreloadCheckButton.pressed = settings_saver.get_autoreload_state()
	
	$SettingsPanel/ShowActionsCheckButton.pressed = settings_saver.get_show_actions_state()
	
	$SettingsPanel/ShowTrailsCheckButton.pressed = settings_saver.get_show_trails_state()
	
	$SettingsPanel/CRTEffectCheckButton.pressed = settings_saver.get_crt_effect_state()
	
# warning-ignore:unused_argument
func _input(event):
	if Input.is_key_pressed(KEY_F1):
			$HelpPanel.show()
	
func _on_PlayButton_button_down():
	$AudioStreamPlayer.play()
	
	$MainPanel.hide()
	$PlayPanel.show()
	
func _on_SettingsButton_button_down():
	$AudioStreamPlayer.play()
	
	$MainPanel.hide()
	$SettingsPanel.show()
	
func _on_QuitButton_button_down():
	$AudioStreamPlayer.play()
	
	get_tree().quit(0)
