extends CharacterBody2D

@export var speed: float = 1000.0
@export var jump_force: float = -700.0
@export var double_jump_force: float = -900.0
@export var gravity: float = 900.0
@export var dash_speed: float = 2500.0
@export var dash_duration: float = 0.5
@export var glowing_ball_scene: PackedScene
@export var health: int = 100

signal health_changed(new_health)

@onready var animated_sprite = $AnimatedSprite2D
@onready var hand_position = $HandPosition
@onready var collision_shape = $CollisionShape2D # Get a reference to the collision shape

var jump_count: int = 2
var can_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var is_dead: bool = false # New state to track if the player is dead

func _physics_process(delta: float) -> void:
	# If the player is dead, stop all other processing
	if is_dead:
		velocity.y += gravity * delta
		move_and_slide()
		return

	var vel = velocity

	if is_dashing:
		vel.y = 0
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	if not is_on_floor() and not is_dashing:
		vel.y += gravity * delta
	
	if is_on_floor():
		jump_count = 2
		can_dash = true

	var dir = Input.get_axis("ui_left", "ui_right")
	if not is_dashing:
		vel.x = dir * speed

	if Input.is_action_just_pressed("ui_sprint") and can_dash:
		is_dashing = true
		can_dash = false
		dash_timer = dash_duration
		vel.y = 0
		vel.x = Input.get_axis("ui_left", "ui_right") * dash_speed

	if Input.is_action_just_pressed("ui_accept") and jump_count > 0 and not is_dashing:
		if jump_count == 2:
			vel.y = jump_force
		elif jump_count == 1:
			vel.y = double_jump_force
		jump_count -= 1
	
	if Input.is_action_just_pressed("ui_attack") and not is_dashing:
		shoot_glowing_ball()
		
	update_animation(dir)
		
	velocity = vel
	move_and_slide()

func update_animation(dir):
	if is_dashing:
		animated_sprite.play("dash")
	elif animated_sprite.animation == "attack" and animated_sprite.is_playing():
		pass
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif dir != 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = dir < 0
	else:
		animated_sprite.play("idle")

func shoot_glowing_ball():
	var glowing_ball_instance = glowing_ball_scene.instantiate()
	
	var shoot_direction = Vector2.RIGHT
	if animated_sprite.flip_h:
		shoot_direction = Vector2.LEFT

	var spawn_position = hand_position.global_position
	if animated_sprite.flip_h:
		spawn_position.x = global_position.x - (hand_position.position.x)
	else:
		spawn_position.x = global_position.x + (hand_position.position.x)
		
	glowing_ball_instance.global_position = spawn_position
	glowing_ball_instance.direction = shoot_direction
	
	get_tree().get_root().add_child(glowing_ball_instance)
	
	animated_sprite.play("attack")

# --- MODIFIED DEATH LOGIC ---
func take_damage(amount: int):
	if is_dead:
		return

	health -= amount
	health_changed.emit(health) # Let the HUD know health has changed

	print("Player took ", amount, " damage! Current health: ", health)
	
	if health <= 0:
		is_dead = true
		animated_sprite.play("death")
		collision_shape.disabled = true
		
		

func _ready():
	health_changed.emit(health)

func _on_animated_sprite_2d_animation_finished():
	# When the death animation is finished, remove the player from the game
	if animated_sprite.animation == "death":
		queue_free()


func _on_health_changed(new_health: Variant) -> void:
	pass # Replace with function body.
