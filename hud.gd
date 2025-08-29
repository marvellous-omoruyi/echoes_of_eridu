extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var damage_bar = $damageBar
@onready var timer = $Timer

# This function updates the health bar's visual.
func update_health(current_health):
	health_bar.value = current_health

# This function is the SLOT that listens for the player's signal.
func _on_player_health_changed(new_health):
	update_health(new_health)
