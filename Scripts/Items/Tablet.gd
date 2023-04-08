extends Area2D

var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "stop")
	
func _on_Tablet_body_entered(body):
	if body.name == "Player":
		timer.start(15)
		remove_child($Sprite)
		remove_child($CollisionPolygon2D)
		remove_child($LightOccluder2D)
		$"../Player/UI/MessageLabel".show_message("Adrenaline pill eaten!")
		Engine.time_scale = 1.5

func stop():
	Engine.time_scale = 1
