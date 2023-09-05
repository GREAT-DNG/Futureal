extends Node2D

const TELEPORT_TIMER_WAIT_TIME: int = 10
const SPEED: float = 10.0
const MAX_DIFFERENCE: int = 25
const FIELD: Vector2 = Vector2(600, 500)

export(float) var health = 25.0

var body_motion: Vector2 = Vector2()
var start_position: Vector2
var dead: bool = false

var teleport_timer: Timer = Timer.new()

onready var obstacle: Node = $"../Obstacle"

func _ready() -> void:
	body_motion.y = SPEED
	
	teleportation()
	
	add_child(teleport_timer)
	# warning-ignore:return_value_discarded
	teleport_timer.connect("timeout", $AnimationPlayer, "play", ["Teleportation"])
	teleport_timer.start(TELEPORT_TIMER_WAIT_TIME)
	
	refresh_panel()

func _physics_process(_delta: float) -> void:
	if (start_position.y + MAX_DIFFERENCE <= $Body.position.y) or (start_position.y - MAX_DIFFERENCE >= $Body.position.y):
		body_motion.y = -body_motion.y
	
	$Body.move_and_slide(body_motion)

func refresh_panel() -> void:
	$Body/HealthLabel.text = var2str(stepify(health, 0.1))

func hit (power: float) -> void:
	if stepify(health, 0.1) >= 0.0:
		health -= power
		if stepify(health, 0.1) <= 0.0:
			health = 0.0
			obstacle.get_node("AnimationPlayer").play("Destruction")
			obstacle.get_node("AudioStreamPlayer2D").play()
			$AnimationPlayer.play("Death")
			dead = true
		refresh_panel()
		if SettingsManager.get_setting("actions"):
			$Body/ActionColorRect.show_hit()

func teleportation() -> void:
	if dead:
		return
	
	$Body/CollisionShape2D.disabled = true
	
	var new_x: float = rand_range(-FIELD.x / 2, FIELD.x / 2)
	var new_y: float = rand_range(-FIELD.y / 2, FIELD.y / 2)
	$Body.position = Vector2(new_x, new_y)
	
	start_position = $Body.position
	
	for i in range($Guns.get_child_count()):
		var gun_new_x: float = rand_range(-FIELD.x / 2, FIELD.x / 2)
		var gun_new_y: float = rand_range(-FIELD.y / 2, FIELD.y / 2)
		$Guns.get_children()[i].position = Vector2(gun_new_x, gun_new_y)
	
	$Body/CollisionShape2D.disabled = false
