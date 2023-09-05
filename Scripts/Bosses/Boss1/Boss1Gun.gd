extends Node2D

export(float) var lethargy = 1.75
export(int, "Desert Eagle", "Mac-10", "HK MP5", "AK47", "M4A1", "Benelli M4 Super 90", "M249 SAW") var gun_id

var enemy_position: Vector2
var gun: Dictionary

var shot_timer: Timer = Timer.new()
var reload_timer: Timer = Timer.new()

onready var player: Node = $"../../../Player"

func _ready() -> void:
	enemy_position = $"../../".position
	
	gun = GunsManager.get_gun(gun_id)
	
	add_child(shot_timer)
	shot_timer.start(gun.rate + rand_range(0.5, lethargy))
	# warning-ignore:return_value_discarded
	shot_timer.connect("timeout", self, "shot")
	
	add_child(reload_timer)
	reload_timer.one_shot = true
	# warning-ignore:return_value_discarded
	reload_timer.connect("timeout", self, "reload")
	
	$GunSprite.texture = GunsManager.get_gun_sprite(gun_id)
	$GunAudioStreamPlayer2D.stream = GunsManager.get_gun_shot_sound(gun_id)

func _process(_delta: float) -> void:
	if player.position.x < position.x + enemy_position.x:
		$GunSprite.flip_v = true
	else:
		$GunSprite.flip_v = false
	
	$GunSprite.look_at(player.position)

func reload() -> void:
	gun.loaded_bullets = gun.clip_size
	$GunAudioStreamPlayer2D.stream = GunsManager.get_gun_shot_sound(gun_id)
	shot_timer.start(gun.rate + rand_range(0.5, lethargy))

func shot() -> void:
	if $"../../".dead or $"../../../Player".ghost_mode:
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
		result = get_world_2d().direct_space_state.intersect_ray(position + enemy_position, player.position + Vector2(rand_range(15, 50), rand_range(15, 50)), [self])
	
	if SettingsManager.get_setting("trails") and result.has("position"):
		var trail: Node = load("res://Scenes/Trail.tscn").instance()
		$"../../../".add_child(trail)
		trail.start(position + enemy_position, result.position)
	
	$GunAudioStreamPlayer2D.play()
	
	if result != null:
		if result.has("collider"):
			if result.collider.is_in_group("Players"):
				result.collider.call("hit", gun.power)
