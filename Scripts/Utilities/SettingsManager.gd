extends Node

const GAME_VERSION: String = "0.0"
const SETTINGS_PATH: String = "user://settings.json"
const CONTROLS_PATH: String = "user://controls.json"
const DEFAULT_SETTINGS_DATA: Dictionary = {
		"autoreload": true,
		"autochange": true,
		"fullscreen": true,
		"mute": false,
		"actions": true,
		"trails": true,
		"cursor": true,
		"crt": true,
		"exactness": false,
		"multiplayer": {
				"nickname": "",
				"ip": "127.0.0.1",
				},
		}

var file: File = File.new()
var settings_data: Dictionary

func _ready() -> void:
	print("[" + Time.get_time_string_from_system() + "] Futureal v" + GAME_VERSION + " started")
	if OS.is_debug_build():
		print("[" + Time.get_time_string_from_system() + "] Debug on")
	if OS.has_feature("editor"):
		print("[" + Time.get_time_string_from_system() + "] Editor on")
	
	if file.file_exists(SETTINGS_PATH):
		# warning-ignore:return_value_discarded
		file.open(SETTINGS_PATH, File.READ)
		settings_data = JSON.parse(file.get_as_text()).result
		file.close()
		
		print("[" + Time.get_time_string_from_system() + "] Settings loaded")
	else:
		settings_data = DEFAULT_SETTINGS_DATA.duplicate()
	
	OS.window_fullscreen = get_setting("fullscreen")
	if !get_setting("fullscreen"):
		OS.window_position = (OS.get_screen_size() - Vector2(800, 600)) / 2
		OS.window_size = Vector2(800, 600)
	
	AudioServer.set_bus_mute(0, get_setting("mute"))
	
	if !get_setting("cursor"):
		Input.set_custom_mouse_cursor(null)
	
	if file.file_exists(CONTROLS_PATH):
		# warning-ignore:return_value_discarded
		file.open(CONTROLS_PATH, File.READ)
		var controls_data = JSON.parse(file.get_as_text()).result
		file.close()
		for i in controls_data:
			if InputMap.has_action(i):
				InputMap.action_erase_events(i)
				for j in controls_data[i]:
					if j[0] == "K":
						var control = InputEventKey.new()
						control.scancode = j[1]
						InputMap.action_add_event(i, control)
					elif j[0] == "M":
						var control = InputEventMouseButton.new()
						control.button_index = j[1]
						InputMap.action_add_event(i, control)
						
		print("[" + Time.get_time_string_from_system() + "] Controls loaded")

func get_setting(name: String):
	if settings_data.has(name):
		return settings_data[name]
	return DEFAULT_SETTINGS_DATA[name]

func save_setting(name: String, value) -> void:
	settings_data[name] = value
	# warning-ignore:return_value_discarded
	file.open(SETTINGS_PATH, File.WRITE)
	file.store_string(JSON.print(settings_data, "\t"))
	file.close()
	
	print("[" + Time.get_time_string_from_system() + "] Setting \"" + name + "\" saved")

func save_controls() -> void:
	var controls_data: Dictionary = {}
	for i in InputMap.get_actions():
		if i.find("ui_") != 0:
			controls_data[i] = []
			for j in InputMap.get_action_list(i).size():
				controls_data[i].append([])
				if InputMap.get_action_list(i)[j] is InputEventKey:
					controls_data[i][j].append("K")
					controls_data[i][j].append(InputMap.get_action_list(i)[j].scancode)
				elif InputMap.get_action_list(i)[j] is InputEventMouseButton:
					controls_data[i][j].append("M")
					controls_data[i][j].append(InputMap.get_action_list(i)[j].button_index)
	
	# warning-ignore:return_value_discarded
	file.open(CONTROLS_PATH, File.WRITE)
	file.store_string(JSON.print(controls_data, "\t"))
	file.close()
	
	print("[" + Time.get_time_string_from_system() + "] Controls saved")
