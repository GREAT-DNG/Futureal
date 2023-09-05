extends Label

var timer: Timer = Timer.new()

func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "hide")

func show_message(message_text: String, show_time: float = 5.0) -> void:
	get_parent().get_node("MessageAudioStreamPlayer").play()
	text = message_text
	show()
	timer.start(show_time)
