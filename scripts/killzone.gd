extends Area2D

@onready var timer: Timer = $Timer

var died: bool

func _on_body_entered(body):
	died = true
	timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	died = false
