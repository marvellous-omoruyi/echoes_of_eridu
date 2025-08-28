extends Area2D

@export var speed: float = 800.0  # You can change this value in the Inspector
@export var damage: int = 10

var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float):
	global_position += direction * speed * delta

# This function is called when the ball hits something
func _on_body_entered(body: Node2D):
	# Check if the body it hit is the player
	if body.is_in_group("player"):
		body.take_damage(damage)

	# Destroy the ball after it hits anything (player, wall, etc.)
	# that isn't an enemy.
	if not body.is_in_group("enemy"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	# Clean up the ball if it goes off-screen
	queue_free()
