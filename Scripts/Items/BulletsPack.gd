extends Area2D

export(int) var clips = 1

func _on_BulletsPack_body_entered(body):
	if body.name == "Player":
		var plural = ""
		
		remove_child($Sprite)
		remove_child($CollisionPolygon2D)
		remove_child($LightOccluder2D)
		$"../../Player/PickupAudioStreamPlayer2D".stream = load("res://Audios/Player/ItemPickup.wav")
		$"../../Player/PickupAudioStreamPlayer2D".play()
		$"../../Player".give_bullets(clips)
		if clips > 1:
			plural = "s"
		$"../../Player/UI/MessageLabel".show_message("Found " + var2str(clips) + " clip" + plural)
	
func _on_BulletsPack_mouse_entered():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor_G.png"))
	
func _on_BulletsPack_mouse_exited():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor.png"))
