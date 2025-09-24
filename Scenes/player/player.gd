# player.gd
# Polished by Alex "CodeWizard" Morgan

extends CharacterBody2D


# --- Player Attributes ---
@export var speed: float = 1000.0
@export var jump_force: float = -700.0
@export var double_jump_force: float = -900.0
@export var gravity: float = 900.0
@export var dash_speed: float = 2500.0
@export var dash_duration: float = 0.5
@export var health: int = 100
@export var camera: Camera2D
@export var glowing_ball_scene: PackedScene
@export var has_dead = false
@onready var music_player = $AudioStreamPlayer2D

# --- NEW: Constant for hand position ---
const HAND_POS_X: float = 284.0 # Original X position from player.tscn

# --- Signals (The Player's Voice) ---
signal health_changed(new_health)
signal dead

# --- Node References ---
@onready var animated_sprite = $AnimatedSprite2D
@onready var hand_position = $HandPosition
@onready var coyote_timer = $CoyoteTimer
@onready var standing_collision = $StandingCollision
@onready var ducking_collision = $DuckingCollision
@onready var healthbar = $CanvasLayer/HealthBar

# --- State Variables ---
var jump_count: int = 2
var can_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var is_dead: bool = false
var original_modulate: Color
var was_on_floor: bool = true
var is_ducking: bool = false

func _ready():
	health_changed.emit(health)
	original_modulate = animated_sprite.modulate
	standing_collision.disabled = false
	ducking_collision.disabled = true
	healthbar.init_health(health)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity.y += gravity * delta
		move_and_slide()
		return

	var is_crouch_pressed = Input.is_action_pressed("crouch") and is_on_floor()

	if is_crouch_pressed and not is_ducking:
		is_ducking = true
		standing_collision.disabled = true
		ducking_collision.disabled = false
	elif not is_crouch_pressed and is_ducking:
		is_ducking = false
		standing_collision.disabled = false
		ducking_collision.disabled = true

	var vel = velocity

	# --- CODEWIZARD'S SPRINT FIX ---
	# We handle the dash velocity here. This ensures the player moves at dash_speed
	# for the entire duration of the dash.
	if is_dashing:
		vel.y = 0
		# The direction is determined once at the start of the dash
		vel.x = sign(velocity.x) * dash_speed 
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			vel.x = 0 # Stop the player after dashing to avoid sliding
	else:
		# Gravity
		if not is_on_floor():
			vel.y += gravity * delta

		# Movement (Disabled while ducking)
		var dir = Input.get_axis("ui_left", "ui_right")
		if not is_ducking:
			vel.x = dir * speed
		else:
			vel.x = move_toward(vel.x, 0, speed)

	# Floor Reset & Coyote Time
	if is_on_floor():
		jump_count = 2
		can_dash = true
	else:
		if was_on_floor and not is_dashing:
			coyote_timer.start()

	# --- Player Actions (Input Handling) ---
	if Input.is_action_just_pressed("ui_sprint") and can_dash and not is_ducking:
		is_dashing = true
		can_dash = false
		dash_timer = dash_duration
		# --- CODEWIZARD'S SPRINT FIX ---
		# Set initial velocity for the dash
		var dash_direction = Input.get_axis("ui_left", "ui_right")
		if dash_direction != 0:
			velocity.x = dash_direction * dash_speed
		else:
			# If no direction is pressed, dash in the direction the player is facing
			velocity.x = (1 if not animated_sprite.flip_h else -1) * dash_speed


	if Input.is_action_just_pressed("ui_accept") and (jump_count > 0 or not coyote_timer.is_stopped()) and not is_dashing and not is_ducking:
		coyote_timer.stop()
		if jump_count >= 2:
			vel.y = jump_force
			jump_count = 1
		else:
			vel.y = double_jump_force
			jump_count = 0

	if Input.is_action_just_pressed("ui_attack") and not is_dashing and not is_ducking:
		shoot_glowing_ball()

	update_animation(Input.get_axis("ui_left", "ui_right"))

	velocity = vel
	move_and_slide()

	was_on_floor = is_on_floor()

# --- MODIFIED: This function is completely updated ---
func update_animation(dir: float):
	# 1. Update facing direction based on input (works on ground and in air)
	if dir != 0:
		animated_sprite.flip_h = dir < 0

	# 2. Update hand position to match the character's direction
	# This ensures the glowing ball always spawns from the correct side.
	if animated_sprite.flip_h: # Facing Left
		hand_position.position.x = -HAND_POS_X
	else: # Facing Right
		hand_position.position.x = HAND_POS_X

	# 3. Set the correct animation based on the player's state
	if is_ducking:
		animated_sprite.play("duck")
	elif is_dashing:
		animated_sprite.play("dash")
	elif animated_sprite.animation == "attack" and animated_sprite.is_playing():
		pass # Allow attack animation to finish playing
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif dir != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

func shoot_glowing_ball():
	var glowing_ball_instance = glowing_ball_scene.instantiate()
	var shoot_direction = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
	glowing_ball_instance.global_position = hand_position.global_position
	glowing_ball_instance.direction = shoot_direction
	get_tree().get_root().add_child(glowing_ball_instance)
	animated_sprite.play("attack")
	music_player.play()

func take_damage(amount: int):
	if is_dead:
		return
	health -= amount
	
	health_changed.emit(health)
	add_damage_feedback()
	if health <= 0 and not is_dead:
		has_dead = true
		is_dead = true
		animated_sprite.play("death")
		# --- CODEWIZARD'S FIX ---
		# Defer disabling shapes to avoid physics errors.
		standing_collision.set_deferred("disabled", false)
		ducking_collision.set_deferred("disabled", true)
		dead.emit()
	healthbar.health= health	
	
func add_damage_feedback():
	if camera:
		var tween = get_tree().create_tween()
		tween.tween_method(shake_camera, 10.0, 0.0, 0.2)

	var flash_tween = get_tree().create_tween()
	animated_sprite.modulate = Color(1, 0.2, 0.2)
	flash_tween.tween_property(animated_sprite, "modulate", original_modulate, 0.3)

func shake_camera(strength: float):
	if camera:
		camera.offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "death":
		pass
