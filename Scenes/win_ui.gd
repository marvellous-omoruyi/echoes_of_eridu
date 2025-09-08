# win_ui.gd
extends Control

signal restart_pressed
signal menu_pressed
@onready var music_player = $AudioStreamPlayer2D


func _ready():
	# --- CODEWIZARD'S FIX ---
	# The path must include the container node.
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)
	music_player.play()
func _on_restart_pressed():
	restart_pressed.emit()

func _on_menu_pressed():
	menu_pressed.emit()
