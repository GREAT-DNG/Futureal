extends CanvasLayer

var players_tree_items: Dictionary = {}

func _ready() -> void:
	$CRTColorRect.visible = SettingsManager.get_setting("crt")
	$FPSLabel.visible = OS.is_debug_build()
	$PausePanel/RestartButton.disabled = MultiplayerManager.is_multiplayer()
	
	if MultiplayerManager.is_multiplayer():
		$GameInfoPanel/Multiplayer.show()
		$GameInfoPanel/Multiplayer/PlayersTree.set_column_expand(0, true)
		$GameInfoPanel/Multiplayer/PlayersTree.set_column_min_width(0, 2.5)
		$GameInfoPanel/Multiplayer/PlayersTree.set_column_title(0, "Players")
		$GameInfoPanel/Multiplayer/PlayersTree.set_column_expand(1, true)
		$GameInfoPanel/Multiplayer/PlayersTree.set_column_title(1, "Kills")
		$GameInfoPanel/Multiplayer/PlayersTree.set_column_expand(2, true)
		$GameInfoPanel/Multiplayer/PlayersTree.set_column_title(2, "Deaths")
		
		update_game_info()
	else:
		$GameInfoPanel/Singleplayer.show()
		$GameInfoPanel/Singleplayer/MapSprite.texture = generate_level_map()

func _process(_delta: float) -> void:
	if $FPSLabel.visible:
		$FPSLabel.text = "FPS: " + var2str(int(Engine.get_frames_per_second()))

func game_complete() -> void:
	$Stats.hide()
	$Final.show()

func player_killed() -> void:
	$GameOverPanel.show()

func show_game_info() -> void:
	$GameInfoPanel.show()
	update_game_info()

func hide_game_info() -> void:
	$GameInfoPanel.hide()

func update_game_info() -> void:
	if MultiplayerManager.is_multiplayer():
		$GameInfoPanel/Multiplayer/PlayersTree.clear()
		
		players_tree_items[0] = $GameInfoPanel/Multiplayer/PlayersTree.create_item() # root
		players_tree_items[get_tree().get_network_unique_id()] = $GameInfoPanel/Multiplayer/PlayersTree.create_item(players_tree_items[0])
		players_tree_items[get_tree().get_network_unique_id()].set_text(0, MultiplayerManager.nickname)
		players_tree_items[get_tree().get_network_unique_id()].set_text(1, var2str(MultiplayerManager.kills))
		players_tree_items[get_tree().get_network_unique_id()].set_text(2, var2str(MultiplayerManager.deaths))
		
		for i in MultiplayerManager.players:
			players_tree_items[i] = $GameInfoPanel/Multiplayer/PlayersTree.create_item(players_tree_items[0])
			players_tree_items[i].set_text(0, MultiplayerManager.players[i].nickname)
			players_tree_items[i].set_text(1, var2str(MultiplayerManager.players[i].kills))
			players_tree_items[i].set_text(2, var2str(MultiplayerManager.players[i].deaths))
	else:
		$GameInfoPanel/Singleplayer/MapSprite.offset = (-get_parent().position / 5).round()

func generate_level_map() -> ImageTexture:
	var blocks_tile_map_used_cells: Array = $"../../".get_node("BlocksTileMap").get_used_cells()
	var level_map: Image = Image.new()
	
	var max_x: int = 0
	var max_y: int = 0
	
	for i in blocks_tile_map_used_cells:
	# warning-ignore:narrowing_conversion
		max_x = max(max_x, abs(i.x))
	# warning-ignore:narrowing_conversion
		max_y = max(max_y, abs(i.y))
	
	max_x += 1
	max_y += 1
	
	level_map.create(max_x * 2, max_y * 2, false, Image.FORMAT_RGBA8)
	level_map.lock()
	
	for i in blocks_tile_map_used_cells:
		level_map.set_pixel(i.x + abs(max_x), i.y + abs(max_y), Color.white)
	
	level_map.unlock()
	# warning-ignore:narrowing_conversion
	# warning-ignore:narrowing_conversion
	level_map.resize(level_map.get_size().x * 10, level_map.get_size().y * 10, Image.INTERPOLATE_NEAREST)
	
	var level_map_texture: ImageTexture = ImageTexture.new()
	level_map_texture.create_from_image(level_map, 0)
	
	return level_map_texture

func refresh_panel(health: float, gun: Dictionary) -> void:
	$Stats/HealthLabel.text = var2str(stepify(health, 0.1))
	$Stats/GunLabel.text = gun.name + "\n" + var2str(gun.loaded_bullets) + "/" + var2str(gun.bullets)

func _on_ContinueButton_pressed() -> void:
	$AudioStreamPlayer.play()
	$PausePanel.hide()
	get_tree().paused = false
	$AnimationPlayer.play_backwards("Transition")
	if MultiplayerManager.is_multiplayer():
		get_parent().get_node("AnimationPlayer").rpc("play_backwards", "Inactive")

func _on_RestartButton_pressed() -> void:
	$AudioStreamPlayer.play()
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
	get_tree().paused = false

func _on_MenuButton_pressed() -> void:
	$AudioStreamPlayer.play()
	if MultiplayerManager.is_multiplayer():
		if get_tree().is_network_server():
			MultiplayerManager.rpc("end_game")
		else:
			MultiplayerManager.end_game()
	else:
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(load("res://Scenes/UI/Menu.tscn"))
		print("[" + Time.get_time_string_from_system() + "] Singleplayer game finished")
	get_tree().paused = false
