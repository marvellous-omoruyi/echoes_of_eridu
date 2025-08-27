extends CharacterBody2D

@export var speed: float = 150.0
@export var patrol_distance: float = 200.0
@export var health: int = 100
@export var glowing_ball_scene: PackedScene
@export var melee_damage: int = 25
@export var melee_attack_cooldown: float = 1.5

# We need to get a reference to the nodes we'll add in the editor.
@onready var animated_sprite = $AnimatedSprite2D
@onready var shoot_timer = $ShootTimer
@onready var melee_cooldown_timer = $MeleeCooldownTimer

var direction: float = 1.0
var start_position_x: float
var is_player_in_range: bool = false
var is_player_in_melee_range: bool = false
var can_melee_attack: bool = true
var is_attacking: bool = false

func _ready():
	start_position_x = global_position.x
	# This is a good check to make sure your scene is set up correctly.
	if animated_sprite == null:
		push_error("AnimatedSprite2D node not found. Please name the node 'AnimatedSprite2D'.")
		set_process(false)
	
	shoot_timer.stop()

func _physics_process(delta: float) -> void:
	# If we're in an attack animation, we stop moving.
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return
	
	# Melee attack gets priority. If the player is close, we melee.
	if is_player_in_melee_range and can_melee_attack:
		melee_attack()
		return

	# If player isn't in range for any attack, we just patrol.
	if not is_player_in_range:
		patrol()
	else:
		# If player is in range, but not melee, we stop to shoot.
		velocity.x = 0

	animated_sprite.flip_h = get_player_direction() < 0
	
	if velocity.x != 0 and not is_attacking:
		animated_sprite.play("walk")
	elif not is_attacking:
		animated_sprite.play("idle")
	
	move_and_slide()

func patrol():
	# Change direction when the enemy reaches the patrol limit
	if direction == 1.0 and global_position.x >= start_position_x + patrol_distance:
		direction = -1.0
	elif direction == -1.0 and global_position.x <= start_position_x - patrol_distance:
		direction = 1.0
	velocity.x = direction * speed

func get_player_direction() -> float:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		return (player.global_position.x - global_position.x)
	return 0.0

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took ", amount, " damage! Current health: ", health)
	
	if health <= 0:
		queue_free()

func _on_shoot_timer_timeout():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Only shoot if the player is in the wider range and not close enough for melee.
	if is_player_in_range and not is_player_in_melee_range and not is_attacking:
		is_attacking = true
		var glowing_ball_instance = glowing_ball_scene.instantiate()
		var shoot_direction = (player.global_position - global_position).normalized()
	
		glowing_ball_instance.global_position = global_position
		glowing_ball_instance.direction = shoot_direction
	
		get_tree().get_root().add_child(glowing_ball_instance)
		animated_sprite.play("attack")
	
func melee_attack():
	is_attacking = true
	can_melee_attack = false
	animated_sprite.play("attack") # You can rename this to "melee_attack" if you have a separate animation
	
	# Check for bodies in the melee area to damage them
	var bodies = $MeleeRange.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			body.take_damage(melee_damage)
			# We only want to hit the player once per attack
			break
			
	melee_cooldown_timer.start(melee_attack_cooldown)

# This function is called when the attack animation finishes playing.
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack": # Or "melee_attack"
		is_attacking = false

# This function resets our ability to use the melee attack.
func _on_melee_cooldown_timer_timeout():
	can_melee_attack = true

# --- Signal Connections ---

func _on_detection_zone_body_entered(body: Node2D):
	if body.is_in_group("player"):
		is_player_in_range = true
		shoot_timer.start()

func _on_detection_zone_body_exited(body: Node2D):
	if body.is_in_group("player"):
		is_player_in_range = false
		shoot_timer.stop()

func _on_melee_range_body_entered(body: Node2D):
	if body.is_in_group("player"):
		is_player_in_melee_range = true

func _on_melee_range_body_exited(body: Node2D):
	if body.is_in_group("player"):
		is_player_in_melee_range = false
