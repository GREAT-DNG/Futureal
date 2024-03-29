extends KinematicBody2D

export(int) var current_level_number

var guns_manager = load("res://Scripts/Utilities/GunsManager.gd").new()
var game_saver = load("res://Scripts/Utilities/GameSaver.gd").new()
var settings_saver = load("res://Scripts/Utilities/SettingsSaver.gd").new()

var motion = Vector2()
var up = Vector2(0, -1)
var speed = 160
var gravitation = 10
var max_gravitation = 250
var jump = 500

var autoreload = false
var active_gun_number = 0
var guns_collection = [guns_manager.get_gun(0)]
var show_actions = false
var show_trails = false

var shot_timer = Timer.new()
var reload_timer = Timer.new()
var final_timer = Timer.new()

var money = 0
var health = 10.0
var max_health = 25.0

var is_dead = false # or complete game

var is_nohit = false

func _ready():
	if current_level_number == 0:
		push_error("\"Player\": Incorrect current_level_number")
	
	if settings_saver.check_settings():
		autoreload = settings_saver.get_autoreload_state()
		show_actions = settings_saver.get_show_actions_state()
		show_trails = settings_saver.get_show_trails_state()
	
	if game_saver.is_level_complete(current_level_number - 1):
		health = game_saver.get_health(current_level_number - 1)
		money = game_saver.get_money(current_level_number - 1)
		guns_collection = game_saver.get_guns_collection(current_level_number - 1)
		active_gun_number = game_saver.get_active_gun_number(current_level_number - 1)
		change_gun(guns_collection[active_gun_number].id)
	
	add_child(shot_timer)
	shot_timer.one_shot = true
	shot_timer.start(guns_collection[active_gun_number].rate)
	
	add_child(reload_timer)
	reload_timer.one_shot = true
	reload_timer.connect("timeout", self, "reload")
	
	$UI.refresh_panel(health, money, guns_collection[active_gun_number])
	
# warning-ignore:unused_argument
func _process(delta):
	if health <= 0 and !is_dead:
		is_dead = true
		$DeathStreamPlayer2D.play()
		$UI.player_killed()
		get_tree().paused = true
		
	if get_viewport().get_mouse_position().x < 800 / 2:
		$Gun/GunSprite.flip_v = true
	else:
		$Gun/GunSprite.flip_v = false
	
	$Gun/GunSprite.look_at(get_mouse_position_from_zero())
	
# warning-ignore:unused_argument
func _input(event):
	if Input.is_key_pressed(KEY_F9):
		is_nohit = !is_nohit
		if is_nohit:
			$UI/MessageLabel.show_message("[Cheat] NOHIT activated", 3)
		else:
			$UI/MessageLabel.show_message("[Cheat] NOHIT deactivated", 3)
	
	if Input.is_key_pressed(KEY_F10):
		guns_collection.resize(0)
		guns_collection.append(guns_manager.get_gun(0))
		guns_collection.append(guns_manager.get_gun(1))
		guns_collection.append(guns_manager.get_gun(2))
		guns_collection.append(guns_manager.get_gun(3))
		guns_collection.append(guns_manager.get_gun(4))
		guns_collection.append(guns_manager.get_gun(5))
		guns_collection.append(guns_manager.get_gun(6))
		$UI/MessageLabel.show_message("[Cheat] All guns taked", 3)
		
	if Input.is_key_pressed(KEY_F11):
		guns_collection[active_gun_number].bullets += 100
		$UI.refresh_panel(health, money, guns_collection[active_gun_number])
		$UI/MessageLabel.show_message("[Cheat] 100 bullets added", 3)
		
	if Input.is_key_pressed(KEY_F12):
		money += 100
		$UI.refresh_panel(health, money, guns_collection[active_gun_number])
		$UI/MessageLabel.show_message("[Cheat] 100 moneys added", 3)
		
	if Input.is_key_pressed(KEY_ESCAPE):
		$UI.pause()
		get_tree().paused = true
		
	if Input.is_action_pressed("next_gun") and !Input.is_action_pressed("previous_gun"):
		if guns_collection.size() > active_gun_number + 1:
			active_gun_number += 1
		else:
			active_gun_number = 0
		change_gun(guns_collection[active_gun_number].id)
	elif Input.is_action_pressed("previous_gun") and !Input.is_action_pressed("next_gun"):
		if active_gun_number - 1 >= 0:
			active_gun_number -= 1
		else:
			active_gun_number = guns_collection.size() - 1
		change_gun(guns_collection[active_gun_number].id)
		
	if Input.is_action_pressed("reload"):
		start_reload()
	
# warning-ignore:unused_argument
func _physics_process(delta):
	if is_dead:
		return
	
	motion.y += gravitation
	
	if is_on_floor() and motion.y > max_gravitation:
		motion.y = max_gravitation
	
	if is_on_ceiling():
		motion.y = gravitation
		
	if Input.is_action_pressed("up") or Input.is_action_pressed("ui_select"):
		if is_on_floor():
			motion.y = -jump
	
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		motion.x = -speed
		$AnimatedSprite.play("Run_L")
		if !is_on_floor():
			$WalkAudioStreamPlayer2D.stop()
		elif !$WalkAudioStreamPlayer2D.playing:
			randomize()
			$WalkAudioStreamPlayer2D.stream = load("res://Audios/Player/Steps" + var2str(int(rand_range(0, 2))) + ".wav")
			$WalkAudioStreamPlayer2D.play()
	elif Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		motion.x = speed
		$AnimatedSprite.play("Run_R")
		if !is_on_floor():
			$WalkAudioStreamPlayer2D.stop()
		elif !$WalkAudioStreamPlayer2D.playing:
			randomize()
			$WalkAudioStreamPlayer2D.stream = load("res://Audios/Player/Steps" + var2str(int(rand_range(0, 2))) + ".wav")
			$WalkAudioStreamPlayer2D.play()
	else:
		motion.x = 0
		
		if $AnimatedSprite.animation == "Run_R":
			$AnimatedSprite.play("Wait", true)
		elif $AnimatedSprite.animation == "Run_L":
			$AnimatedSprite.play("Wait")
			
		$WalkAudioStreamPlayer2D.stop()
		
	if Input.is_action_pressed("shot") and guns_collection[active_gun_number].is_automatic:
		shot()
	elif Input.is_action_just_pressed("shot") and !guns_collection[active_gun_number].is_automatic:
		shot()
	
	# warning-ignore:return_value_discarded
	move_and_slide(motion, up)
	
# Returns the position of the mouse relative to scene zero
func get_mouse_position_from_zero():
	var viewport_start_position = Vector2(0, 0)
	viewport_start_position.x = position.x - 800 / 2
	viewport_start_position.y = position.y - 600 / 2
	
	return viewport_start_position + get_viewport().get_mouse_position()
	
# Returns the ratio of original (800x600) to current resolution
func get_resolution_ratio():
	return get_viewport().size.x / 800
	
# Returns the size of the black area from the edge of the screen
func get_aspect_ratio_difference():
	if !OS.window_fullscreen:
		return Vector2(1, 1)
	
	if OS.get_screen_size().y == get_viewport().size.y:
		return Vector2((OS.get_screen_size().x - get_viewport().size.x) / 2, 1)
	if OS.get_screen_size().x == get_viewport().size.x:
		return Vector2(1, (OS.get_screen_size().y - get_viewport().size.y) / 2)
	
func add_money(var number):
	money += number
	$UI.refresh_panel(health, money, guns_collection[active_gun_number])
	
func heal(var power):
	if !is_dead:
		if health + power < max_health:
			health += power
		else:
			health = max_health
	$UI.refresh_panel(health, money, guns_collection[active_gun_number])
	
	if show_actions:
		$ActionSprite.show_heal()
	
func hit(var power):
	if is_nohit or is_dead:
		return
		
	health -= power
	$UI.refresh_panel(health, money, guns_collection[active_gun_number])
	
	if show_actions:
		$ActionSprite.show_hit()
	 
func give_bullets(var clips):
	for i in range(guns_collection.size()):
		guns_collection[i - 1].bullets += clips * guns_collection[i - 1].clip_size
	
	$UI.refresh_panel(health, money, guns_collection[active_gun_number])
	
func save_game():
	game_saver.save(current_level_number, health, money, guns_collection, active_gun_number)
	
func change_gun(var gun_id, var is_new_gun = false):
	reload_timer.stop()
	
	if is_new_gun:
		guns_collection.append(guns_manager.get_gun(gun_id))
		active_gun_number = guns_collection.size() - 1
		
	$Gun/GunSprite.texture = guns_manager.get_gun_sprite(guns_collection[active_gun_number].id)
	shot_timer.wait_time = guns_collection[active_gun_number].rate
	$Gun/GunAudioStreamPlayer2D.stream = guns_manager.get_gun_shot_sound(guns_collection[active_gun_number].id)
	$UI.refresh_panel(health, money, guns_collection[active_gun_number])
	
func start_reload():
	$Gun/GunAudioStreamPlayer2D.stream = guns_manager.get_gun_reload_sound(active_gun_number)
	$Gun/GunAudioStreamPlayer2D.play()
	
	reload_timer.start(guns_collection[active_gun_number].reload_time)
	
func reload():
	if guns_collection[active_gun_number].bullets <= 0:
		return
	
	guns_collection[active_gun_number].bullets -= guns_collection[active_gun_number].clip_size
	guns_collection[active_gun_number].loaded_bullets = guns_collection[active_gun_number].clip_size
	
	$UI/MessageLabel.show_message("Reloaded")
	$UI.refresh_panel(health, money, guns_collection[active_gun_number])
	
	$Gun/GunAudioStreamPlayer2D.stream = guns_manager.get_gun_shot_sound(active_gun_number)
	
func shot():
	if shot_timer.time_left != 0 or reload_timer.time_left != 0 or get_tree().paused:
		return
	
	if guns_collection[active_gun_number].loaded_bullets == 0:
		if autoreload:
			start_reload()
		return
		
	shot_timer.start()
	
	$Gun/GunAudioStreamPlayer2D.play()
	
#	if get_viewport().get_mouse_position().x < 400:
#		$AnimatedSprite.play("Shot_R")
#	else:
#		$AnimatedSprite.play("Shot_L")
	
	var result = get_world_2d().direct_space_state.intersect_ray(position, get_mouse_position_from_zero(), [self])
	
	guns_collection[active_gun_number].loaded_bullets -= 1
	$UI.refresh_panel(health, money, guns_collection[active_gun_number])
	
	if show_trails:
		var trail = load("res://Scenes/Trail.tscn").instance()
		$"../".add_child(trail)
		
		if result.has("position"):
			trail.start(position + $Gun.position, result.position)
		else:
			trail.start(position + $Gun.position, get_mouse_position_from_zero())
			
#		if guns_collection[active_gun_number].id == 5:
#			for i in range(4):
#				var additional_trail = load("res://Scenes/Trail.tscn").instance()
#				$"../".add_child(additional_trail)
#				if result.has("position"):
#					randomize()
#					additional_trail.start(position + $Gun.position, result.position + Vector2(rand_range(5, 10), rand_range(5, 10)))
#				else:
#					additional_trail.start(position + $Gun.position, get_mouse_position_from_zero() + Vector2(rand_range(5, 10), rand_range(5, 10)))
	
	var min_offset_value = -10 * guns_collection[active_gun_number].power
	var max_offset_value = 10 * guns_collection[active_gun_number].power
	
	randomize()
	var x_offset = rand_range(min_offset_value, max_offset_value)
	randomize()
	var y_offset = rand_range(min_offset_value, max_offset_value)
	var offset = Vector2(x_offset, y_offset) * get_resolution_ratio()
	
	var real_mouse_position = get_viewport().get_mouse_position() * get_resolution_ratio()
	var new_mouse_position = real_mouse_position + offset + get_aspect_ratio_difference()
	Input.warp_mouse_position(new_mouse_position)
	
	if result.has("collider"):
		if result.collider.is_in_group("Enemies"):
			result.collider.call("hit", guns_collection[active_gun_number].power)
	
	var recoil = (get_mouse_position_from_zero() - position).normalized() * guns_collection[active_gun_number].recoil
	recoil.x *= 10
	recoil.y /= 10
	motion -= recoil
	
func game_complete():
	get_tree().paused = true
	
	is_dead = true
	$UI.game_complete()
	
	add_child(final_timer)
	final_timer.pause_mode = Node.PAUSE_MODE_PROCESS
	final_timer.one_shot = true
	final_timer.connect("timeout", self, "load_main_menu")
	final_timer.start(5)
	
func load_main_menu():
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/Menu.tscn"))
