# slime.gd
# Polished by Alex "CodeWizard" Morgan

extends CharacterBody2D

@export var speed: float = 150.0
@export var patrol_distance: float = 200.0
@export var health: int = 100
# --- CODEWIZARD'S FIX ---
# I've renamed this to be more specific to what it's shooting.
# Make sure to assign your slimeBall.tscn to this in the Godot Inspector!
@export var slime_ball_scene: PackedScene 
@export var contact_damage: int = 1

@onready var animated_sprite = $AnimatedSprite2D
@onready var shoot_timer = $ShootTimer
@onready var contact_damage_timer = $ContactDamageTimer

var direction: float = 1.0
var start_position_x: float
var is_player_in_range: bool = false
var is_attacking: bool = false
var original_modulate: Color
var player_in_contact = null
var is_preparing_attack: bool = false

func _ready():
	start_position_x = global_position.x
	shoot_timer.stop()
	original_modulate = animated_sprite.modulate

func _physics_process(delta: float):
	if is_attacking or is_preparing_attack:
		velocity.x = 0
		move_and_slide()
		return

	if is_player_in_range:
		velocity.x = 0
	else:
		patrol()
	
	update_animation()
	move_and_slide()

func patrol():
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
	var tween = get_tree().create_tween()
	animated_sprite.modulate = Color.WHITE
	tween.tween_property(animated_sprite, "modulate", original_modulate, 0.2)
	
	if health <= 0:
		queue_free()

func _on_shoot_timer_timeout():
	if is_player_in_range and not is_attacking and not is_preparing_attack:
		is_preparing_attack = true
		animated_sprite.play("attack_anticipation")

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack_anticipation":
		is_attacking = true
		is_preparing_attack = false
		animated_sprite.play("attack")
	elif animated_sprite.animation == "attack":
		shoot_slime_ball() # Changed from shoot_glowing_ball
		is_attacking = false

# --- CODEWIZARD'S FIX ---
# This function was un-nested from _on_animated_sprite_2d_animation_finished
# to fix a GDScript syntax error.
func shoot_slime_ball():
	if slime_ball_scene == null:
		return

	var slime_ball_instance = slime_ball_scene.instantiate()
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		is_attacking = false
		return
		
	var shoot_direction = (player.global_position - global_position).normalized()
	
	var spawn_offset = 60.0 
	var spawn_position = global_position + (shoot_direction * spawn_offset)
	
	slime_ball_instance.global_position = spawn_position
	# This assumes your slime_ball.gd has a 'direction' variable.
	slime_ball_instance.set("direction", shoot_direction) 

	get_tree().get_root().add_child(slime_ball_instance)

# --- Signal Connections ---
func _on_detection_zone_body_entered(body):
	if body.is_in_group("player"):
		is_player_in_range = true
		shoot_timer.start()

func _on_detection_zone_body_exited(body):
	if body.is_in_group("player"):
		is_player_in_range = false
		shoot_timer.stop()

func _on_damage_zone_body_entered(body):
	if body.is_in_group("player"):
		player_in_contact = body
		contact_damage_timer.start()
		if player_in_contact:
			player_in_contact.take_damage(contact_damage)

func _on_damage_zone_body_exited(body):
	if body == player_in_contact:
		player_in_contact = null
		contact_damage_timer.stop()

func _on_contact_damage_timer_timeout():
	if player_in_contact:
		player_in_contact.take_damage(contact_damage)
