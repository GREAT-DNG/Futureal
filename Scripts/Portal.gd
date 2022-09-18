extends Area2D

var timer = Timer.new()
var is_player_entered = false

export(PackedScene) var next_level

func _ready():
	add_child(timer)
	timer.start(0.3)
	timer.connect("timeout", self, "change_texture")
	
func change_texture():
	if is_player_entered:
		if get_child(0).texture == load("res://Sprites/Portal/Portal_0.png"):
			get_child(0).texture = load("res://Sprites/Portal/Portal_1.png")
		elif get_child(0).texture == load("res://Sprites/Portal/Portal_1.png"):
			get_child(0).texture = load("res://Sprites/Portal/Portal_0.png")
	
func _on_Portal_body_entered(body):
	if(body.name == "Player"):
		is_player_entered = true
	
func _on_Portal_body_exited(body):
	if(body.name == "Player"):
		is_player_entered = false
	
	get_child(0).texture = load("res://Sprites/Portal/Portal_0.png")
	
func _on_TeleportArea_body_entered(body):
	if body.name == "Player":
		body.save_game()
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(next_level)
