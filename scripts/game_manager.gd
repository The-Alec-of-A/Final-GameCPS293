extends Node

@onready var arrow_set: Sprite2D = %arrowSet

func _ready():
	arrow_set.visible = true

func _on_timer_timeout() -> void:
	arrow_set.visible = false	# hide arrows when the timer finishes
	
