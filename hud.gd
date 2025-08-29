extends CanvasLayer

@onready var health_bar = $HealthBar

# This function will be called by the player to update the health bar's value.
func update_health(current_health):
	health_bar.value = current_health
	
func _on_player_health_changed(new_health):
	update_health(new_health)
