extends Node

var is_used = false

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		if !is_used:
			$"../Player/UI/MessageLabel".show_message("Secret found!")
		
		is_used = true
		$HideSprite.hide()
	
func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		$HideSprite.show()
