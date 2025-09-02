# echoes_of_eridu/Scenes/Levels/level_scene.gd
# Polished by Alex "CodeWizard" Morgan

extends Node2D

@onready var player = $player
@onready var hud = $HUD
# --- CODEWIZARD'S UPDATE ---
# Pointing to your specific UI scenes
@onready var win_ui = $win_ui
@onready var lost_ui = $lost_ui
@onready var fall_detector = $FallDetector

var is_game_over: bool = false

func _ready():
	# Connect player signals to the HUD
	player.health_changed.connect(hud._on_player_health_changed)
	
	# Connect player death and falling to our game over logic
	player.dead.connect(show_lose_screen)
	fall_detector.body_entered.connect(_on_fall_detector_body_entered)
	
	# --- CODEWIZARD'S UPDATE ---
	# Connect the button signals from BOTH UI scenes to our level logic
	win_ui.restart_pressed.connect(_on_restart_pressed)
	win_ui.menu_pressed.connect(_on_menu_pressed)
	lost_ui.restart_pressed.connect(_on_restart_pressed)
	lost_ui.menu_pressed.connect(_on_menu_pressed)

func _process(delta: float):
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
	# Show the win UI
	win_ui.show()
	get_tree().paused = true

func show_lose_screen():
	if is_game_over:
		return
	is_game_over = true
	# --- CODEWIZARD'S UPDATE ---
	# Show the lost UI
	lost_ui.show()
	get_tree().paused = true

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/HomeScreen.tscn")
