# echoes_of_eridu/Scenes/Levels/level_scene.gd
# Polished by Alex "CodeWizard" Morgan, with Debugging

extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var fall_detector = $FallDetector

var is_game_over: bool = false

func _process(delta: float):
	# --- CODEWIZARD'S FIX ---
	# This guard clause prevents the game from crashing during scene changes.
	# If the level is no longer in the main scene tree, we stop processing.
	if not is_inside_tree():
		return

	if $Player.has_dead and not is_game_over:
		show_lose_screen() # Call the function to handle game over logic

	if is_game_over:
		return
		
	# Win Condition: Check if there are no more enemies
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		show_win_screen()

func _on_fall_detector_body_entered(body: Node):
	if body.is_in_group("player"):
		show_lose_screen()

func show_win_screen():
	if is_game_over:
		return
	is_game_over = true
	get_tree().change_scene_to_file("res://Scenes/win_ui.tscn")

func show_lose_screen():
	if is_game_over:
		return
	is_game_over = true
	get_tree().change_scene_to_file("res://Scenes/lost_ui.tscn")
