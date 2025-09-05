# echoes_of_eridu/Scenes/Levels/level_scene.gd
# Polished by Alex "CodeWizard" Morgan, with Debugging

extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var fall_detector = $FallDetector

var is_game_over: bool = false

var playerCon = playerglob.has_dead 



func _process(delta: float):
	if $Player.has_dead:
		get_tree().change_scene_to_file("res://Scenes/lost_ui.tscn")
	if is_game_over:
		return
		
	# Win Condition: Check if there are no more enemies
	var enemies = get_tree().get_nodes_in_group("enemy")
	# --- CODEWIZARD'S DEBUG ---
	# This will constantly print the number of enemies remaining.
	# If this number doesn't go down when you kill an enemy, they aren't in the "enemy" group.
	# print("Enemies remaining: ", enemies.size()) 
	
	if enemies.is_empty():
		show_win_screen()

func _on_fall_detector_body_entered(body: Node):
	# --- CODEWIZARD'S DEBUG ---
	print("FallDetector entered by: ", body.name)
	if body.is_in_group("player"):
		show_lose_screen()

func show_win_screen():
	if is_game_over:
		return
	is_game_over = true
	# --- CODEWIZARD'S DEBUG ---
	print("WIN CONDITION MET! Changing to win_ui.tscn")
	get_tree().change_scene_to_file("res://Scenes/win_ui.tscn")

func show_lose_screen():
	if is_game_over:
		return
	is_game_over = true
	# --- CODEWIZARD'S DEBUG ---
	print("LOSE CONDITION MET! Changing to lost_ui.tscn")
	get_tree().change_scene_to_file("res://Scenes/lost_ui.tscn")
	
