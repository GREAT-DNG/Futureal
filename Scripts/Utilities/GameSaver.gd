extends Node

const PASSWORD: String = ":)"
const PATH: String = "user://saves/"

var save_file: File = File.new()
var save_directory: Directory = Directory.new()

func save(level_number: int, health: float, guns_collection: Array, active_gun_number: int) -> void:
	var data: Dictionary = {
		"health": health,
		"guns_collection": guns_collection,
		"active_gun_number": active_gun_number}
	
	if !save_directory.dir_exists(PATH):
		# warning-ignore:return_value_discarded
		save_directory.make_dir(PATH)
	
	# warning-ignore:return_value_discarded
	save_file.open_encrypted_with_pass(PATH + "F" + var2str(level_number), File.WRITE, PASSWORD)
	save_file.store_line(to_json(data))
	save_file.close()
	
	print("[" + Time.get_time_string_from_system() + "] Game saved")

func get_health(level_number: int) -> float:
	# warning-ignore:return_value_discarded
	save_file.open_encrypted_with_pass(PATH + "F" + var2str(level_number), File.READ, PASSWORD)
	return parse_json(save_file.get_line()).health

func get_guns_collection(level_number: int) -> Array:
	# warning-ignore:return_value_discarded
	save_file.open_encrypted_with_pass(PATH + "F" + var2str(level_number), File.READ, PASSWORD)
	var result: Array = parse_json(save_file.get_line()).guns_collection
	
	for i in range(result.size()):
		result[i].id = int(result[i].id)
		result[i].bullets = int(result[i].bullets)
		result[i].loaded_bullets = int(result[i].loaded_bullets)
		result[i].clip_size = int(result[i].clip_size)
	
	return result

func get_active_gun_number(level_number: int) -> int:
	# warning-ignore:return_value_discarded
	save_file.open_encrypted_with_pass(PATH + "F" + var2str(level_number), File.READ, PASSWORD)
	return int(parse_json(save_file.get_line()).active_gun_number)

func is_level_complete(level_number: int) -> bool:
	return save_file.file_exists(PATH + "F" + var2str(level_number))
