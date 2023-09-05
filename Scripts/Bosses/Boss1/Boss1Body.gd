extends KinematicBody2D

func hit(power: float) -> void:
	get_parent().hit(power)
