extends Panel

onready var audiostreamplayer = get_parent().get_node("AudioStreamPlayer")

func _on_BackButton_pressed() -> void:
	audiostreamplayer.play()
	hide()
	get_parent().get_node("MainPanel").show()
	MultiplayerManager.stop()
	$MultiplayerUI.unlock_client_ui()

func _on_PlayModeOptionButton_item_selected(index: int) -> void:
	audiostreamplayer.play()
	if index == 0:
		$MultiplayerUI.hide()
		$SingleplayerUI.show()
		MultiplayerManager.stop()
	elif index == 1:
		$SingleplayerUI.hide()
		$MultiplayerUI.show()

func _on_PlayModeButton_pressed() -> void:
	audiostreamplayer.play()
	if $PlayModeButton.text == "Singleplayer":
		$PlayModeButton.text = "Multiplayer"
		$SingleplayerUI.hide()
		$MultiplayerUI.show()
	elif $PlayModeButton.text == "Multiplayer":
		$PlayModeButton.text = "Singleplayer"
		$MultiplayerUI.hide()
		$SingleplayerUI.show()
