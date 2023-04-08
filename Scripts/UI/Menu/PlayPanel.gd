extends Node

func _on_BackButton_button_down():
	$"../AudioStreamPlayer".play()
	$"../PlayPanel".hide()
	$"../MainPanel".show()
	
func _on_LoadButton_button_down():
	$"../AudioStreamPlayer".play()
	$"../PlayPanel/LoadPanel".show()
	
func _on_Level1Button_button_down():
	$"../AudioStreamPlayer".play()
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level1.tscn"))
	
func _on_Level2Button_button_down():
	$"../AudioStreamPlayer".play()
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level2.tscn"))
	
func _on_Level3Button_button_down():
	$"../AudioStreamPlayer".play()
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level3.tscn"))
