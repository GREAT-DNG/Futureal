extends KinematicBody2D

const GRAVITATION: float = 10.0
const MAX_GRAVITATION: float = 150.0
const JUMP: float = 500.0
const ALLOWABLE_ERROR: Vector2 = Vector2(1, 1)

export(float) var health = 10.0
export(float) var health_difference = 2.5
export(float) var speed = 100.0
export(float) var lethargy = 1.0
export(int, "Desert Eagle", "Mac-10", "HK MP5", "AK47", "M4A1", "Benelli M4 Super 90", "M249 SAW") var gun_id
export(PoolVector2Array) var path
export(bool) var shot_always
export(int, "Follow path", "Follow player", "Follow player after seen") var mode

var motion: Vector2 = Vector2()
var additional_motion: Vector2 = Vector2()

var seen = false

var next_position_index: int = 0
var run_wait_time: float = 5.0 # The time to wait before moving to the next point of path

var gun: Dictionary

var shot_timer: Timer = Timer.new()
var reload_timer: Timer = Timer.new()
var shot_wait_timer: Timer = Timer.new()
var run_wait_timer: Timer = Timer.new()

onready var player: Node = $"../../../Player"

func _ready() -> void:
	gun = GunsManager.get_gun(gun_id)
	
	add_child(shot_timer)
	shot_timer.start(gun.rate + rand_range(0.5, lethargy))
	# warning-ignore:return_value_discarded
	shot_timer.connect("timeout", self, "shot")
	
	add_child(reload_timer)
	reload_timer.one_shot = true
	# warning-ignore:return_value_discarded
	reload_timer.connect("timeout", self, "reload")
	
	add_child(shot_wait_timer)
	shot_wait_timer.one_shot = true
	
	add_child(run_wait_timer)
	run_wait_timer.one_shot = true
	
	$GunSprite.texture = GunsManager.get_gun_sprite(gun_id)
	$GunAudioStreamPlayer2D.stream = GunsManager.get_gun_shot_sound(gun_id)
	
	if path.size() != 0 or mode > 0:
		speed += rand_range(-10, 10)
		run_wait_time += rand_range(-1.5, 1.5)
	
	if SettingsManager.get_setting("difficulty") == 0:
		health -= health_difference
	elif SettingsManager.get_setting("difficulty") == 2:
		health += health_difference
	
	if !SettingsManager.get_setting("exactness"):
		$HealthProgressBar.max_value = health
		$HealthLabel.hide()
		$HealthProgressBar.show()
	
	refresh_panel()

func _process(_delta: float) -> void:
	if $VisibilityNotifier2D.is_on_screen() and !seen:
		seen = true
	
	if player.position.x < position.x:
		$GunSprite.flip_v = true
	else:
		$GunSprite.flip_v = false
	
	$GunSprite.look_at(player.position)

func _physics_process(_delta: float) -> void:
	motion.y += GRAVITATION
	
	if is_on_floor() and motion.y > MAX_GRAVITATION:
		motion.y = MAX_GRAVITATION
	
	if is_on_ceiling():
		motion.y = GRAVITATION
	
	if path.size() != 0 and (mode != 2 or (mode == 2 and seen)) and run_wait_timer.is_stopped():
		var target = Vector2()
		
		if mode == 0 or (mode == 2 and !seen):
			target = path[next_position_index]
		elif mode == 1 or (mode == 2 and seen):
			target = player.position
		
		if target.x > position.x:
			motion.x = speed
		elif target.x < position.x:
			motion.x = -speed
		
		if target.y < position.y:
			var result = get_world_2d().direct_space_state.intersect_ray(position, Vector2(position.x + motion.x, position.y), [self])
			if result != null:
				if result.has("collider") and is_on_floor():
					motion.y = -JUMP
		
		if abs(target.x - position.x) < ALLOWABLE_ERROR.x and abs(target.y - position.y) < ALLOWABLE_ERROR.y and (mode == 0 or (mode == 2 and !seen)):
			if next_position_index < (path.size() - 1):
				next_position_index += 1
			elif next_position_index == (path.size() - 1):
				next_position_index = 0
			
			run_wait_timer.start(run_wait_time)
			motion.x = 0
		
		if motion.x != 0 and is_on_floor() and !$WalkAudioStreamPlayer2D.playing:
			$WalkAudioStreamPlayer2D.stream = load("res://Audios/Player/Steps " + var2str(int(rand_range(0, 2))) + ".wav")
			$WalkAudioStreamPlayer2D.play()
		elif motion.x == 0 or !is_on_floor():
			$WalkAudioStreamPlayer2D.stop()
	
	var new_animation = "Wait"
	if abs(motion.x) > speed - ALLOWABLE_ERROR.x:
		if motion.x < 0:
			new_animation = "Run_L"
		elif motion.x > 0:
			new_animation = "Run_R"
	if new_animation != $AnimatedSprite.animation:
		$AnimatedSprite.play(new_animation, $AnimatedSprite.animation == "Run_R")
	
	motion += additional_motion
	additional_motion = Vector2(0, 0)
	
	# warning-ignore:return_value_discarded
	move_and_slide(motion, Vector2 (0, -1))

func refresh_panel() -> void:
	if SettingsManager.get_setting("exactness"):
		$HealthLabel.text = var2str(stepify(health, 0.1))
	else:
		$HealthProgressBar.value = stepify(health, 0.1)

func hit (power: float) -> void:
	if stepify(health, 0.1) > 0.0:
		if is_on_floor():
			additional_motion.y -= power * 150
		health -= power
		if stepify(health, 0.1) <= 0.0:
			health = 0.0
			$AnimationPlayer.play("Death")
		refresh_panel()
		if SettingsManager.get_setting("actions"):
			$ActionColorRect.show_hit()

func reload() -> void:
	gun.loaded_bullets = gun.clip_size
	$GunAudioStreamPlayer2D.stream = GunsManager.get_gun_shot_sound(gun_id)
	shot_timer.start(gun.rate + rand_range(0.5, lethargy))

func shot() -> void:
	if stepify(health, 0.1) <= 0.0 or (!$VisibilityNotifier2D.is_on_screen() and !shot_always) or player.ghost_mode:
		return
	
	if gun.loaded_bullets <= 0:
		$GunAudioStreamPlayer2D.stream = GunsManager.get_gun_reload_sound(gun_id)
		$GunAudioStreamPlayer2D.play()
		reload_timer.start(gun.reload_time + rand_range(0.5, lethargy))
		shot_timer.stop()
		return
	
	gun.loaded_bullets -= 1
	
	var result: Dictionary
	
	if player != null:
		result = get_world_2d().direct_space_state.intersect_ray(position, player.position + Vector2(rand_range(15, 50), rand_range(15, 50)), [self])
	
	if SettingsManager.get_setting("trails") and result.has("position"):
		var trail: Node = load("res://Scenes/Trail.tscn").instance()
		get_parent().add_child(trail)
		trail.start(position, result.position)
	
	$GunAudioStreamPlayer2D.play()
	
	if result != null:
		if result.has("collider"):
			if result.collider.is_in_group("Players"):
				result.collider.call("hit", gun.power)
