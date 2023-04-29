var save_file = File.new()
var path = "user://settings.json"

func save(var fullscreen, var mute, var autoreload, var show_actions, var show_trails, var crt_effect):
	var data = {
		"fullscreen": fullscreen,
		"mute": mute,
		"autoreload": autoreload,
		"show_actions": show_actions,
		"show_trails": show_trails,
		"crt_effect": crt_effect}
		
	save_file.open(path, File.WRITE)
	save_file.store_line(to_json(data))
	save_file.close()
	
func get_fullscreen_state():
	save_file.open(path, File.READ)
	return parse_json(save_file.get_line()).fullscreen
	
func get_mute_state():
	save_file.open(path, File.READ)
	return parse_json(save_file.get_line()).mute
	
func get_autoreload_state():
	save_file.open(path, File.READ)
	return parse_json(save_file.get_line()).autoreload
	
func get_show_trails_state():
	save_file.open(path, File.READ)
	return parse_json(save_file.get_line()).show_trails
	
func get_show_actions_state():
	save_file.open(path, File.READ)
	return parse_json(save_file.get_line()).show_actions
	
func get_crt_effect_state():
	save_file.open(path, File.READ)
	return parse_json(save_file.get_line()).crt_effect
	
func check_settings():
	if !is_settings_exsists() or !is_settings_correct():
		fix_settings()
	
func fix_settings():
	save(true, false, false, true, true, true)
	
func is_settings_exsists():
	return save_file.file_exists(path)
	
# Settings may be incorrect if they were created by the older version of the game
func is_settings_correct():
	save_file.open(path, File.READ)
	
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
	if !data.has("crt_effect"):
		return false
		
	return true;
