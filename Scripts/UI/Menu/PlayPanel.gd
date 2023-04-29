extends Node

var game_saver = load("res://Scripts/Utilities/GameSaver.gd").new()

func _ready():
	var last_completed_level = 0
	
	for i in range(15): # Number of levels
		if game_saver.is_level_complete(i):
			last_completed_level = i
	
	if last_completed_level == 3:
		$"TabContainer/Part 2".remove_and_skip()
	
	last_completed_level += 1
	
	# Need refactoring
	for i in range(last_completed_level):
		i += 1
		
		if i <= 3:
			get_node(NodePath("TabContainer/Part 1/Level" + var2str(i) + "Button")).disabled = false
		elif i <= 6:
			get_node(NodePath("TabContainer/Part 2/Level" + var2str(i) + "Button")).disabled = false
		elif i <= 9:
			get_node(NodePath("TabContainer/Part 3/Level" + var2str(i) + "Button")).disabled = false
		elif i <= 12:
			get_node(NodePath("TabContainer/Part 4/Level" + var2str(i) + "Button")).disabled = false
		elif i <= 15:
			get_node(NodePath("TabContainer/Part 5/Level" + var2str(i) + "Button")).disabled = false
		
		if i <= 12 and $TabContainer.has_node("Part 5"):
			var tab_buttons = $"TabContainer/Part 5".get_children()
			for j in range(tab_buttons.size()):
				$"TabContainer/Part 5".remove_child(tab_buttons[j])
			$"TabContainer/Part 5".remove_and_skip()
		if i <= 9 and $TabContainer.has_node("Part 4"):
			var tab_buttons = $"TabContainer/Part 4".get_children()
			for j in range(tab_buttons.size()):
				$"TabContainer/Part 4".remove_child(tab_buttons[j])
			$"TabContainer/Part 4".remove_and_skip()
		if i <= 6 and $TabContainer.has_node("Part 3"):
			var tab_buttons = $"TabContainer/Part 3".get_children()
			for j in range(tab_buttons.size()):
				$"TabContainer/Part 3".remove_child(tab_buttons[j])
			$"TabContainer/Part 3".remove_and_skip()
		if i <= 3 and $TabContainer.has_node("Part 2"):
			var tab_buttons = $"TabContainer/Part 2".get_children()
			for j in range(tab_buttons.size()):
				$"TabContainer/Part 2".remove_child(tab_buttons[j])
			$"TabContainer/Part 2".remove_and_skip()
			
		i -= 1
		
func _on_BackButton_button_down():
	$"../AudioStreamPlayer".play()
	$"../PlayPanel".hide()
	$"../MainPanel".show()
	
func _on_LoadButton_button_down():
	$"../AudioStreamPlayer".play()
	ProjectSettings.set("display/mouse_cursor/custom_image", "")
	$LoadLevelFileDialog.popup()
	
func _on_Level1Button_button_down():
	$"../AudioStreamPlayer".play()
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level1.tscn"))
	
func _on_Level2Button_button_down():
	$"../AudioStreamPlayer".play()
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level2.tscn"))
	
func _on_Level3Button_button_down():
	$"../AudioStreamPlayer".play()
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Levels/Level3.tscn"))
