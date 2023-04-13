extends Area2D

export(Vector2) var spawn_position
export(int, 0, 1) var enemy_type
export(int, 0, 6) var gun_id
export(bool) var one_shot = true

var is_used = false

func _on_EnemySpawner_body_entered(body):
	if body.is_in_group("Player"):
		if (!one_shot) or (one_shot and !is_used):
			var enemy = load("res://Scenes/Enemies/Enemy" + var2str(enemy_type) + ".tscn").instance()
			enemy.position = spawn_position
			enemy.gun_id = gun_id
			get_node(NodePath("../../Enemies/" + var2str(enemy_type))).call_deferred("add_child", enemy)
			is_used = true
