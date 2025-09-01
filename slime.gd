# slime.gd
# Polished by Maya Rivera, The Immersion Architect

extends CharacterBody2D

@export var speed: float = 150.0
@export var patrol_distance: float = 200.0
@export var health: int = 100
@export var glowing_ball_scene: PackedScene
@export var contact_damage: int = 1 # Damage dealt each timer tick.

@onready var animated_sprite = $AnimatedSprite2D
@onready var shoot_timer = $ShootTimer
@onready var contact_damage_timer = $ContactDamageTimer # Get the new timer


var direction: float = 1.0
var start_position_x: float
var is_player_in_range: bool = false
var is_attacking: bool = false
var original_modulate: Color # MAYA'S ADDITION: For the damage flash
var player_in_contact = null # Tracks if the player is touching the slime

# MAYA'S ADDITION: This new state makes the slime's attack readable for the player.
# A good enemy always communicates its intent.
var is_preparing_attack: bool = false

func _ready():
	start_position_x = global_position.x
	shoot_timer.stop()
	original_modulate = animated_sprite.modulate # MAYA'S ADDITION: Store the slime's normal color.

func _physics_process(delta: float):
	# If the slime is attacking or preparing to attack, it should not move.
	# This holds the slime in place, making its actions clearer to the player.
	if is_attacking or is_preparing_attack:
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

func _on_damage_zone_body_entered(body):
	# When the player enters our damage zone, we store a reference to them
	# and start the damage timer.
	if body.is_in_group("player"):
		player_in_contact = body
		contact_damage_timer.start()
		# Deal one tick of damage instantly for immediate feedback.
		if player_in_contact:
			player_in_contact.take_damage(contact_damage)

func _on_damage_zone_body_exited(body):
	# When the player leaves, we stop the timer and clear the reference.
	if body == player_in_contact:
		player_in_contact = null
		contact_damage_timer.stop()

func _on_contact_damage_timer_timeout():
	# Every time the timer ticks, if the player is still in contact, deal damage.
	if player_in_contact:
		player_in_contact.take_damage(contact_damage)

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
	
	# MAYA'S ADDITION: Add a visual flash to give the player satisfying feedback.
	# The player needs to feel the impact of their attack.
	var tween = get_tree().create_tween()
	animated_sprite.modulate = Color.WHITE # Flash white
	tween.tween_property(animated_sprite, "modulate", original_modulate, 0.2)
	
	if health <= 0:
		queue_free()

# This function now starts the "attack_anticipation" animation.
# This is the "tell" that gives the player a moment to react.
func _on_shoot_timer_timeout():
	if is_player_in_range and not is_attacking and not is_preparing_attack:
		is_preparing_attack = true
		animated_sprite.play("attack_anticipation") # You'll need to create this animation

func _on_animated_sprite_2d_animation_finished():
	# When the "tell" animation is done, play the actual attack.
	if animated_sprite.animation == "attack_anticipation":
		is_attacking = true
		is_preparing_attack = false
		animated_sprite.play("attack")
	# When the attack animation finishes, shoot the projectile.
	elif animated_sprite.animation == "attack":
		shoot_glowing_ball()
		is_attacking = false # Reset the state so the slime can patrol again.

# This function was un-nested to fix the GDScript syntax error.
func shoot_glowing_ball():
	if glowing_ball_scene == null:
		return

	var glowing_ball_instance = glowing_ball_scene.instantiate()
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		is_attacking = false
		return
		
	var shoot_direction = (player.global_position - global_position).normalized()
	
	var spawn_offset = 60.0 
	var spawn_position = global_position + (shoot_direction * spawn_offset)
	
	glowing_ball_instance.global_position = spawn_position
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
