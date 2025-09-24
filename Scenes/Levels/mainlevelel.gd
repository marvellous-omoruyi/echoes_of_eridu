extends Node2D

@onready var ui = $CanvasLayer
@onready var timer = $Timer

func _ready():
	timer.start()
	ui.visible=true

func _on_timer_timeout() -> void:
	ui.visible=false# Replace with function body.
