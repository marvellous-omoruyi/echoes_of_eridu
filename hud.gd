extends CanvasLayer

@onready var health_bar = $HealthBar # The main health bar (top layer, green)
@onready var damage_bar = $DamageBar # The damage indicator (bottom layer, red)
@onready var damage_timer = $DamageTimer # The timer for the delay

# This function sets the initial state of both bars when the game starts.
func set_max_health(max_value):
	health_bar.max_value = max_value
	health_bar.value = max_value
	damage_bar.max_value = max_value
	damage_bar.value = max_value

# This function is called when the player takes damage.
func update_health(new_health):
	# 1. Instantly update the main health bar.
	health_bar.value = new_health
	
	# 2. Start the timer to delay the damage bar's update.
	damage_timer.start()

# This function is called when the DamageTimer finishes.
func _on_damage_timer_timeout():
	# 3. Create a smooth animation (a "Tween") to move the damage bar.
	var tween = get_tree().create_tween()
	# Animate the 'value' property of the damage_bar from its current value
	# down to the health_bar's new value over 0.5 seconds.
	tween.tween_property(damage_bar, "value", health_bar.value, 0.5).set_trans(Tween.TRANS_SINE)
