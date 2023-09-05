extends Line2D

const VISIBILITY_TIMER_WAIT_TIME: float = 0.05
const DECREASE_AT_SHOT: float = 0.1

var visibility_timer: Timer = Timer.new()

func start(shooter_position: Vector2, hit_position: Vector2) -> void:
	add_child(visibility_timer)
	# warning-ignore:return_value_discarded
	visibility_timer.connect("timeout", self, "decrease_visibility")
	add_point(shooter_position)
	add_point(hit_position)
	visibility_timer.start(VISIBILITY_TIMER_WAIT_TIME)

func decrease_visibility() -> void:
	if modulate.a <= 0:
		visibility_timer.stop()
		queue_free()
		return
	
	modulate.a -= DECREASE_AT_SHOT
