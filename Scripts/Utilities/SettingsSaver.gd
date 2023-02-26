var save_file = File.new()

func save(var fullscreen, var mute, var autoreload):
	var data = {
		"fullscreen": fullscreen,
		"mute": mute,
		"autoreload": autoreload}
		
	save_file.open("user://settings.json", File.WRITE)
	save_file.store_line(to_json(data))
	save_file.close()
	
func get_fullscreen_state():
	save_file.open("user://settings.json", File.READ)
	return parse_json(save_file.get_line()).fullscreen
	
func get_mute_state(): # doesn't always work, i'll fix it soon. maybe...
	save_file.open("user://settings.json", File.READ)
	return parse_json(save_file.get_line()).mute
	
func get_autoreload_state():
	save_file.open("user://settings.json", File.READ)
	return parse_json(save_file.get_line()).autoreload
	
func is_settings_exsists():
	return save_file.file_exists("user://settings.json")
