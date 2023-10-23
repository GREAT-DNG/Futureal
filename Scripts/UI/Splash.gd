extends Control

const START_TIME: float = 0.25
const TYPE_TIME: float = 0.15
const SHOW_TIME: float = 0.5
const text: String = "Futureal"

var process_input: bool = false

func _ready() -> void:
	$CRTColorRect.visible = SettingsManager.get_setting("crt")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$AnimationPlayer.play_backwards("Transition")
	
	yield(get_tree().create_timer(START_TIME), "timeout")
	
	for i in text:
		$FuturealLabel.text += i
		$AudioStreamPlayer.stream = load("res://Audios/Keystrokes/" + var2str(int(rand_range(0, 2))) + ".wav")
		$AudioStreamPlayer.play()
		yield(get_tree().create_timer(TYPE_TIME), "timeout")
	
	yield(get_tree().create_timer(SHOW_TIME), "timeout")
	
	process_input = true
	
	$AnimationPlayer.play("Flashing")

func _input(event: InputEvent) -> void:
	if process_input and (event is InputEventKey or event is InputEventMouseButton):
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(load("res://Scenes/UI/Menu.tscn"))
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
