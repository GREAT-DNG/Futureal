extends Panel

onready var audiostreamplayer = get_parent().get_node("AudioStreamPlayer")

func _ready() -> void:
	# warning-ignore:return_value_discarded
	MultiplayerManager.connect("player_registred", self, "_register_player")
	# warning-ignore:return_value_discarded
	MultiplayerManager.connect("player_unregistred", self, "_unregister_player")
	# warning-ignore:return_value_discarded
	MultiplayerManager.connect("game_started", self, "_game_started")
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_on_SceneTree_connected_to_server")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_on_SceneTree_server_disconnected")

remotesync func write(text: String, send: bool = true, nickname: String = MultiplayerManager.nickname) -> void:
	if text.empty():
		return
	
	if !nickname.empty():
		nickname += " "
	
	if send:
		rpc("write", text, false, MultiplayerManager.nickname)
	else:
		$OutputRichTextLabel.text += nickname + "(" + Time.get_time_string_from_system() + ") " + text + "\n"

func run_command(text: String) -> void:
	if text == "/list_players":
		if !MultiplayerManager.players.empty():
			write("Players list (nickname : ID):", false, "")
			for i in MultiplayerManager.players:
				write(MultiplayerManager.players[i].nickname + " : " + var2str(i), false, "")
		else:
			write("Players list empty", false, "")
	elif text.match("/get_ip *"):
		text.erase(0, 8)
		if MultiplayerManager.players.has(int(text)):
			write("Player " + MultiplayerManager.players[int(text)].nickname + " IP: " + get_tree().network_peer.get_peer_address(int(text)), false, "")
		else:
			write("Player ID not found", false, "")
	elif text == "/get_ip":
		write("Usage: /get_ip ID", false, "")
	elif text.match("/kick *"):
		text.erase(0, 6)
		if MultiplayerManager.players.has(int(text)):
			get_tree().network_peer.disconnect_peer(int(text))
		else:
			write("Player ID not found", false, "")
	elif text == "/kick":
		write("Usage: /kick ID", false, "")
	elif text == "/help":
		write("Commands list:", false, "")
		write("/list_players", false, "")
		write("/get_ip ID", false, "")
		write("/kick ID", false, "")
		write("/help", false, "")
	else:
		write("Unknown command, use /help to list commands", false, "")

func _on_StartButton_pressed() -> void:
	audiostreamplayer.play()
	MultiplayerManager.start_game()

func _on_BackButton_pressed() -> void:
	audiostreamplayer.play()
	hide()
	get_parent().get_node("PlayPanel").show()
	MultiplayerManager.stop()
	$"../PlayPanel/MultiplayerUI".unlock_client_ui()
	$OutputRichTextLabel.text = ""

func _on_MessageLineEdit_text_entered(new_text: String) -> void:
	audiostreamplayer.play()
	if new_text.begins_with("/") and get_tree().is_network_server():
		run_command(new_text)
	else:
		write(new_text)
	$MessageLineEdit.text = ""

func _on_SendButton_pressed() -> void:
	audiostreamplayer.play()
	if $MessageLineEdit.text.begins_with("/") and get_tree().is_network_server():
		run_command($MessageLineEdit.text)
	else:
		write($MessageLineEdit.text)
	$MessageLineEdit.text = ""

func _register_player(nickname: String) -> void:
	write("Player " + nickname + " connected", false, "")

func _unregister_player(nickname: String) -> void:
	write("Player " + nickname + " disconnected", false, "")

func _game_started() -> void:
	write("Game started", false, "")

func _on_SceneTree_connected_to_server() -> void:
	write("Connected to server", false, "")

func _on_SceneTree_server_disconnected() -> void:
	audiostreamplayer.play()
	$"../PlayPanel/MultiplayerUI/MessagePopupDialog".open_dialog("Server disconnected")
	MultiplayerManager.stop()
	$"../PlayPanel/MultiplayerUI".unlock_client_ui()
	$OutputRichTextLabel.text = ""
	hide()
	get_parent().get_node("PlayPanel").show()
