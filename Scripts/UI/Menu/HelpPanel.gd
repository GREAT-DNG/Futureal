extends Node

func _on_HelpOKButton_button_down():
	$AudioStreamPlayer.play()
	$HelpPanel.hide()
