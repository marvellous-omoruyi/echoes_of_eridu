extends CharacterBody2D

@export var speed: float = 1000.0
@export var jump_force: float = -700.0
@export var double_jump_force: float = -900.0
@export var gravity: float = 900.0
@export var dash_speed: float = 1800.0
@export var dash_duration: float = 0.15

@onready var animated_sprite = $AnimatedSprite2D

var jump_count: int = 2
var can_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0

func _physics_process(delta: float) -> void:
	var vel = velocity

	if is_dashing:
		vel.y = 0
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	# Apply gravity
	if not is_on_floor() and not is_dashing:
		vel.y += gravity * delta
	
	# Reset jump and dash count if the character is on the floor
	if is_on_floor():
		jump_count = 2
		can_dash = true

	# Horizontal movement
	var dir = Input.get_axis("ui_left", "ui_right")
	if not is_dashing:
		vel.x = dir * speed

	# Dash Logic
	if Input.is_action_just_pressed("ui_sprint") and can_dash:
		is_dashing = true
		can_dash = false
		dash_timer = dash_duration
		vel.y = 0 # Prevent gravity from affecting the dash
		vel.x = Input.get_axis("ui_left", "ui_right") * dash_speed

	# Jump Logic
	if Input.is_action_just_pressed("ui_accept") and jump_count > 0 and not is_dashing:
		if jump_count == 2:
			vel.y = jump_force
		elif jump_count == 1:
			vel.y = double_jump_force
		
		jump_count -= 1

	# Animation Logic
	if is_dashing:
		animated_sprite.play("dash")
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif dir != 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = dir < 0
	else:
		animated_sprite.play("idle")
		
	velocity = vel
	move_and_slide()
