extends Control

var load_level_thread = Thread.new()

onready var audiostreamplayer = get_parent().get_parent().get_node("AudioStreamPlayer")

func _ready() -> void:
	var last_completed_level: int
	
	for i in range(9):
		if GameSaver.is_level_complete(i):
			last_completed_level = i
	
	last_completed_level += 1
	
	if last_completed_level < 6:
		$"TabContainer/Part 3".queue_free()
	if last_completed_level < 3:
		$"TabContainer/Part 2".queue_free()
	
	for i in range(last_completed_level):
		i += 1
		if i <= 3:
			get_node("TabContainer/Part 1/Level" + var2str(i) + "Button").disabled = false
		elif i <= 6:
			get_node("TabContainer/Part 2/Level" + var2str(i) + "Button").disabled = false
		elif i <= 9:
			get_node("TabContainer/Part 3/Level" + var2str(i) + "Button").disabled = false
		i -= 1
	
	$TabContainer.current_tab = $TabContainer.get_tab_count() - 1

func _on_LoadButton_pressed() -> void:
	audiostreamplayer.play()
	$LoadLevelFileDialog.popup()

func _on_LevelButton_pressed(part: int, level: int) -> void:
	audiostreamplayer.play()
	$"../../AnimationPlayer".play("Loading")
	$LoadingPanel/CRTColorRect.visible = SettingsManager.get_setting("crt")
	$LoadingPanel.show()
	load_level_thread.start(self, "load_level", "res://Scenes/Levels/Singleplayer/Part " + var2str(part) + "/Level" + var2str(level) + ".tscn")

func load_level(path: String) -> Resource:
	var level = ResourceLoader.load(path)
	call_deferred("change_scene")
	return level

func change_scene() -> void:
	var scene = load_level_thread.wait_to_finish()
	if scene is PackedScene:
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(scene)
	else:
		$"../../AnimationPlayer".stop()
		$LoadingPanel.hide()
	
	print("[" + Time.get_time_string_from_system() + "] Singleplayer game started")

func _on_TabContainer_tab_changed(_tab: int) -> void:
	audiostreamplayer.play()
