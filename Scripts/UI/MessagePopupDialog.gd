extends PopupDialog

func open_dialog(text: String) -> void:
	$Label.text = text
	popup_centered()

func _on_OKButton_pressed() -> void:
	$"../../../AudioStreamPlayer".play()
	hide()
