extends Control


func _on_button_pressed(): # This is for your "Start Game" button
	# Make sure the path to your main level scene is correct!
	get_tree().change_scene_to_file("res://Scenes/Levels/LevelScene.tscn")

func _on_button_2_pressed(): # This is for your "Quit" button
	get_tree().quit()
