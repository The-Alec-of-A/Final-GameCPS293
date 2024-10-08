extends Sprite2D

@onready var timer: Timer = $Timer

var rng = RandomNumberGenerator.new()
var images = ["res://assets/other/arrow down.png", "res://assets/other/arrow left.png",
 "res://assets/other/arrow right.png", "res://assets/other/arrow up.png"]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_random_arrow()
	visible = true
	timer.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_random_arrow():
	var rngIndex = rng.randi_range(0, 3)
	var arrowImage = Image.new()
	arrowImage.load(images[rngIndex])
	
	var texture = ImageTexture.new()
	texture.create_from_image(arrowImage)
	$".".texture = texture


func _on_timer_timeout() -> void:
	visible = false	# hide arrows when the timer finishes
