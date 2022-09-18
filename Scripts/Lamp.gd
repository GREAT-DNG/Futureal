extends Node2D

export(int, 0, 1) var lamp_type
export(int) var light_scale = 1

func _ready():
	$Sprite.texture = load("res://Sprites/Lamps/Lamp" + var2str(lamp_type) + ".png")
	$Light2D.texture = load("res://Sprites/Light/Light" + var2str(lamp_type) + ".png")
	
	$Light2D.texture_scale = light_scale
	
	if lamp_type == 1:
		$Light2D.offset.y = 150
