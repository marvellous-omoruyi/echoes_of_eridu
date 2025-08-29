extends Node2D

# The path must match the node's name exactly, including capitalization.
@onready var player = $Player
@onready var hud = $HUD

func _ready():
	# Now that the script can find "Player", this code will execute correctly.
	hud.set_max_health(player.health)
	player.health_changed.connect(hud.update_health)
