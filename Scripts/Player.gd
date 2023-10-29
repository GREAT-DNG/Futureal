extends KinematicBody2D

const GRAVITATION: float = 10.0
const JUMP: float = 500.0
const MAX_GRAVITATION: float = 150.0
const MAX_HARMLESS_GRAVITATION: float = 750.0
const MAX_HEALTH: float = 25.0
const MAX_STAMINA: float = 200.0
const MAX_SPEED: float = 250.0

puppet var motion: Vector2 = Vector2()
var additional_motion: Vector2 = Vector2()
var speed: float = 160.0
var stamina: float = 200.0

puppetsync var active_gun_number: int = 0
puppetsync var guns_collection: Array = [GunsManager.get_gun(0)]

var shot_timer: Timer = Timer.new()
var reload_timer: Timer = Timer.new()
var final_timer: Timer = Timer.new()

puppetsync var health: float = 10.0

var cheats_used: bool = false
var immortality_mode: bool = false
var all_guns: bool = false
var endless_bullets_mode: bool = false
var ghost_mode: bool = false

func _ready() -> void:
	if !MultiplayerManager.is_multiplayer() and get_parent().level == 0:
		push_error("\"Player\": Incorrect level number")
	
	if !MultiplayerManager.is_multiplayer() or is_network_master():
		$GameUI/AnimationPlayer.play_backwards("Transition")
	
	if MultiplayerManager.is_multiplayer():
		rset_config("position", MultiplayerAPI.RPC_MODE_PUPPETSYNC)
		$Gun/Sprite.rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPETSYNC)
		$Gun/Sprite.rset_config("flip_v", MultiplayerAPI.RPC_MODE_PUPPETSYNC)
		$AnimationPlayer.rpc_config("play", MultiplayerAPI.RPC_MODE_PUPPET)
		$AnimationPlayer.rpc_config("play_backwards", MultiplayerAPI.RPC_MODE_PUPPET)
		if is_network_master():
			$Camera2D.current = true
			$CanvasModulate.visible = true
			# warning-ignore:return_value_discarded
			MultiplayerManager.connect("game_info_updated", $GameUI, "update_game_info")
		else:
			$MultiplayerStats.show()
			$MultiplayerStats.rpc("refresh_stats", health)
	
	if !MultiplayerManager.is_multiplayer() and GameSaver.is_level_complete(get_parent().level - 1):
		health = GameSaver.get_health(get_parent().level - 1)
		guns_collection = GameSaver.get_guns_collection(get_parent().level - 1)
		active_gun_number = GameSaver.get_active_gun_number(get_parent().level - 1)
		change_gun(guns_collection[active_gun_number].id)
	
	add_child(shot_timer)
	shot_timer.one_shot = true
	shot_timer.start(guns_collection[active_gun_number].rate)
	
	add_child(reload_timer)
	reload_timer.one_shot = true
	# warning-ignore:return_value_discarded
	reload_timer.connect("timeout", self, "reload")
	
	if !MultiplayerManager.is_multiplayer() or is_network_master():
		$GameUI.refresh_panel(health, guns_collection[active_gun_number])

func _process(_delta: float) -> void:
	if ((Input.is_action_pressed("shot") and guns_collection[active_gun_number].is_automatic) or (Input.is_action_just_pressed("shot") and !guns_collection[active_gun_number].is_automatic)) and (!MultiplayerManager.is_multiplayer() or is_network_master()):
		if !MultiplayerManager.is_multiplayer():
			shot(get_mouse_position_from_zero())
		elif is_network_master():
			rpc("shot", get_mouse_position_from_zero())
	
	if Input.is_action_pressed("game_info") and (!MultiplayerManager.is_multiplayer() or is_network_master()):
		$GameUI.show_game_info()
	elif !MultiplayerManager.is_multiplayer() or is_network_master():
		$GameUI.hide_game_info()
	
	if !MultiplayerManager.is_multiplayer() or is_network_master():
		$Gun/Sprite.flip_v = get_viewport().get_mouse_position().x < 800 / 2
		$Gun/Sprite.look_at(get_mouse_position_from_zero())
		if MultiplayerManager.is_multiplayer():
			$Gun/Sprite.rset("rotation", $Gun/Sprite.rotation)
			$Gun/Sprite.rset("flip_v", $Gun/Sprite.flip_v)

func _input(event: InputEvent) -> void:
	if MultiplayerManager.is_multiplayer() and !is_network_master():
		return
	
	if event.is_action_pressed("next_gun") and !event.is_action_pressed("previous_gun"):
		if guns_collection.size() > active_gun_number + 1:
			active_gun_number += 1
		else:
			active_gun_number = 0
		if !MultiplayerManager.is_multiplayer():
			change_gun(guns_collection[active_gun_number].id)
		elif is_network_master():
			rset("active_gun_number", active_gun_number)
			rpc("change_gun", guns_collection[active_gun_number].id)
	elif event.is_action_pressed("previous_gun") and !event.is_action_pressed("next_gun"):
		if active_gun_number - 1 >= 0:
			active_gun_number -= 1
		else:
			active_gun_number = guns_collection.size() - 1
		if !MultiplayerManager.is_multiplayer():
			change_gun(guns_collection[active_gun_number].id)
		elif is_network_master():
			rset("active_gun_number", active_gun_number)
			rpc("change_gun", guns_collection[active_gun_number].id)
	
	if event.is_action_pressed("reload"):
		if !MultiplayerManager.is_multiplayer():
			start_reload()
		elif is_network_master():
			rpc("start_reload")
	
	if event.is_action_pressed("pause"):
		$GameUI/PausePanel.show()
		get_tree().paused = true
		if MultiplayerManager.is_multiplayer():
			$AnimationPlayer.rpc("play", "Inactive")
	
	if Input.is_key_pressed(KEY_F9) and !MultiplayerManager.is_multiplayer():
		immortality_mode = !immortality_mode
		if immortality_mode:
			$GameUI/MessageLabel.show_message("[Cheat] Immortality mode activated", 3)
		else:
			$GameUI/MessageLabel.show_message("[Cheat] Immortality mode deactivated", 3)
	
	if Input.is_key_pressed(KEY_F10) and !MultiplayerManager.is_multiplayer():
		all_guns = true
		guns_collection.resize(0)
		guns_collection.append(GunsManager.get_gun(0))
		guns_collection.append(GunsManager.get_gun(1))
		guns_collection.append(GunsManager.get_gun(2))
		guns_collection.append(GunsManager.get_gun(3))
		guns_collection.append(GunsManager.get_gun(4))
		guns_collection.append(GunsManager.get_gun(5))
		guns_collection.append(GunsManager.get_gun(6))
		$GameUI/MessageLabel.show_message("[Cheat] All guns taked", 3)
		cheats_used = true
	
	if Input.is_key_pressed(KEY_F11) and !MultiplayerManager.is_multiplayer():
		endless_bullets_mode = !endless_bullets_mode
		if endless_bullets_mode:
			$GameUI/MessageLabel.show_message("[Cheat] Endless bullets mode activated", 3)
		else:
			$GameUI/MessageLabel.show_message("[Cheat] Endless bullets mode deactivated", 3)
		cheats_used = true
	
	if Input.is_key_pressed(KEY_F12) and !MultiplayerManager.is_multiplayer():
		ghost_mode = !ghost_mode
		if ghost_mode:
			$CollisionShape2D.disabled = true
			speed *= 1.5
			$Camera2D.zoom *= 1.5
			modulate.a = 0.5
			$GameUI/MessageLabel.show_message("[Cheat] Ghost mode activated", 3)
		else:
			$CollisionShape2D.disabled = false
			speed /= 1.5
			$Camera2D.zoom /= 1.5
			modulate.a = 1
			$GameUI/MessageLabel.show_message("[Cheat] Ghost mode deactivated", 3)
		cheats_used = true

func _physics_process(_delta: float) -> void:
	if health <= 0:
		return
	
	if !ghost_mode:
		motion.y += GRAVITATION
	
	if is_on_floor():
		if (motion.y > MAX_HARMLESS_GRAVITATION) and SettingsManager.get_setting("difficulty") > 0:
			hit(motion.y / (MAX_HARMLESS_GRAVITATION / (1.25 * SettingsManager.get_setting("difficulty"))), false)
		if motion.y > MAX_GRAVITATION:
			motion.y = MAX_GRAVITATION
	
	if is_on_ceiling():
		motion.y = GRAVITATION
	
	if !MultiplayerManager.is_multiplayer() or is_network_master():
		if Input.is_action_pressed("up") and !Input.is_action_pressed("down"):
			if ghost_mode:
				motion.y = -speed
			elif is_on_floor():
				motion.y = -JUMP
		elif Input.is_action_pressed("down") and ghost_mode and !Input.is_action_pressed("up"):
			motion.y = speed
		elif ghost_mode:
			motion.y = 0
		
		if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
			if Input.is_action_pressed("run") and stamina - 1 > 0 and is_on_floor():
				$WalkAudioStreamPlayer2D.pitch_scale = 1 + (stamina / MAX_STAMINA) / 2
				if speed + stamina > MAX_SPEED:
					motion.x = -MAX_SPEED
				else:
					motion.x = -(speed + stamina)
				stamina -= 1
			else:
				motion.x = -speed
				if stamina + 2 <= MAX_STAMINA:
					stamina += 2
		elif Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
			if Input.is_action_pressed("run") and stamina - 1 > 0 and is_on_floor():
				$WalkAudioStreamPlayer2D.pitch_scale = 1 + (stamina / MAX_STAMINA) / 2
				if speed + stamina > MAX_SPEED:
					motion.x = MAX_SPEED
				else:
					motion.x = speed + stamina
				stamina -= 1
			else:
				motion.x = speed
				if stamina + 1 <= MAX_STAMINA:
					stamina += 1
		else:
			motion.x = 0
			if stamina + 2 <= MAX_STAMINA:
				stamina += 2
		
		if MultiplayerManager.is_multiplayer():
			rset("position", position)
			rset("motion", motion)
	
	if motion.x != 0 and is_on_floor() and !$WalkAudioStreamPlayer2D.playing:
		$WalkAudioStreamPlayer2D.stream = load("res://Audios/Player/Steps " + var2str(int(rand_range(0, 2))) + ".wav")
		$WalkAudioStreamPlayer2D.play()
	elif motion.x == 0 or !is_on_floor():
		$WalkAudioStreamPlayer2D.stop()
	
	var new_animation = "Wait"
	if motion.x < 0:
		if motion.y > 0 and !is_on_floor():
			new_animation = "Fall_L"
		elif motion.y < 0 and !is_on_floor():
			new_animation = "Jump_L"
		else:
			new_animation = "Run_L"
	elif motion.x > 0:
		if motion.y > 0 and !is_on_floor():
			new_animation = "Fall_R"
		elif motion.y < 0 and !is_on_floor():
			new_animation = "Jump_R"
		else:
			new_animation = "Run_R"
	else:
		if motion.y > 0 and !is_on_floor():
			new_animation = "Fall"
		elif motion.y < 0 and !is_on_floor():
			new_animation = "Jump"
	
	if new_animation != $AnimatedSprite.animation:
		$AnimatedSprite.play(new_animation, $AnimatedSprite.animation == "Run_R")
	
	motion += additional_motion
	additional_motion = Vector2(0, 0)
	
	# warning-ignore:return_value_discarded
	move_and_slide(motion, Vector2(0, -1))

# Returns the position of the mouse relative to scene zero
func get_mouse_position_from_zero() -> Vector2:
	var viewport_start_position = Vector2(0, 0)
	viewport_start_position.x = position.x - 800 / 2
	viewport_start_position.y = position.y - 600 / 2
	
	return viewport_start_position + get_viewport().get_mouse_position()

# Returns the ratio of original (800x600) to current resolution
func get_resolution_ratio() -> float:
	return get_viewport().size.x / 800

# Returns the size of the black area from the edge of the screen
func get_aspect_ratio_difference() -> Vector2:
	if OS.window_fullscreen and OS.get_screen_size().y == get_viewport().size.y:
		return Vector2((OS.get_screen_size().x - get_viewport().size.x) / 2, 1)
	if OS.window_fullscreen and OS.get_screen_size().x == get_viewport().size.x:
		return Vector2(1, (OS.get_screen_size().y - get_viewport().size.y) / 2)
	return Vector2(1, 1)

remotesync func heal(power: float) -> void:
	if health + power < MAX_HEALTH:
		health += power
	else:
		health = MAX_HEALTH
	
	if SettingsManager.get_setting("actions"):
		$ActionColorRect.show_heal()
	
	if !MultiplayerManager.is_multiplayer() or is_network_master():
		$GameUI.refresh_panel(health, guns_collection[active_gun_number])
	elif !is_network_master():
		$MultiplayerStats.refresh_stats(health)

remotesync func hit(power: float, kick: bool = true) -> void:
	if immortality_mode:
		return
	
	health -= power
	
	if health <= 0:
		$DeathStreamPlayer2D.play()
		if !MultiplayerManager.is_multiplayer():
			$GameUI.player_killed()
			get_tree().paused = true
		elif is_network_master():
			MultiplayerManager.rpc("dead")
			MultiplayerManager.rpc("killed", get_tree().get_rpc_sender_id())
			rpc("respawn")
	
	if SettingsManager.get_setting("actions"):
		$ActionColorRect.show_hit()
	
	if is_on_floor() and kick:
		additional_motion.y -= power * 150
	
	if !MultiplayerManager.is_multiplayer() or is_network_master():
		$GameUI.refresh_panel(health, guns_collection[active_gun_number])
	elif !is_network_master():
		$MultiplayerStats.refresh_stats(health)

puppetsync func give_bullets(clips: int) -> void:
	for i in range(guns_collection.size()):
		guns_collection[i - 1].bullets += clips * guns_collection[i - 1].clip_size
	
	if !MultiplayerManager.is_multiplayer() or is_network_master():
		$GameUI.refresh_panel(health, guns_collection[active_gun_number])

puppetsync func change_gun(gun_id: int, new_gun: bool = false) -> void:
	reload_timer.stop()
	
	if new_gun and !all_guns:
		if gun_exists(gun_id):
			guns_collection[guns_collection.find(GunsManager.get_gun(gun_id))].bullets += GunsManager.get_gun(gun_id).bullets
		else:
			guns_collection.append(GunsManager.get_gun(gun_id))
		if SettingsManager.get_setting("autochange"):
			active_gun_number = guns_collection.size() - 1
	
	$Gun/Sprite.texture = GunsManager.get_gun_sprite(guns_collection[active_gun_number].id)
	shot_timer.wait_time = guns_collection[active_gun_number].rate
	$Gun/AudioStreamPlayer2D.stream = GunsManager.get_gun_shot_sound(guns_collection[active_gun_number].id)
	if !MultiplayerManager.is_multiplayer() or is_network_master():
		$GameUI.refresh_panel(health, guns_collection[active_gun_number])

func gun_exists(gun_id: int) -> bool:
	for i in guns_collection:
		if i.id == gun_id:
			return true
	return false

puppetsync func start_reload() -> void:
	if guns_collection[active_gun_number].bullets <= 0:
		return
	
	$Gun/AudioStreamPlayer2D.stream = GunsManager.get_gun_reload_sound(active_gun_number)
	$Gun/AudioStreamPlayer2D.play()
	
	reload_timer.start(guns_collection[active_gun_number].reload_time)

func reload() -> void:
	if SettingsManager.get_setting("difficulty") < 2:
		guns_collection[active_gun_number].bullets -= guns_collection[active_gun_number].clip_size - guns_collection[active_gun_number].loaded_bullets
		guns_collection[active_gun_number].loaded_bullets = guns_collection[active_gun_number].clip_size
	else:
		guns_collection[active_gun_number].bullets -= guns_collection[active_gun_number].clip_size
		guns_collection[active_gun_number].loaded_bullets = guns_collection[active_gun_number].clip_size
	
	$Gun/AudioStreamPlayer2D.stream = GunsManager.get_gun_shot_sound(guns_collection[active_gun_number].id)
	
	if !MultiplayerManager.is_multiplayer() or is_network_master():
		$GameUI.refresh_panel(health, guns_collection[active_gun_number])
		$GameUI/MessageLabel.show_message("Reloaded")

puppetsync func shot(mouse_position_from_zero: Vector2) -> void:
	if !shot_timer.is_stopped() or !reload_timer.is_stopped() or get_tree().paused:
		return
	
	if guns_collection[active_gun_number].loaded_bullets == 0:
		if SettingsManager.get_setting("autoreload"):
			start_reload()
		return
	
	shot_timer.start()
	
	$Gun/AudioStreamPlayer2D.play()
	
	var result = get_world_2d().direct_space_state.intersect_ray(position, mouse_position_from_zero, [self])
	
	if !endless_bullets_mode:
		guns_collection[active_gun_number].loaded_bullets -= 1
		if !MultiplayerManager.is_multiplayer():
			$GameUI.refresh_panel(health, guns_collection[active_gun_number])
		elif is_network_master():
			rset("guns_collection", guns_collection)
	
	if SettingsManager.get_setting("trails"):
		var trail = load("res://Scenes/Trail.tscn").instance()
		get_parent().add_child(trail)
		
		if result.has("position"):
			trail.start(position + $Gun.position, result.position)
		else:
			trail.start(position + $Gun.position, mouse_position_from_zero)
	
	if !MultiplayerManager.is_multiplayer() or is_network_master():
		var min_offset_value = -10 * guns_collection[active_gun_number].power
		var max_offset_value = 10 * guns_collection[active_gun_number].power
		
		var x_offset = rand_range(min_offset_value, max_offset_value)
		var y_offset = rand_range(min_offset_value, max_offset_value)
		var offset = Vector2(x_offset, y_offset) * get_resolution_ratio()
		
		var real_mouse_position = get_viewport().get_mouse_position() * get_resolution_ratio()
		var new_mouse_position = real_mouse_position + offset + get_aspect_ratio_difference()
		Input.warp_mouse_position(new_mouse_position)
	
	if result.has("collider"):
		if result.collider.is_in_group("Enemies") or result.collider.is_in_group("Players"):
			if !MultiplayerManager.is_multiplayer():
				result.collider.hit(guns_collection[active_gun_number].power)
			elif is_network_master():
				result.collider.rpc("hit", guns_collection[active_gun_number].power)
	
	var recoil = (mouse_position_from_zero - position).normalized() * guns_collection[active_gun_number].recoil
	recoil.x *= 10
	recoil.y /= 10
	additional_motion -= recoil

func teleportation() -> void:
	if cheats_used:
		$GameUI/MessageLabel.show_message("Replay level without cheats")
		return
	$GameUI/AnimationPlayer.play("Transition")
	yield($GameUI/AnimationPlayer, "animation_finished")
	GameSaver.save(get_parent().level, health, guns_collection, active_gun_number)
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(get_parent().next_level)

puppetsync func respawn() -> void:
	active_gun_number = 0
	guns_collection.clear()
	change_gun(0, true)
	position = MultiplayerManager.spawn_positions[get_tree().get_network_unique_id()]
	health = 10.0
	if is_network_master():
		$GameUI.refresh_panel(health, guns_collection[active_gun_number])
	elif !is_network_master():
		$MultiplayerStats.rpc("refresh_stats", health)

func game_complete() -> void:
	get_tree().paused = true
	
	$GameUI.game_complete()
	
	add_child(final_timer)
	final_timer.pause_mode = Node.PAUSE_MODE_PROCESS
	final_timer.one_shot = true
	# warning-ignore:return_value_discarded
	final_timer.connect("timeout", self, "load_main_menu") # get_tree().create_timer()
	final_timer.start(5)

func load_main_menu() -> void:
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/UI/Menu.tscn"))
