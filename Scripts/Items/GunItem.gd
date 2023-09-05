extends Area2D

export(int, "Desert Eagle", "Mac-10", "HK MP5", "AK47", "M4A1", "Benelli M4 Super 90", "M249 SAW") var gun_id
export(bool) var respawning = false
export(float) var respawning_time = 10.0

var respawn_timer: Timer = Timer.new()

func _ready() -> void:
	$Sprite.texture = GunsManager.get_gun_sprite(gun_id)
	$CollisionPolygon2D.polygon = get_node("Guns/Gun" + var2str(gun_id) + "/CollisionPolygon2D").polygon
	$LightOccluder2D.occluder.polygon = get_node("Guns/Gun" + var2str(gun_id) + "/LightOccluder2D").occluder.polygon
	$Guns.queue_free()
	
	add_child(respawn_timer)
	respawn_timer.one_shot = true
	# warning-ignore:return_value_discarded
	respawn_timer.connect("timeout", $AnimationPlayer, "play_backwards", ["Disappearance"])
	# warning-ignore:return_value_discarded
	respawn_timer.connect("timeout", $AudioStreamPlayer2D, "play")

func _on_GunItem_body_entered(body: Node) -> void:
	if body.is_in_group("Players"):
		body.get_node("PickupAudioStreamPlayer2D").stream = load("res://Audios/Player/GunPickup.wav")
		body.get_node("PickupAudioStreamPlayer2D").play()
		
		if !MultiplayerManager.is_multiplayer():
			body.change_gun(gun_id, true)
		elif body.is_network_master():
			body.rpc("change_gun", gun_id, true)
		
		if !MultiplayerManager.is_multiplayer() or body.is_network_master():
			body.get_node("GameUI/MessageLabel").show_message(GunsManager.get_gun(gun_id).name)
		
		if respawning:
			respawn_timer.start(respawning_time)
			$AnimationPlayer.play("Disappearance")
		else:
			$AnimationPlayer.play("Destruction")
