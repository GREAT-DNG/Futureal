extends Node

var settings_saver = load("res://Scripts/Utilities/SettingsSaver.gd").new()

func save_settings():
	settings_saver.save($"../SettingsPanel/FullscreenCheckButton".pressed, \
	$"../SettingsPanel/MuteCheckButton".pressed, \
	$"../SettingsPanel/AutoreloadCheckButton".pressed, \
	$"../SettingsPanel/ShowActionsCheckButton".pressed, \
	$"../SettingsPanel/ShowTrailsCheckButton".pressed)
	
func _on_BackButton_button_down():
	$"../AudioStreamPlayer".play()
	$"../SettingsPanel".hide()
	$"../MainPanel".show()
	
func _on_FullscreenCheckButton_button_up():
	$"../AudioStreamPlayer".play()
	OS.window_fullscreen = $"../SettingsPanel/FullscreenCheckButton".pressed
	if(!$"../SettingsPanel/FullscreenCheckButton".pressed):
		OS.window_size = Vector2(800, 600)
	save_settings()
	
func _on_MuteCheckButton_button_up():
	$"../AudioStreamPlayer".play()
	AudioServer.set_bus_mute(0, $"../SettingsPanel/MuteCheckButton".pressed)
	save_settings()
	
func _on_AutoreloadCheckButton_button_up():
	$"../AudioStreamPlayer".play()
	save_settings()
	
func _on_ShowActionsCheckButton_button_up():
	$"../AudioStreamPlayer".play()
	save_settings()
	
func _on_ShowTrailsCheckButton_button_up():
	$"../AudioStreamPlayer".play()
	save_settings()
