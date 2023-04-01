var save_file = File.new()

func save(var fullscreen, var mute, var autoreload, var show_actions, var show_trails):
	var data = {
		"fullscreen": fullscreen,
		"mute": mute,
		"autoreload": autoreload,
		"show_actions": show_actions,
		"show_trails": show_trails}
		
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
	
func get_show_trails_state():
	save_file.open("user://settings.json", File.READ)
	return parse_json(save_file.get_line()).show_trails
	
func get_show_actions_state():
	save_file.open("user://settings.json", File.READ)
	return parse_json(save_file.get_line()).show_actions
	
func check_settings():
	if is_settings_exsists():
		return is_settings_correct()
	
	fix_settings()
	return false
	
func fix_settings():
	save(false, false, false, false, false)
	
func is_settings_exsists():
	return save_file.file_exists("user://settings.json")
	
# Settings may be incorrect if they were created by the older version of the game
func is_settings_correct():
	save_file.open("user://settings.json", File.READ)
	
	var data = parse_json(save_file.get_line())
	
	if !data.has("fullscreen"):
		return false
	if !data.has("mute"):
		return false
	if !data.has("autoreload"):
		return false
	if !data.has("show_actions"):
		return false
	if !data.has("show_trails"):
		return false
		
	return true;
