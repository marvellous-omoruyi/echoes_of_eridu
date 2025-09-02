# echoes_of_eridu/Scenes/Levels/level_scene.gd
# Polished by Alex "CodeWizard" Morgan

extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var fall_detector = $FallDetector

var is_game_over: bool = false

func _ready():
	# The HUD still needs to know about the player's health
	player.health_changed.connect(hud._on_player_health_changed)
	
	# Connect player death and falling to our game over logic
	player.dead.connect(show_lose_screen)
	fall_detector.body_entered.connect(_on_fall_detector_body_entered)

func _process(delta: float):
	# Don't check for a win if the game is already over
	if is_game_over:
		return
		
	# Win Condition: Check if there are no more enemies
	if get_tree().get_nodes_in_group("enemy").is_empty():
		show_win_screen()

func _on_fall_detector_body_entered(body: Node):
	if body.is_in_group("player"):
		show_lose_screen()

func show_win_screen():
	if is_game_over:
		return
	is_game_over = true
	# --- CODEWIZARD'S UPDATE ---
	# Switch to the win scene
	get_tree().change_scene_to_file("res://Scenes/win_ui.tscn")

func show_lose_screen():
	if is_game_over:
		return
	is_game_over = true
	# --- CODEWIZARD'S UPDATE ---
	# Switch to the lost scene
	get_tree().change_scene_to_file("res://Scenes/lost_ui.tscn")
