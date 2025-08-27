extends CharacterBody2D

@export var speed: float = 150.0
@export var patrol_distance: float = 200.0
@export var health: int = 100
@export var glowing_ball_scene: PackedScene

@onready var animated_sprite = $AnimatedSprite2D
@onready var shoot_timer = $ShootTimer

var direction: float = 1.0
var start_position_x: float
var is_player_in_range: bool = false
var is_attacking: bool = false # Our new state variable

func _ready():
	start_position_x = global_position.x
	shoot_timer.stop()

func _physics_process(delta: float) -> void:
	# If we are in the middle of an attack, don't do anything else.
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	# If the player is in range, stop moving. Otherwise, patrol.
	if is_player_in_range:
		velocity.x = 0
	else:
		patrol()
	
	update_animation()
	move_and_slide()

func patrol():
	if direction == 1.0 and global_position.x >= start_position_x + patrol_distance:
		direction = -1.0
	elif direction == -1.0 and global_position.x <= start_position_x - patrol_distance:
		direction = 1.0
	velocity.x = direction * speed

func update_animation():
	if velocity.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()

func _on_shoot_timer_timeout():
	if is_player_in_range and not is_attacking:
		is_attacking = true
		animated_sprite.play("attack")

# This new function is CRITICAL. It resets our state after the attack animation finishes.
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false
		shoot_glowing_ball() # We shoot the ball at the end of the animation

func shoot_glowing_ball():
	var glowing_ball_instance = glowing_ball_scene.instantiate()
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		is_attacking = false # Failsafe
		return
		
	var shoot_direction = (player.global_position - global_position).normalized()
	glowing_ball_instance.global_position = global_position
	glowing_ball_instance.direction = shoot_direction
	get_tree().get_root().add_child(glowing_ball_instance)

# --- Signal Connections ---

func _on_detection_zone_body_entered(body: Node2D):
	if body.is_in_group("player"):
		is_player_in_range = true
		shoot_timer.start()

func _on_detection_zone_body_exited(body: Node2D):
	if body.is_in_group("player"):
		is_player_in_range = false
		shoot_timer.stop()
