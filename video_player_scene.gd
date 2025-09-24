extends Control

# This function is called automatically when the video finishes
func _on_video_stream_player_finished():
	# Replace this path with the actual path to your main menu or level scene
	SceneLoader.load_scene("res://Scenes/home_screen.tscn")
func _on_button_pressed(): # This is for your "Start Game" button
	# Make sure the path to your main level scene is correct!
	SceneLoader.load_scene("res://Scenes/home_screen.tscn")
