extends Area2D

export(float) var softness = 1.5

func _physics_process(_delta: float) -> void:
	for i in get_overlapping_bodies():
		if i.is_in_group("Players"):
			if i.motion.y > 0:
				i.motion.y /= softness
