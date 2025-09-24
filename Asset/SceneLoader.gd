# SceneLoader.gd
extends Node

# The path to the loading screen scene you just created.
const LOADING_SCREEN_PATH = "res://loading_screen.tscn"

var loading_screen_instance
var next_scene_path: String
var progress = []

func _ready():
	# Create an instance of the loading screen but don't show it yet.
	var packed_loading_screen = load("res://LoadingScreen.tscn" )
	loading_screen_instance = packed_loading_screen.instantiate()
	set_process(false) # We'll turn this on only when loading.

# This is the main function you'll call from anywhere to change scenes.
func load_scene(path: String):
	# Show the loading screen.
	get_tree().root.add_child(loading_screen_instance)
	
	# Store the path for the _process function to use.
	next_scene_path = path
	
	# Start loading the new scene in a background thread.
	ResourceLoader.load_threaded_request(path)
	
	# Start the _process function to check for loading progress.
	set_process(true)
	
func _process(_delta):
	# Check the status of the background loading thread.
	var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		# Loading is in progress, so update the progress bar.
		# The progress array's first element is a value from 0.0 to 1.0.
		var percentage = int(progress[0] * 100)
		loading_screen_instance.set_progress(percentage)
	
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		# Loading is complete!
		set_process(false) # Stop checking for progress.
		
		# Get the fully loaded scene resource.
		var new_scene = ResourceLoader.load_threaded_get(next_scene_path)
		
		# VERY IMPORTANT: Remove the loading screen instance before changing scenes.
		get_tree().root.remove_child(loading_screen_instance)
		
		# Finally, change to the new scene.
		get_tree().change_scene_to_packed(new_scene)
		
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		# Handle the case where the scene failed to load.
		print("ERROR: Failed to load scene: %s" % next_scene_path)
		set_process(false)
