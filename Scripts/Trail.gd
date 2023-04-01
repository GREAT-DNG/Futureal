extends Line2D

var visibility_timer = Timer.new()
var visibility_timer_wait_time = 0.05
var decrease_at_shot = 0.2

func _ready():
#	gradient = null
	add_child(visibility_timer)
	visibility_timer.connect("timeout", self, "decrease_visibility")
	
func start(var shooter_position, var hit_position):
	add_point(shooter_position)
	add_point(hit_position)
	visibility_timer.start(visibility_timer_wait_time)
	
func decrease_visibility():
	if modulate.a <= 0:
		visibility_timer.stop()
		remove_child(visibility_timer)
		remove_and_skip()
		return
		
	modulate.a = modulate.a - decrease_at_shot
