extends CharacterBody2D

@export var speed: float = 150.0
@export var patrol_distance: float = 200.0
@export var health: int = 100

@onready var animated_sprite = $AnimatedSprite2D

var direction: float = 1.0 # 1 for right, -1 for left
var start_position_x: float

func _ready():
	start_position_x = global_position.x
	# This check ensures the script finds the AnimatedSprite2D node.
	if animated_sprite == null:
		push_error("AnimatedSprite2D node not found. Please name the node 'AnimatedSprite2D'.")
		set_process(false)

func _physics_process(delta: float) -> void:
	# Change direction when the enemy reaches the patrol limit
	if direction == 1.0 and global_position.x >= start_position_x + patrol_distance:
		direction = -1.0
	elif direction == -1.0 and global_position.x <= start_position_x - patrol_distance:
		direction = 1.0

	# Apply movement
	velocity.x = direction * speed
	
	# Animation Logic
	if velocity.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")
	
	move_and_slide()

# This function is called by the Glowing Ball
func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took ", amount, " damage! Current health: ", health)
	
	if health <= 0:
		queue_free()
