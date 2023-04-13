extends Area2D

export(PackedScene) var next_level

# warning-ignore:unused_argument
func _on_Portal_body_entered(body):
	$AnimatedSprite.play("Active")
	
# warning-ignore:unused_argument
func _on_Portal_body_exited(body):
	$AnimatedSprite.play("Inactive")
	
func _on_TeleportArea_body_entered(body):
	if body.is_in_group("Player"):
		body.save_game()
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(next_level)
