extends Area2D

@export var speed: float = 1500.0
@export var damage: int = 10
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT

func _ready():
	$AnimatedSprite2D.play("shoot")
	
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
		
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D):
	# Check if the body that was hit has a 'take_damage' function
	if body.has_method("take_damage"):
		# Call the function and pass the damage value
		body.take_damage(damage)
	
	# Destroy the glowing ball after it hits something
	queue_free()
