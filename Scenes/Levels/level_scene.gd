extends Node2D

# This is the corrected path to your player node.
@onready var player = $TileMap/player
@onready var hud = $HUD

func _ready():
	# Now that the script can find the player, this code will work.
	hud.set_max_health(player.health)
	player.health_changed.connect(hud.update_health)
