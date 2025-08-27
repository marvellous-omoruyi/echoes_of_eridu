extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 500.0

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(10)
	
	# The projectile should be destroyed when it hits any physics body
	# to prevent it from continuing through walls.
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	# This is a good practice to clean up projectiles that go off-screen.
	queue_free()
