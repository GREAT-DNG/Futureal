extends Sprite

var modulate_timer_wait_time = 0.1
var decrease_at_shot = 0.03

var modulate_timer = Timer.new()

func _ready():
	add_child(modulate_timer)
	modulate_timer.connect("timeout", self, "decrease_modulation")
	
func show_hit():
	modulate = Color(1, 0, 0, 0.3)
	modulate_timer.start(modulate_timer_wait_time)
	
func show_heal():
	modulate = Color(0, 1, 0, 0.3)
	modulate_timer.start(modulate_timer_wait_time)
	
func decrease_modulation():
	if (modulate.a <= 0):
		modulate_timer.stop()
		return
		
	modulate = Color(modulate.r, modulate.g, modulate.b, modulate.a - decrease_at_shot)
