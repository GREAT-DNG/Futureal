extends Area2D

var effect_timer: Timer = Timer.new()

func _on_Pill_body_entered(body: Node) -> void:
	if body.is_in_group("Players"):
		add_child(effect_timer)
		effect_timer.one_shot = true
		# warning-ignore:return_value_discarded
		effect_timer.connect("timeout", self, "stop_effect")
		effect_timer.start(30)
		$AnimationPlayer.play("Disappearance")
		body.get_node("GameUI/MessageLabel").show_message("Pill eaten!")
		Engine.time_scale = 1.5

func stop_effect() -> void:
	Engine.time_scale = 1
	queue_free()
