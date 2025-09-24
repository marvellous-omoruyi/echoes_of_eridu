# echoes_of_eridu/Scenes/Levels/level_scene.gd
# Polished by Alex "CodeWizard" Morgan, with Debugging

extends Node2D
@onready var enemiesHud = $CanvasLayer/Label2
@onready var enemiesHud2 = $CanvasLayer/Label4
@onready var player = $Player
@onready var hud = $HUD
@onready var fall_detector = $FallDetector
@onready var healthbar = $HealthBar
@onready var Timer_l = $TimerLost
@onready var node = $Node2D
@onready var node2d2 = $Node2D2
var is_game_over: bool = false
@onready var music_player = $AudioStreamPlayer
@onready var health
@onready var number
@onready var timer = $Timer
@onready var ui = $CanvasLayer2

func _ready():

	health = player.health
	var enemies2_ =str(len(get_tree().get_nodes_in_group("enemy")))
	print(enemies2_)
	enemiesHud2.text= enemies2_
	# Play the music as soon as the scene is ready
	music_player.play()
	music_player.volume_db = -10.0
	healthbar.init_health(health)
	number = node.level
	timer.start()
	ui.visible=true
	
	

func _process(delta: float):
	var enemies_ =str(len(get_tree().get_nodes_in_group("enemy")))
	print(enemies_)
	enemiesHud.text= enemies_
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
		get_tree().change_scene_to_file("res://Scenes/lost_ui.tscn")
		music_player.stop()   
func _on_timer_lost_timeout() -> void:
	
	music_player.stop()   
	get_tree().change_scene_to_file("res://Scenes/lost_ui.tscn")# Replace with function body.

func show_win_screen():
	if is_game_over:
		return
	is_game_over = true
	number+1
	
	get_tree().change_scene_to_file("res://Scenes/win_ui.gd")
	music_player.stop()   
func show_lose_screen():
	if is_game_over:
		return
	is_game_over = true
	Timer_l.start()
	
	


func _on_timer_timeout()       :

	ui.visible=false# Replace with function body.place with function body.
