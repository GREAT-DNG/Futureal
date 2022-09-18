extends KinematicBody2D

export(int) var gun_id
export(bool) var is_boss
export(bool) var shot_always

var motion = Vector2 ()
var gravitation = 10
var max_gravitation = 500
var up = Vector2 (0, -1)

var gun
var guns_manager = load("res://Scripts/GunsManager.gd").new()

var health = 10
var is_dead = false

var shot_timer = Timer.new()
var sprite_timer = Timer.new()
var reload_timer = Timer.new()

func _ready():
	randomize()
	
	if is_boss:
		health = 25
	
	gun = guns_manager.get_gun(gun_id)
	
	add_child(shot_timer)
	if !is_boss:
		shot_timer.start(gun.rate + rand_range(0.5, 1))
	else:
		shot_timer.start(gun.rate + 0.6)
	shot_timer.connect("timeout", self, "shot")
	
	add_child(sprite_timer)
	sprite_timer.start(3)
	sprite_timer.connect("timeout", self, "refresh_texture")
	
	add_child(reload_timer)
	reload_timer.one_shot = true
	reload_timer.connect("timeout", self, "reload")
	
	$GunSprite.texture = guns_manager.get_gun_sprite(gun_id)
	$AudioStreamPlayer2D.stream = guns_manager.get_gun_shot_sound(gun_id)
	
	refresh_panel()
	
# warning-ignore:unused_argument
func _process(delta):
	if $"../../Player".position.x < position.x:
		$GunSprite.flip_v = true
	else:
		$GunSprite.flip_v = false
		
	$GunSprite.look_at($"../../Player".position)
		
	if health <= 0 and !is_dead:
		$HealthLabel.hide()
		remove_child($CollisionShape2D)
		$"../../Player".add_money(5)
		is_dead = true
		
		if is_boss:
			$"../../Player".game_complete()
	
# warning-ignore:unused_argument
func _physics_process(delta):
	motion.y += gravitation
	
	if is_on_floor() and motion.y > max_gravitation:
		motion.y = max_gravitation
		
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
	
func reload():
	gun.loaded_bullets = gun.clip_size
	if !is_boss:
		shot_timer.start(gun.rate + rand_range(0.5, 1))
	else:
		shot_timer.start(gun.rate + 0.5)
	
func shot():
	if is_dead:
		return
	
	if !$VisibilityNotifier2D.is_on_screen():
		if !shot_always:
			return
	
	if gun.loaded_bullets <= 0:
		if is_boss:
			reload_timer.start(gun.reload_time + 1)
		else:
			reload_timer.start(gun.reload_time + rand_range(0.5, 1))
		shot_timer.stop()
		return
	
	gun.loaded_bullets -= 1
	
	var result
	
	if $"../../Player" != null:
		result = get_world_2d().direct_space_state.intersect_ray(position, $"../../Player".position + Vector2(rand_range(15, 50), rand_range(15, 50)), [self])
	
	$AudioStreamPlayer2D.play()
	
	if result != null:
		if result.has("collider"):
			if result.collider.name.find("Player") != -1:
				result.collider.call("hit", gun.power)
	
func _on_Enemy_mouse_entered():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor_R.png"))
	
func _on_Enemy_mouse_exited():
	Input.set_custom_mouse_cursor(load("res://Sprites/Cursors/Cursor.png"))
