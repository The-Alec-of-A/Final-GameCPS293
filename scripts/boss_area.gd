extends Area2D

var arrowSetInstance
var playerInstance
var entered = false
@onready var killzone: Area2D = %killzone
@onready var boss_health_bar: TextureProgressBar = %"boss health bar"

func _on_body_entered(_body: Node2D) -> void:
	arrowSetInstance = get_node("Player/arrowSet")
	playerInstance = get_node("Player")
	boss_health_bar.visible = true
	
	if !arrowSetInstance.fullCharge:
		playerInstance.count = 0
		arrowSetInstance.correctCount = 0
		arrowSetInstance.update_image()
		entered = true
		
func _on_body_exited(_body: Node2D) -> void:
	entered = false
	arrowSetInstance.markersDisappear()
	arrowSetInstance.arrowsVisible.stop()
	arrowSetInstance.arrowsPaused.stop()
