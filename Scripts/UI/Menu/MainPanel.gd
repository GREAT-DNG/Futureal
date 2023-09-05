extends Panel

onready var audiostreamplayer = get_parent().get_node("AudioStreamPlayer")
onready var animationplayer = get_parent().get_node("AnimationPlayer")

func _ready() -> void:
	$VersionLabel.text = "v" + SettingsManager.GAME_VERSION
	$EditorLabel.visible = OS.has_feature("editor")
	$DebugLabel.visible = OS.is_debug_build()
	animationplayer.play_backwards("Transition")

func _on_FuturealLabel_mouse_entered() -> void:
	get_parent().get_node("AnimationPlayer").play("LogoBG")

func _on_FuturealLabel_mouse_exited() -> void:
	get_parent().get_node("AnimationPlayer").play_backwards("LogoBG")

func _on_PlayButton_pressed() -> void:
	audiostreamplayer.play()
	hide()
	get_parent().get_node("PlayPanel").show()

func _on_SettingsButton_pressed() -> void:
	audiostreamplayer.play()
	hide()
	get_parent().get_node("SettingsPanel").show()

func _on_QuitButton_pressed() -> void:
	audiostreamplayer.play()
	animationplayer.play("Transition")
	yield(get_parent().get_node("AnimationPlayer"), "animation_finished")
	print("[" + Time.get_time_string_from_system() + "] Futureal v" + SettingsManager.GAME_VERSION + " finished")
	get_tree().quit(0)
