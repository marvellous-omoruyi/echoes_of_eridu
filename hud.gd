extends CanvasLayer

@onready var health_bar = $HealthBar # The top, green health bar
@onready var damage_bar = $DamageBar # The bottom, red damage bar
@onready var damage_timer = $DamageTimer # The timer for the delay

# This sets up both bars when the game starts.
func set_max_health(max_value):
	health_bar.max_value = max_value
	health_bar.value = max_value
	damage_bar.max_value = max_value
	damage_bar.value = max_value

# This is called when the player takes damage.
func update_health(new_health):
	# Instantly drop the main health bar's value.
	health_bar.value = new_health
	
	# Start the timer to delay the red bar's update.
	damage_timer.start()

# This function runs AFTER the timer finishes.
func _on_damage_timer_timeout():
	# Create a smooth animation to make the red bar "catch up"
	# to the green bar over 0.5 seconds.
	var tween = get_tree().create_tween()
	tween.tween_property(damage_bar, "value", health_bar.value, 0.5).set_trans(Tween.TRANS_SINE)

func _on_timer_timeout() -> void:
	pass # Replace with function body.
