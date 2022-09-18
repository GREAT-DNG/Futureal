extends Area2D

export(int, 0, 6) var gun_id

func _ready():
	get_child(0).texture = load("res://Sprites/Guns/Gun" + var2str(gun_id) + ".png")
	get_node(NodePath("Gun" + var2str(gun_id) + "CollisionPolygon2D")).disabled = false
	get_node(NodePath("Gun" + var2str(gun_id) + "LightOccluder2D")).show()

func _on_Gun_body_entered(body):
	if body.name == "Player":
		remove_child(get_node(NodePath("Gun" + var2str(gun_id) + "CollisionPolygon2D")))
		remove_child($Sprite)
		remove_child(get_node(NodePath("Gun" + var2str(gun_id) + "LightOccluder2D")))
		$"../../Player".change_gun(gun_id, true)
	
func _on_Gun_mouse_entered():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor_G.png"))
	
func _on_Gun_mouse_exited():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor.png"))
