extends Area2D

var arrowSetInstance
var playerInstance
var entered = false
@onready var killzone: Area2D = %killzone

func _on_body_entered(body: Node2D) -> void:
	arrowSetInstance = get_node("Player/arrowSet")
	playerInstance = get_node("Player")
	
	if !arrowSetInstance.fullCharge:
		playerInstance.count = 0
		arrowSetInstance.correctCount = 0
		arrowSetInstance.update_image()
		entered = true
		
func _on_body_exited(body: Node2D) -> void:
	entered = false
	arrowSetInstance.markersDisappear()
	arrowSetInstance.arrowsVisible.stop()
	arrowSetInstance.arrowsPaused.stop()
