extends ColorRect

const VISIBILITY_TIMER_WAIT_TIME: float = 0.1
const DECREASE_AT_SHOT: float = 0.03

var visibility_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(visibility_timer)
	# warning-ignore:return_value_discarded
	visibility_timer.connect("timeout", self, "decrease_modulation")

func show_hit() -> void:
	color = Color(1, 0, 0, 0.3)
	visibility_timer.start(VISIBILITY_TIMER_WAIT_TIME)

func show_heal() -> void:
	color = Color(0, 1, 0, 0.3)
	visibility_timer.start(VISIBILITY_TIMER_WAIT_TIME)

func decrease_modulation() -> void:
	if (color.a <= 0):
		visibility_timer.stop()
		return
	
	color.a = color.a - DECREASE_AT_SHOT
