extends Node

var is_used = false

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		if !is_used:
			$"../Player/UI/MessageLabel".show_message("Secret found!", 3)
		
		is_used = true
		$HideSprite.hide()
	
func _on_Area2D_body_exited(body):
	if body.name == "Player":
		$HideSprite.show()
