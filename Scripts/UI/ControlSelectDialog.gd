extends PopupDialog

signal control_selected(InputEvent)

var control: InputEvent
var ui_accept_action_list: Array

func _input(event: InputEvent) -> void:
	if event is InputEventKey and $TabContainer.current_tab == 0:
		if !event.alt and !event.shift and !event.control and !event.meta and !event.command:
			control = event
			$TabContainer/Keyboard/Label.text = event.as_text()
			$OKButton.disabled = false

func _on_TabContainer_tab_changed(_tab: int) -> void:
	$AudioStreamPlayer.play()
	reset()

func _on_OptionButton_item_selected(_index: int) -> void:
	$AudioStreamPlayer.play()
	$OKButton.disabled = false
	control = InputEventMouseButton.new()
	control.button_index = $TabContainer/Mouse/OptionButton.get_selected_id()

func _on_OKButton_pressed() -> void:
	$AudioStreamPlayer.play()
	emit_signal("control_selected", control)
	close_dialog()

func _on_EraseButton_pressed() -> void:
	$AudioStreamPlayer.play()
	emit_signal("control_selected", null)
	close_dialog()

func _on_CancelButton_pressed() -> void:
	$AudioStreamPlayer.play()
	close_dialog()

func open_dialog() -> void:
	ui_accept_action_list = InputMap.get_action_list("ui_accept")
	InputMap.action_erase_events("ui_accept")
	reset()
	popup_centered()

func reset() -> void:
	$TabContainer/Keyboard/Label.text = "Press key"
	$TabContainer/Mouse/OptionButton.selected = -1
	$TabContainer/Mouse/OptionButton.text = "Select mouse button"
	$OKButton.disabled = true
	control = null

func close_dialog() -> void:
	for i in ui_accept_action_list:
		InputMap.action_add_event("ui_accept", i)
	reset()
	hide()
