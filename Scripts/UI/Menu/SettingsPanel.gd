extends Panel

const CONTROLS: Dictionary = {
	"up": "Up",
	"down": "Down",
	"left": "Left",
	"right": "Right",
	"run": "Run",
	"shot": "Shot",
	"next_gun": "Next Gun",
	"previous_gun": "Previous Gun",
	"reload": "Reload",
	"pause": "Pause",
	"game_info": "Game Info",
	}

var action_name: String
var control_index: int

onready var audiostreamplayer: Node = get_parent().get_node("AudioStreamPlayer")

func _ready() -> void:
	$TabContainer/Gameplay/AutoreloadCheckButton.pressed = SettingsManager.get_setting("autoreload")
	$TabContainer/Gameplay/AutochangeCheckButton.pressed = SettingsManager.get_setting("autochange")
	$TabContainer/Gameplay/Difficulty/OptionButton.selected = SettingsManager.get_setting("difficulty")
	
	$TabContainer/System/ScrollContainer/Control/FullscreenCheckButton.pressed = SettingsManager.get_setting("fullscreen")
	$TabContainer/System/ScrollContainer/Control/MuteCheckButton.pressed = SettingsManager.get_setting("mute")
	$TabContainer/System/ScrollContainer/Control/ActionsCheckButton.pressed = SettingsManager.get_setting("actions")
	$TabContainer/System/ScrollContainer/Control/TrailsCheckButton.pressed = SettingsManager.get_setting("trails")
	$TabContainer/System/ScrollContainer/Control/CRTCheckButton.pressed = SettingsManager.get_setting("crt")
	$TabContainer/System/ScrollContainer/Control/ExactnessCheckButton.pressed = SettingsManager.get_setting("exactness")
	$TabContainer/System/ScrollContainer/Control/CustomCursorCheckButton.pressed = SettingsManager.get_setting("cursor")
	
	# warning-ignore:return_value_discarded
	$ControlSelectPopupDialog.connect("control_selected", self, "change_control")
	update_controls()

func _on_BackButton_pressed() -> void:
	audiostreamplayer.play()
	hide()
	get_parent().get_node("MainPanel").show()

func _on_TabContainer_tab_changed(_tab: int) -> void:
	audiostreamplayer.play()

func _on_AutochangeCheckButton_pressed() -> void:
	audiostreamplayer.play()
	SettingsManager.save_setting("autochange", $TabContainer/Gameplay/AutochangeCheckButton.pressed)

func _on_AutoreloadCheckButton_pressed() -> void:
	audiostreamplayer.play()
	SettingsManager.save_setting("autoreload", $TabContainer/Gameplay/AutoreloadCheckButton.pressed)

func _on_OptionButton_item_selected(index: int) -> void:
	audiostreamplayer.play()
	SettingsManager.save_setting("difficulty", index)

func _on_FullscreenCheckButton_pressed() -> void:
	audiostreamplayer.play()
	OS.window_fullscreen = $TabContainer/System/ScrollContainer/Control/FullscreenCheckButton.pressed
	if !$TabContainer/System/ScrollContainer/Control/FullscreenCheckButton.pressed:
		OS.window_position = (OS.get_screen_size() - Vector2(800, 600)) / 2
		OS.window_size = Vector2(800, 600)
	SettingsManager.save_setting("fullscreen", $TabContainer/System/ScrollContainer/Control/FullscreenCheckButton.pressed)

func _on_MuteCheckButton_pressed() -> void:
	audiostreamplayer.play()
	AudioServer.set_bus_mute(0, $TabContainer/System/ScrollContainer/Control/MuteCheckButton.pressed)
	SettingsManager.save_setting("mute", $TabContainer/System/ScrollContainer/Control/MuteCheckButton.pressed)

func _on_ActionsCheckButton_pressed() -> void:
	audiostreamplayer.play()
	SettingsManager.save_setting("actions", $TabContainer/System/ScrollContainer/Control/ActionsCheckButton.pressed)

func _on_TrailsCheckButton_pressed() -> void:
	audiostreamplayer.play()
	SettingsManager.save_setting("trails", $TabContainer/System/ScrollContainer/Control/TrailsCheckButton.pressed)

func _on_CRTCheckButton_pressed() -> void:
	audiostreamplayer.play()
	SettingsManager.save_setting("crt", $TabContainer/System/ScrollContainer/Control/CRTCheckButton.pressed)

func _on_ExactnessCheckButton_pressed() -> void:
	audiostreamplayer.play()
	SettingsManager.save_setting("exactness", $TabContainer/System/ScrollContainer/Control/ExactnessCheckButton.pressed)

func _on_CustomCursorCheckButton_pressed() -> void:
	audiostreamplayer.play()
	SettingsManager.save_setting("cursor", $TabContainer/System/ScrollContainer/Control/CustomCursorCheckButton.pressed)
	if $TabContainer/System/ScrollContainer/Control/CustomCursorCheckButton.pressed:
		Input.set_custom_mouse_cursor(load("res://Sprites/UI/Cursor.png"))
	else:
		Input.set_custom_mouse_cursor(null)

func _on_LinkButton_pressed() -> void:
	# warning-ignore:return_value_discarded
	OS.shell_open("https://great-dng.github.io/futureal-website/")
	print("[" + Time.get_time_string_from_system() + "] Website opened")

func update_controls() -> void:
	for i in CONTROLS:
		for j in range(1, 4):
			get_node("TabContainer/Controls/ScrollContainer/Control/" + CONTROLS[i].replace(" ", "") + "Control/Button" + var2str(j)).text = ""
		
		for j in InputMap.get_action_list(i).size():
			var control
			if InputMap.get_action_list(i)[j] is InputEventKey:
				control = InputMap.get_action_list(i)[j].as_text()
			elif InputMap.get_action_list(i)[j] is InputEventMouseButton:
				if InputMap.get_action_list(i)[j].button_index == BUTTON_LEFT:
					control = "LMB"
				elif InputMap.get_action_list(i)[j].button_index == BUTTON_RIGHT:
					control = "RMB"
				elif InputMap.get_action_list(i)[j].button_index == BUTTON_MIDDLE:
					control = "MMB"
				elif InputMap.get_action_list(i)[j].button_index == BUTTON_WHEEL_UP:
					control = "MWU"
				elif InputMap.get_action_list(i)[j].button_index == BUTTON_WHEEL_DOWN:
					control = "MWD"
			
			get_node("TabContainer/Controls/ScrollContainer/Control/" + CONTROLS[i].replace(" ", "") + "Control/Button" + var2str(j + 1)).text = control

func select_control(new_action_name: String, new_control_index: int) -> void:
	audiostreamplayer.play()
	action_name = new_action_name
	control_index = new_control_index
	$ControlSelectPopupDialog.open_dialog()

func change_control(new_control: InputEvent) -> void:
	if new_control == null and InputMap.get_action_list(action_name).size() >= control_index:
		InputMap.action_erase_event(action_name, InputMap.get_action_list(action_name)[control_index - 1])
	elif new_control != null:
		if InputMap.get_action_list(action_name).size() < control_index:
			InputMap.action_add_event(action_name, new_control)
		else:
			var control_list = InputMap.get_action_list(action_name)
			InputMap.action_erase_events(action_name)
			for i in control_list.size():
				if i == control_index - 1:
					control_list[i] = new_control
				InputMap.action_add_event(action_name, control_list[i])
	
	update_controls()
	SettingsManager.save_controls()
