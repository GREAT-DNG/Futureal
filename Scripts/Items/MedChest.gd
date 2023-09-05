extends Area2D

export(float) var heal_power = 5.0
export(bool) var respawning = false
export(float) var respawning_time = 10.0

var respawn_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(respawn_timer)
	respawn_timer.one_shot = true
	# warning-ignore:return_value_discarded
	respawn_timer.connect("timeout", $AnimationPlayer, "play_backwards", ["Disappearance"])
	# warning-ignore:return_value_discarded
	respawn_timer.connect("timeout", $AudioStreamPlayer2D, "play")

func _on_MedChest_body_entered(body: Node) -> void:
	if body.is_in_group("Players"):
		body.get_node("PickupAudioStreamPlayer2D").stream = load("res://Audios/Player/ItemPickup.wav")
		body.get_node("PickupAudioStreamPlayer2D").play()
		
		if !MultiplayerManager.is_multiplayer():
			body.heal(heal_power)
		elif body.is_network_master():
			body.rpc("heal", heal_power)
		
		if !MultiplayerManager.is_multiplayer() or body.is_network_master():
			body.get_node("GameUI/MessageLabel").show_message("Healed at " + var2str(heal_power))
		
		if respawning:
			respawn_timer.start(respawning_time)
			$AnimationPlayer.play("Disappearance")
		else:
			$AnimationPlayer.play("Destruction")
