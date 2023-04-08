extends CanvasLayer

func game_complete():
	$Stats.hide()
	$Final.show()
	
func player_killed():
	$Stats.hide()
	$GameOverPanel.show()
	
func pause():
	$Stats.hide()
	$PausePanel.show()
	get_tree().paused = true
	
func refresh_panel(var health, var money, var gun):
	$Stats/HealthLabel.text = var2str(health)
	$Stats/MoneyLabel.text = var2str(money)
	$Stats/GunLabel.text = gun.name + "\n" + var2str(gun.loaded_bullets) + "/" + var2str(gun.bullets)
	
func _on_ContinueButton_button_down():
	$AudioStreamPlayer.play()
	$PausePanel.hide()
	$Stats.show()
	get_tree().paused = false
	
func _on_RestartButton_button_down():
	$AudioStreamPlayer.play()
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
	get_tree().paused = false
	
func _on_MenuButton_button_down():
	$AudioStreamPlayer.play()
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Menu.tscn"))
	get_tree().paused = false
