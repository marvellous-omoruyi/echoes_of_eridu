extends CanvasLayer
@onready var node = $Node2D
@onready var number = str(node.level) 
@onready var label = $Label
func _ready():
	
	label.text= number
