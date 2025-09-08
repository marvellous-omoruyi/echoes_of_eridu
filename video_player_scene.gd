extends Control

# This function is called automatically when the video finishes
func _on_video_stream_player_finished():
	# Replace this path with the actual path to your main menu or level scene
	get_tree().change_scene_to_file("res://Scenes/home_screen.tscn")
