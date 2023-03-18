extends Label

var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "hide_message")
	
func show_message(var message_text, var show_time = 5):
	$"../MessageAudioStreamPlayer".play()
	text = message_text
	show()
	timer.start(show_time)

func hide_message():
	hide()
