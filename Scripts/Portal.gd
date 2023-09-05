extends Area2D

func _on_Portal_body_entered(_body: Node) -> void:
	$AnimatedSprite.play()
	$AudioStreamPlayer.play()

func _on_Portal_body_exited(_body: Node) -> void:
	$AnimatedSprite.stop()
	$AudioStreamPlayer.stop()

func _on_TeleportArea_body_entered(body: Node) -> void:
	if body.is_in_group("Players"):
		body.teleportation()
