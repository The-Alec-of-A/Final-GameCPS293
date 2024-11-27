extends Area2D

@onready var timer: Timer = $Timer
@onready var arrow_set: Sprite2D = %arrowSet
@onready var player: CharacterBody2D = %Player

var died: bool

func _on_body_entered(body: Node2D):
	died = true
	arrow_set.correctCount = 0
	player.count = 0
	timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	died = false
	
