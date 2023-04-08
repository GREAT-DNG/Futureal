extends KinematicBody2D

export(int) var health = 10
export(float) var lethargy = 1.0
export(int, 0, 6) var gun_id
export(PoolVector2Array) var path
export(bool) var shot_always
export(bool) var can_complete_game

var settings_saver = load("res://Scripts/Utilities/SettingsSaver.gd").new()
var guns_manager = load("res://Scripts/Utilities/GunsManager.gd").new()

var motion = Vector2()
var gravitation = 10
var max_gravitation = 250
var up = Vector2 (0, -1)
var speed = 100
var next_position = Vector2()
var next_position_index = 0
var wait_time = 5

var gun
var show_actions = false
var show_trails = false

var is_dead = false

var shot_timer = Timer.new()
var sprite_timer = Timer.new()
var reload_timer = Timer.new()
var wait_timer = Timer.new()

func _ready():
	randomize()
	
	gun = guns_manager.get_gun(gun_id)
	
	if settings_saver.check_settings():
		show_actions = settings_saver.get_show_actions_state()
		show_trails = settings_saver.get_show_trails_state()
	
	add_child(shot_timer)
	shot_timer.start(gun.rate + rand_range(0.5, lethargy))
	shot_timer.connect("timeout", self, "shot")
	
	add_child(sprite_timer)
	sprite_timer.start(3)
	sprite_timer.connect("timeout", self, "refresh_texture")
	
	add_child(reload_timer)
	reload_timer.one_shot = true
	reload_timer.connect("timeout", self, "reload")
	
	add_child(wait_timer)
	wait_timer.one_shot = true
	
	$GunSprite.texture = guns_manager.get_gun_sprite(gun_id)
	$AudioStreamPlayer2D.stream = guns_manager.get_gun_shot_sound(gun_id)
	
	if path.size() != 0:
		next_position = path[next_position_index]
	
	refresh_panel()
	
# warning-ignore:unused_argument
func _process(delta):
	if $"../../../Player".position.x < position.x:
		$GunSprite.flip_v = true
	else:
		$GunSprite.flip_v = false
		
	$GunSprite.look_at($"../../../Player".position)
		
	if health <= 0 and !is_dead:
		$HealthLabel.hide()
		remove_child($CollisionShape2D)
		$"../../../Player".add_money(5)
		is_dead = true
		
		if can_complete_game:
			$"../../../Player".game_complete()
	
# warning-ignore:unused_argument
func _physics_process(delta):
	motion.y += gravitation
	
	if is_on_floor() and motion.y > max_gravitation:
		motion.y = max_gravitation
		
	if path.size() != 0 and wait_timer.time_left == 0:
		if round(next_position.x) == round(position.x):
			if next_position_index < (path.size() - 1):
				next_position = path[next_position_index + 1]
				next_position_index += 1
			elif next_position_index == (path.size() - 1):
				next_position = path[0]
				next_position_index = 0
			wait_timer.start(wait_time)
			motion.x = 0
			$AnimatedSprite.play("Wait")
		elif next_position.x > position.x:
			motion.x = speed
			$AnimatedSprite.play("Run_R")
		elif next_position.x < position.x:
			motion.x = -speed
			$AnimatedSprite.play("Run_L")
		
	# warning-ignore:return_value_discarded
	move_and_slide(motion, up)
	
func refresh_panel():
	$HealthLabel.text = var2str(health)
	
func refresh_texture():
	if $VisibilityNotifier2D.is_on_screen():
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play()
	
func hit (var power):
	if !is_dead:
		health -= power
	refresh_panel()
	
	if show_actions:
		$ActionSprite.show_hit()
	
func reload():
	gun.loaded_bullets = gun.clip_size
	$AudioStreamPlayer2D.stream = guns_manager.get_gun_shot_sound(gun_id)
	shot_timer.start(gun.rate + rand_range(0.5, lethargy))
	
func shot():
	if is_dead:
		return
	
	if !$VisibilityNotifier2D.is_on_screen():
		if !shot_always:
			return
	
	if gun.loaded_bullets <= 0:
		$AudioStreamPlayer2D.stream = guns_manager.get_gun_reload_sound(gun_id)
		$AudioStreamPlayer2D.play()
		reload_timer.start(gun.reload_time + rand_range(0.5, lethargy))
		shot_timer.stop()
		return
	
	gun.loaded_bullets -= 1
	
	var result
	
	if $"../../../Player" != null:
		result = get_world_2d().direct_space_state.intersect_ray(position, $"../../../Player".position + Vector2(rand_range(15, 50), rand_range(15, 50)), [self])
	
	if show_trails and result.has("position"):
		var trail = load("res://Scenes/Trail.tscn").instance()
		$"../".add_child(trail)
		trail.start(position, result.position)
	elif !result.has("position"):
		return
		
	$AudioStreamPlayer2D.play()
	
	if result != null:
		if result.has("collider"):
			if result.collider.is_in_group("Player"):
				result.collider.call("hit", gun.power)
	
func _on_BasicEnemy_mouse_entered():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor_R.png"))
	
func _on_BasicEnemy_mouse_exited():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor.png"))
