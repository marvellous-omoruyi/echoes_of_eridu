extends Control

@onready var music_player = $AudioStreamPlayer2D
func _ready():
	# Play the music as soon as the scene is ready
	music_player.play()
func _on_button_pressed(): # This is for your "Start Game" button
	# Make sure the path to your main level scene is correct!
	SceneLoader.load_scene("res://Scenes/Levels/LevelScene.tscn")
	music_player.stop()   

func _on_button_2_pressed(): # This is for your "Quit" button
	get_tree().quit()
