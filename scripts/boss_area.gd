extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	timer.start()
	body.get_node("arrow_set")


func _on_timer_timeout() -> void:
	pass # Replace with function body.
