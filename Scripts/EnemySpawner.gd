extends Area2D

export(Vector2) var spawn_position
export(int) var gun_id
export(bool) var one_shot = true

var is_used = false

func _on_EnemySpawner_body_entered(body):
	if one_shot and !is_used:
		if body.name == "Player":
			var enemy = load("res://Scenes/Enemy.tscn").instance()
			enemy.position = spawn_position
			enemy.gun_id = gun_id
			$"../../Enemies".call_deferred("add_child", enemy)
			is_used = true
	elif !one_shot:
		if body.name == "Player":
			var enemy = load("res://Scenes/Enemy.tscn").instance()
			enemy.position = spawn_position
			$"../../Enemies".call_deferred("add_child", enemy)
