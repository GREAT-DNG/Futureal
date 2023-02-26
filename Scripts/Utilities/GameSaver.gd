var save_file = File.new()
var password = ":)"

func save(var level_num, var health, var money, var guns_collection):
	var data = {
		"health": health,
		"money": money,
		"guns_collection": guns_collection}
		
	save_file.open_encrypted_with_pass("user://F" + var2str(level_num), File.WRITE, password)
	save_file.store_line(to_json(data))
	save_file.close()
	
func get_health(var level_num):
	save_file.open_encrypted_with_pass("user://F" + var2str(level_num), File.READ, password)
	return parse_json(save_file.get_line()).health
	
func get_money(var level_num):
	save_file.open_encrypted_with_pass("user://F" + var2str(level_num), File.READ, password)
	return int(parse_json(save_file.get_line()).money)
	
func get_guns_collection(var level_num):
	save_file.open_encrypted_with_pass("user://F" + var2str(level_num), File.READ, password)
	var result = parse_json(save_file.get_line()).guns_collection
	
	for i in range(result.size()):
		result[i].id = int(result[i].id)
		result[i].bullets = int(result[i].bullets)
		result[i].loaded_bullets = int(result[i].loaded_bullets)
		result[i].clip_size = int(result[i].clip_size)
	
	return result
	
func is_level_complete(var level_num):
	return save_file.file_exists("user://F" + var2str(level_num))
