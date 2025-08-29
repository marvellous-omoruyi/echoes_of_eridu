extends Node2D

# This is the corrected path. Your player is inside the "TileMap" node.
@onready var player = $TileMap/player
@onready var hud = $HUD

func _ready():
	# Set the initial health on the HUD when the level loads
	hud.set_max_health(player.health)
	
	# Connect the player's health_changed signal to the HUD's update_health function
	player.health_changed.connect(hud.update_health)
