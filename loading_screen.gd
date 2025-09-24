# LoadingScreen.gd
extends CanvasLayer

@onready var progress_bar = $ProgressBar
@onready var label = $Label




# This function will be called from our global loader to update the UI.
func set_progress(percentage: int):
	progress_bar.value = percentage
	label.text = "Loading... %d%%" % percentage
	   
