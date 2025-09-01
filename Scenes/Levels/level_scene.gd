# level_scene.gd
# The "Director" script for this level.
# Written by Maya Rivera, The Immersion Architect

extends Node2D

# Drag your Player node from the Scene tree here in the Inspector.
@export var player: Node2D

func _ready():
	# We must ensure the player exists before we try to connect to it.
	if player:
		# We're telling this script: "Listen for the 'dead' signal from the player.
		# When you hear it, call the _on_player_dead function."
		player.dead.connect(_on_player_dead)

# This function is the heart of our game loop. It's called when the player dies.
func _on_player_dead():
	# Polish Principle: Don't rush the player. Let the death animation play out.
	# We'll wait for 2 seconds to give the moment impact before restarting.
	# This respects the player's failure and makes the experience feel less abrupt.
	await get_tree().create_timer(2.0).timeout
	
	# After the pause, reload the entire level scene to restart.
	get_tree().reload_current_scene()
