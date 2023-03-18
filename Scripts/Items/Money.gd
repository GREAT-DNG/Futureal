extends Area2D

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		remove_child($Sprite)
		remove_child($CollisionPolygon2D)
		remove_child($LightOccluder2D)
		body.call("add_money", 1)
		# $"../../Player/UI/MessageLabel".show_message("1 coin found")
