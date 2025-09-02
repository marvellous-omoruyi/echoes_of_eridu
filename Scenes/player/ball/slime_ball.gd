# In echoes_of_eridu/Scenes/player/ball/slime_ball.gd

extends Area2D

@export var speed: float = 2000
@export var damage: int = 10

var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float):
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.take_damage(damage)

	if not body.is_in_group("enemy"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# --- CODEWIZARD'S ADDITION ---
# This function is called when the Timer node finishes counting down.
func _on_timer_timeout():
	# Destroy the ball after its lifetime expires.
	queue_free()
