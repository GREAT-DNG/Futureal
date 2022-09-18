extends Area2D

export(int) var hill_power = 5

func _on_Medchest_body_entered(body):
	if body.name == "Player":
		remove_child($Sprite)
		remove_child($CollisionPolygon2D)
		remove_child($LightOccluder2D)
		$"../../Player".hill(hill_power)
	
func _on_MedChest_mouse_entered():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor_G.png"))
	
func _on_MedChest_mouse_exited():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor.png"))
