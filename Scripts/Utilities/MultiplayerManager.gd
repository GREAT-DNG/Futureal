extends Node

signal player_registred(nickname)
signal player_unregistred(nickname)

signal game_started()
signal game_info_updated()

const LEVEL1: Dictionary = {
	"max_players": 2,
	"spawn_positions": [Vector2(500, 0), Vector2(-500, 0)],
	"used_spawn_positions": [],
	}

const LEVEL2: Dictionary = {
	"max_players": 4,
	"spawn_positions": [Vector2(-850, 100), Vector2(-850, 300), Vector2(850, 100), Vector2(850, 300)],
	"used_spawn_positions": [],
	}

const LEVELS: Dictionary = {
	"Level1": LEVEL1,
	"Level2": LEVEL2,
	}

const PORT: int = 49094

var level: String
var server_difficulty = 0
var nickname: String = ""
var kills: int = 0
var deaths: int = 0
var players: Dictionary = {}
var spawn_positions: Dictionary = {}

func _ready() -> void:
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_on_SceneTree_network_peer_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self,"_on_SceneTree_network_peer_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_on_SceneTree_connected_to_server")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_on_SceneTree_server_disconnected")

func _on_SceneTree_network_peer_connected(id: int) -> void:
	rpc_id(id, "register_player", nickname)
	if get_tree().is_network_server():
		rpc_id(id, "set_difficulty", SettingsManager.get_setting("difficulty"))

func _on_SceneTree_network_peer_disconnected(id: int) -> void:
	if !players.has(id):
		return
	
	emit_signal("player_unregistred", players[id].nickname)
	if get_tree().get_root().find_node("Level*", false, false) != null:
		get_tree().get_root().find_node("Level*", false, false).get_node("Players").get_node(var2str(id)).queue_free()
	# warning-ignore:return_value_discarded
	players.erase(id)

func _on_SceneTree_connected_to_server() -> void:
	rpc_id(1, "check_game_version", SettingsManager.GAME_VERSION)

func _on_SceneTree_server_disconnected() -> void:
	if get_tree().get_root().find_node("Level*", false, false) != null:
		get_tree().get_root().find_node("Level*", false, false).queue_free()
		get_tree().get_root().get_node("Menu").show()

remote func check_game_version(game_version: String) -> void:
	if game_version != SettingsManager.GAME_VERSION:
		get_tree().network_peer.disconnect_peer(get_tree().get_rpc_sender_id())

remote func set_difficulty(difficulty: int):
	server_difficulty = difficulty

remote func register_player(new_player_nickname: String) -> void:
	players[get_tree().get_rpc_sender_id()] = {
		"nickname": new_player_nickname,
		"ready": false,
		"kills": 0,
		"deaths": 0,
		}
	
	if get_tree().get_rpc_sender_id() != 1:
		emit_signal("player_registred", players[get_tree().get_rpc_sender_id()].nickname)

func is_multiplayer() -> bool:
	return get_tree().has_network_peer() and get_tree().get_network_peer().get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED

func start_server(new_level: String, new_nickname: String) -> void:
	server_difficulty = SettingsManager.get_setting("difficulty")
	nickname = new_nickname
	level = new_level
	var peer: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	# warning-ignore:return_value_discarded
	peer.create_server(PORT, LEVELS[level].max_players)
	get_tree().set_network_peer(peer)
	
	print("[" + Time.get_time_string_from_system() + "] Server started")

func start_client(ip: String, new_nickname: String) -> void:
	nickname = new_nickname
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, PORT)
	get_tree().set_network_peer(peer)
	
	print("[" + Time.get_time_string_from_system() + "] Client started")

func stop() -> void:
	nickname = ""
	players.clear()
	spawn_positions.clear()
	if get_tree().network_peer != null:
		get_tree().set_network_peer(null)
		print("[" + Time.get_time_string_from_system() + "] Client/Server finished")

func start_game() -> void:
	var level_spawn_positions: Array = LEVELS[level].spawn_positions.duplicate()
	var spawn_position_number: int = int(rand_range(0, level_spawn_positions.size() - 1))
	spawn_positions[1] = level_spawn_positions[spawn_position_number]
	level_spawn_positions.remove(spawn_position_number)
	
	for i in players:
		spawn_position_number = int(rand_range(0, level_spawn_positions.size() - 1))
		spawn_positions[i] = level_spawn_positions[spawn_position_number]
		level_spawn_positions.remove(spawn_position_number)
	
	rpc("prepare_game", level, spawn_positions)

remotesync func prepare_game(level_name: String, new_spawn_positions: Dictionary) -> void:
	get_tree().refuse_new_network_connections = true
	
	spawn_positions = new_spawn_positions
	get_tree().paused = true
	var level_instance: Node = load("res://Scenes/Levels/Multiplayer/" + level_name + ".tscn").instance()
	get_tree().get_root().add_child(level_instance)
	
	for i in spawn_positions:
		var player: Node = load("res://Scenes/Player.tscn").instance()
		player.position = spawn_positions[i]
		player.set_network_master(i)
		player.set_name(var2str(i))
		if i != get_tree().get_network_unique_id():
			player.get_node("MultiplayerStats").set_nickname(players[i].nickname)
			player.get_node("GameUI").queue_free()
			player.get_node("CanvasModulate").free()
			player.get_node("Camera2D").free()
		level_instance.get_node("Players").add_child(player)
	
	if !get_tree().is_network_server():
		rpc_id(1, "prepare_game_done")
	elif players.size() == 0:
		run_game()

remote func prepare_game_done() -> void:
	players[get_tree().get_rpc_sender_id()].ready = true
	
	for i in players:
		if !players[i].ready:
			return
	
	rpc("run_game")

remotesync func run_game() -> void:
	emit_signal("game_started")
	get_tree().get_root().get_node("Menu").hide()
	get_tree().get_root().get_node("Menu/BackgroundAudioStreamPlayer").stop()
	get_tree().paused = false
	
	print("[" + Time.get_time_string_from_system() + "] Multiplayer game started")

remotesync func killed(killer_id: int) -> void:
	if killer_id == get_tree().get_network_unique_id():
		kills += 1
	else:
		if players.has(killer_id):
			players[killer_id].kills += 1
	emit_signal("game_info_updated")
	
	# Refactoring
	if players.has(killer_id):
		if get_tree().get_rpc_sender_id() == get_tree().get_network_unique_id():
			get_tree().get_root().find_node("*Level*", false, false).get_node("Players/" + var2str(get_tree().get_network_unique_id()) + "/GameUI/MessageLabel").show_message(players[killer_id].nickname + " kill " + nickname)
		elif killer_id == get_tree().get_network_unique_id():
			get_tree().get_root().find_node("*Level*", false, false).get_node("Players/" + var2str(get_tree().get_network_unique_id()) + "/GameUI/MessageLabel").show_message(nickname + " kill " + players[get_tree().get_rpc_sender_id()].nickname)
		else:
			get_tree().get_root().find_node("*Level*", false, false).get_node("Players/" + var2str(get_tree().get_network_unique_id()) + "/GameUI/MessageLabel").show_message(players[killer_id].nickname + " kill " + players[get_tree().get_rpc_sender_id()].nickname)

remotesync func dead() -> void:
	if get_tree().get_rpc_sender_id() == get_tree().get_network_unique_id():
		deaths += 1
	else:
		players[get_tree().get_rpc_sender_id()].deaths += 1
	emit_signal("game_info_updated")

remotesync func end_game() -> void:
	get_tree().refuse_new_network_connections = false
	stop()
	get_tree().get_root().get_node("Menu/LobbyPanel").hide()
	get_tree().get_root().get_node("Menu/PlayPanel/MultiplayerUI").unlock_client_ui()
	get_tree().get_root().get_node("Menu/LobbyPanel/OutputRichTextLabel").text = ""
	get_tree().get_root().get_node("Menu/PlayPanel").show()
	get_tree().get_root().get_node("Menu").show()
	get_tree().get_root().get_node("Menu/BackgroundAudioStreamPlayer").play()
	get_tree().get_root().find_node("*Level*", false, false).queue_free()
	for i in players:
		players[i].ready = false
		
	print("[" + Time.get_time_string_from_system() + "] Multiplayer game finished")
