extends Area2D
var guns_manager = load("res://Scripts/Utilities/GunsManager.gd").new()

export(int, 0, 6) var gun_id
var gun

func _ready():
	gun = guns_manager.get_gun(gun_id)
	get_child(0).texture = load("res://Sprites/Guns/Gun" + var2str(gun_id) + ".png")
	get_node(NodePath("Gun" + var2str(gun_id) + "CollisionPolygon2D")).disabled = false
	get_node(NodePath("Gun" + var2str(gun_id) + "LightOccluder2D")).show()

func _on_Gun_body_entered(body):
	if body.is_in_group("Player"):
		remove_child(get_node(NodePath("Gun" + var2str(gun_id) + "CollisionPolygon2D")))
		remove_child($Sprite)
		remove_child(get_node(NodePath("Gun" + var2str(gun_id) + "LightOccluder2D")))
		$"../../Player/PickupAudioStreamPlayer2D".stream = load("res://Audios/Player/GunPickup.wav")
		$"../../Player/PickupAudioStreamPlayer2D".play()
		$"../../Player".change_gun(gun_id, true)
		$"../../Player/UI/MessageLabel".show_message(gun.name)
	
func _on_Gun_mouse_entered():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor_G.png"))
	
func _on_Gun_mouse_exited():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor.png"))
