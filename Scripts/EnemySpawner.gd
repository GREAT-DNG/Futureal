extends Area2D

export(Vector2) var spawn_position
export(bool) var one_shot = true
export(int, 0, 2) var enemy_type
export(int, "Desert Eagle", "Mac-10", "HK MP5", "AK47", "M4A1", "Benelli M4 Super 90", "M249 SAW") var gun_id
export(PoolVector2Array) var path
export(bool) var shot_always
export(int, "Follow path", "Follow player", "Follow player after seen") var mode

var enemy: Node
var used: bool = false

func _on_EnemySpawner_body_entered(body: Node) -> void:
	if body.is_in_group("Players"):
		if (!one_shot and ((used and enemy.dead) or !used)) or (one_shot and !used):
			enemy = load("res://Scenes/Enemies/Enemy" + var2str(enemy_type) + ".tscn").instance()
			enemy.position = spawn_position
			enemy.gun_id = gun_id
			enemy.path = path
			enemy.shot_always = shot_always
			enemy.mode = mode
			get_node("../../Enemies/" + var2str(enemy_type)).call_deferred("add_child", enemy)
			used = true
