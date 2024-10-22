extends Sprite2D

var rng = RandomNumberGenerator.new()
var rndIndex = [0, 0, 0, 0]
var images: Array = ["res://assets/other/arrow down.png",
 "res://assets/other/arrow up.png", "res://assets/other/arrow left.png",
 "res://assets/other/arrow right.png"]
#var checkImageSource = "res://assets/other/checkmark.png"
var nums = ["1", "2", "3", "4"]
var arrowPoint: Array[String] = ["down_arrow", "up_arrow", "left_arrow", "right_arrow"]
var arrowKey: Array[String] = ["", "", "", ""]
var arrowIndex = [0, 0, 0, 0]
var correctCount: int = 0
var powerCharge: int = 0
var fullCharge = false
var checkMarks: Array[Sprite2D] = []

@onready var texture_rect: TextureRect = $TextureRect
@onready var texture_rect_2: TextureRect = $TextureRect2
@onready var texture_rect_3: TextureRect = $TextureRect3
@onready var texture_rect_4: TextureRect = $TextureRect4
@onready var label_1: Label = $Label
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3
@onready var label_4: Label = $Label4
@onready var player: CharacterBody2D = %Player
@onready var boss_area: Area2D = %bossArea
@onready var arrowsVisible: Timer = $arrowsVisible
@onready var arrowsPaused: Timer = $arrowsPaused
@onready var power_bar: TextureProgressBar = $"../../../CanvasLayer/Power bar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_image():
			
	nums.shuffle()
	labelStorage()
	
	rndIndex[0] = rng.randi_range(0, arrowPoint.size() - 1)
	texture_rect.texture = load(images[rndIndex[0]])
	arrowKey[int(nums[0])-1] = arrowPoint[rndIndex[0]]
	
	rndIndex[1] = rng.randi_range(0, arrowPoint.size() - 1)
	texture_rect_2.texture = load(images[rndIndex[1]])
	arrowKey[int(nums[1])-1] = arrowPoint[rndIndex[1]]
	
	rndIndex[2] = rng.randi_range(0, arrowPoint.size() - 1)
	texture_rect_3.texture = load(images[rndIndex[2]])
	arrowKey[int(nums[2])-1] = arrowPoint[rndIndex[2]]

	rndIndex[3] = rng.randi_range(0, arrowPoint.size() - 1)
	texture_rect_4.texture = load(images[rndIndex[3]])
	arrowKey[int(nums[3])-1] = arrowPoint[rndIndex[3]]

	arrowsVisible.start()

func labelStorage():
	label_1.text = nums[0]
	label_2.text = nums[1]
	label_3.text = nums[2]
	label_4.text = nums[3]

func arrowCheck(userInput: Array[String]):
	
	if userInput[correctCount] == arrowKey[correctCount]:
		correctCount += 1
		
		if checkMarks.size() < 4:
			for i in range(nums.size()):
				var markTexture = Sprite2D.new()
#				markTexture.texture = load(checkImageSource)
				add_child(markTexture)
				checkMarks.append(markTexture)
				checkMarks[i].visible = false
#			checkMarkPos()
#		checkMarks[int(nums[correctCount-1]) - 1].visible = true
			
	else:
		correctCount = 0
	
	if correctCount == 4:
		powerCharge += 1
		power_bar.value += 25
		correctCount = 0
		
	if powerCharge == 4:
		fullCharge = true

func _on_arrows_visible_timeout() -> void:
	arrowsDisappear()
	
	for i in range(arrowPoint.size() - 1):
		arrowKey[i] = "";	
	arrowsPaused.start()

func _on_arrows_paused_timeout() -> void:
	if boss_area.entered == true:
		update_image()
	
		texture_rect.visible = true
		texture_rect_2.visible = true
		texture_rect_3.visible = true
		texture_rect_4.visible = true
		label_1.visible = true
		label_2.visible = true
		label_3.visible = true
		label_4.visible = true

func arrowsDisappear():
	texture_rect.visible = false
	texture_rect_2.visible = false
	texture_rect_3.visible = false
	texture_rect_4.visible = false
	label_1.visible = false
	label_2.visible = false
	label_3.visible = false
	label_4.visible = false
	
func checkMarkPos():
	#checkMarks[0].position = Vector2(texture_rect.position.x, texture_rect.position.y)
	#checkMarks[1].position = Vector2(texture_rect_2.position.x, texture_rect_2.position.y)
	#checkMarks[2].position = Vector2(texture_rect_3.position.x, texture_rect_3.position.y)
	#checkMarks[3].position = Vector2(texture_rect_4.position.x, texture_rect_4.position.y)
	pass
