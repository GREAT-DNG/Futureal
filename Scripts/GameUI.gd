extends CanvasLayer

func game_complete():
	$Panel.hide()
	$Final/Sprite.show()
	$Final/Label.show()
	
func player_killed():
	$Panel.hide()
	$GameOverPanel.show()
	
func pause():
	$Panel.hide()
	$PausePanel.show()
	get_tree().paused = true
	
func refresh_panel(var health, var money, var gun):
	$Panel/HealthLabel.text = var2str(health)
	$Panel/MoneyLabel.text = var2str(money)
	$Panel/GunLabel.text = gun.name + " " + var2str(gun.bullets) + "/" + var2str(gun.loaded_bullets)
	
func _on_ContinueButton_button_down():
	$PausePanel.hide()
	$Panel.show()
	get_tree().paused = false

func _on_RestartButton_button_down():
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
	get_tree().paused = false

func _on_MenuButton_button_down():
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Menu.tscn"))
	get_tree().paused = false
