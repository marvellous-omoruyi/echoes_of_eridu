extends CharacterBody2D

@export var speed: float = 150.0
@export var patrol_distance: float = 200.0
@export var health: int = 100
@export var glowing_ball_scene: PackedScene

@onready var animated_sprite = $AnimatedSprite2D
@onready var shoot_timer = $ShootTimer

var direction: float = 1.0
var start_position_x: float
var is_player_in_range: bool = false # Tracks if the player is in the detection zone

func _ready():
	start_position_x = global_position.x
	if animated_sprite == null:
		push_error("AnimatedSprite2D node not found. Please name the node 'AnimatedSprite2D'.")
		set_process(false)
	
	# Stop the timer from running until the player is in range
	shoot_timer.stop()

func _physics_process(delta: float) -> void:
	# Change direction when the enemy reaches the patrol limit
	if direction == 1.0 and global_position.x >= start_position_x + patrol_distance:
		direction = -1.0
	elif direction == -1.0 and global_position.x <= start_position_x - patrol_distance:
		direction = 1.0

	velocity.x = direction * speed
	
	if velocity.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")
	
	move_and_slide()

# This function is called when the enemy is hit
func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took ", amount, " damage! Current health: ", health)
	
	if health <= 0:
		queue_free()

# This function is called when the Timer times out
func _on_shoot_timer_timeout():
	var glowing_ball_instance = glowing_ball_scene.instantiate()
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Only shoot if the player is in range
	if is_player_in_range:
		var shoot_direction = (player.global_position - global_position).normalized()
	
		glowing_ball_instance.global_position = global_position
		glowing_ball_instance.direction = shoot_direction
	
		get_tree().get_root().add_child(glowing_ball_instance)
	
		animated_sprite.play("attack")
	
# This function runs when a body enters the DetectionZone
func _on_detection_zone_body_entered(body: Node2D):
	if body.is_in_group("playddder"):
		is_player_in_range = true
		shoot_timer.start()

# This function runs when a body exits the DetectionZone
func _on_detection_zone_body_exited(body: Node2D):
	if body.is_in_group("player"):
		is_player_in_range = false
		shoot_timer.stop()
