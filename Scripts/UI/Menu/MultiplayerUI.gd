extends Control

onready var audiostreamplayer = get_parent().get_parent().get_node("AudioStreamPlayer")

func _ready() -> void:
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_on_SceneTree_connected_to_server")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self,"_on_SceneTree_connection_failed")
	
	for i in range(MultiplayerManager.LEVELS.size()):
		$MultiplayerTabContainer/Server/LevelOptionButton.add_item(MultiplayerManager.LEVELS.keys()[i] + " (max players: " + var2str(MultiplayerManager.LEVELS[MultiplayerManager.LEVELS.keys()[i]].max_players) + ")")
	
	if !SettingsManager.get_setting("multiplayer").nickname.empty():
		$MultiplayerTabContainer/Client/NicknameLineEdit.text = SettingsManager.get_setting("multiplayer").nickname
		$MultiplayerTabContainer/Server/NicknameLineEdit.text = SettingsManager.get_setting("multiplayer").nickname
	elif OS.has_environment("USERNAME"):
		$MultiplayerTabContainer/Client/NicknameLineEdit.text = OS.get_environment("USERNAME")
		$MultiplayerTabContainer/Server/NicknameLineEdit.text = OS.get_environment("USERNAME")
	
	if !SettingsManager.get_setting("multiplayer").ip.empty():
		$MultiplayerTabContainer/Client/IPLineEdit.text = SettingsManager.get_setting("multiplayer").ip

func _on_ConnectButton_pressed() -> void:
	audiostreamplayer.play()
	if $MultiplayerTabContainer/Client/NicknameLineEdit.text.empty():
		$MessagePopupDialog.open_dialog("Empty nickname")
		return
	if $MultiplayerTabContainer/Client/IPLineEdit.text.empty():
		$MessagePopupDialog.open_dialog("Empty IP")
		return
	elif !$MultiplayerTabContainer/Client/IPLineEdit.text.is_valid_ip_address():
		$MessagePopupDialog.open_dialog("Incorrect IP")
		return
	
	lock_client_ui()
	if $MultiplayerTabContainer/Client/NicknameLineEdit.text != "Client":
		SettingsManager.save_setting("multiplayer", {"nickname": $MultiplayerTabContainer/Client/NicknameLineEdit.text, "ip": $MultiplayerTabContainer/Client/IPLineEdit.text})
	MultiplayerManager.start_client($MultiplayerTabContainer/Client/IPLineEdit.text, $MultiplayerTabContainer/Client/NicknameLineEdit.text)

func _on_StartButton_pressed() -> void:
	audiostreamplayer.play()
	if $MultiplayerTabContainer/Server/NicknameLineEdit.text.empty():
		$MessagePopupDialog.open_dialog("Empty nickname")
		return
		
	if $MultiplayerTabContainer/Server/NicknameLineEdit.text != "Server":
		SettingsManager.save_setting("multiplayer", {"nickname": $MultiplayerTabContainer/Server/NicknameLineEdit.text, "ip": $MultiplayerTabContainer/Client/IPLineEdit.text})
	MultiplayerManager.start_server(MultiplayerManager.LEVELS.keys()[$MultiplayerTabContainer/Server/LevelOptionButton.selected], $MultiplayerTabContainer/Server/NicknameLineEdit.text)
	
	$"../../LobbyPanel".write("Server started", false, "")
	$"../../LobbyPanel".write("You can run commands, use /help to list commands", false, "")
	
	get_parent().hide()
	$"../../LobbyPanel".show()
	$"../../LobbyPanel/StartButton".disabled = false

func _on_MultiplayerTabContainer_tab_changed(_tab: int) -> void:
	audiostreamplayer.play()
	MultiplayerManager.stop()
	unlock_client_ui()

func _on_SceneTree_connected_to_server() -> void:
	get_parent().hide()
	$"../../LobbyPanel".show()
	$"../../LobbyPanel/StartButton".disabled = true

func _on_SceneTree_connection_failed() -> void:
	unlock_client_ui()
	$MessagePopupDialog.open_dialog("Connection failed")

func lock_client_ui() -> void:
	$MultiplayerTabContainer/Client/ConnectButton.disabled = true
	$MultiplayerTabContainer/Client/IPLineEdit.editable = false
	$MultiplayerTabContainer/Client/NicknameLineEdit.editable = false

func unlock_client_ui() -> void:
	$MultiplayerTabContainer/Client/ConnectButton.disabled = false
	$MultiplayerTabContainer/Client/IPLineEdit.editable = true
	$MultiplayerTabContainer/Client/NicknameLineEdit.editable = true
