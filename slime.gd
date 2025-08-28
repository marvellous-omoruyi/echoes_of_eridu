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
var is_attacking: bool = false

func _ready():
	start_position_x = global_position.x
	shoot_timer.stop()

func _physics_process(delta: float):
	# If the slime is in the middle of an attack animation, it should not move or patrol.
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	# If the player is in range, the slime stops. Otherwise, it patrols.
	if is_player_in_range:
		velocity.x = 0
	else:
		patrol()
	
	update_animation()
	move_and_slide()

func patrol():
	# Simple patrol logic
	if not is_on_floor():
		return
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

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()

func _on_shoot_timer_timeout():
	# This function starts the attack sequence if the player is in range and we aren't already attacking.
	if is_player_in_range and not is_attacking:
		is_attacking = true
		animated_sprite.play("attack")

func _on_animated_sprite_2d_animation_finished():
	# This function is called when any animation finishes.
	# We only care about when the "attack" animation finishes.
	if animated_sprite.animation == "attack":
		shoot_glowing_ball()
		is_attacking = false # Reset the state so the slime can patrol again.

func shoot_glowing_ball():
	# Failsafe check to make sure the projectile scene is assigned in the editor.
	if glowing_ball_scene == null:
		print("ERROR: Glowing Ball Scene is not assigned in the Inspector!")
		return

	var glowing_ball_instance = glowing_ball_scene.instantiate()
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		is_attacking = false # Failsafe in case the player is destroyed
		return
		
	# --- HORIZONTAL SHOOTING LOGIC ---
	# 1. Get the raw direction vector to the player.
	var shoot_direction = player.global_position - global_position
	# 2. Erase the vertical component to make the shot horizontal.
	shoot_direction.y = 0
	# 3. Normalize the vector to get a pure direction without distance information.
	shoot_direction = shoot_direction.normalized()
	# --- END OF LOGIC ---

	glowing_ball_instance.global_position = global_position
	
	# Set the "direction" variable on the projectile's own script.
	glowing_ball_instance.set("direction", shoot_direction)

	get_tree().get_root().add_child(glowing_ball_instance)

# --- Signal Connections ---

func _on_detection_zone_body_entered(body):
	if body.is_in_group("player"):
		is_player_in_range = true
		shoot_timer.start()

func _on_detection_zone_body_exited(body):
	if body.is_in_group("player"):
		is_player_in_range = false
		shoot_timer.stop()
