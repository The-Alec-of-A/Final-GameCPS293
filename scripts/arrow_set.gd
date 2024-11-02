extends Sprite2D

var rng = RandomNumberGenerator.new()
var images: Array = ["res://assets/other/arrow down.png",
 "res://assets/other/arrow up.png", "res://assets/other/arrow left.png",
 "res://assets/other/arrow right.png"]
var checkImageSource = "res://assets/other/checkmark.png"
var nums = ["1", "2", "3", "4"]
var arrowPoint: Array[String] = ["downArrow", "upArrow", "leftArrow", "rightArrow"]
var arrowOrder: Array[String] = ["", "", "", ""]
var arrowIndex = [0, 0, 0, 0]
var correctCount: int = 0
var powerCharge: int = 0
var fullCharge = false
var checkMarks: Array[Sprite2D]
var arrowRect: Array[TextureRect]

@onready var label_1: Label = $Label
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3
@onready var label_4: Label = $Label4
@onready var player: CharacterBody2D = %Player
@onready var boss_area: Area2D = %bossArea
@onready var arrowsVisible: Timer = $arrowsVisible
@onready var arrowsPaused: Timer = $arrowsPaused
@onready var power_bar: TextureProgressBar = %"Power bar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if arrowRect.size() < 4:
		for i in range(nums.size()):
			
			var arrowTexture = TextureRect.new()
			add_child(arrowTexture)
			arrowRect.append(arrowTexture)
			arrowRect[i].visible = false
			
			var markTexture = Sprite2D.new()
			markTexture.texture = load(checkImageSource)
			add_child(markTexture)
			checkMarks.append(markTexture)
			checkMarks[i].visible = false
			checkMarks[i].z_index = 2
			
		markFormat()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_image():
	nums.shuffle()
	labelStorage()
	
	for i in range(arrowRect.size()):
		var rndIndex = rng.randi_range(0, arrowPoint.size() - 1)
		arrowRect[int(nums[i])-1].texture = load(images[rndIndex])
		arrowOrder[i] = arrowPoint[rndIndex]
		
	markersAppear()
	arrowsVisible.start()

func labelStorage():
	label_1.text = nums[0]
	label_2.text = nums[1]
	label_3.text = nums[2]
	label_4.text = nums[3]

func arrowCheck(userInput: String):
	
	if userInput == arrowOrder[correctCount]:
		correctCount += 1
		checkMarks[int(nums[correctCount-1])-1].visible = true
	
	else:
		arrowsVisible.stop()
		markersDisappear()
		arrowsPaused.start()
	
	if correctCount == 4:
		powerCharge += 1
		power_bar.value += 25
		correctCount = 0
		
	if powerCharge == 4:
		fullCharge = true
		powerCharge = 0

func _on_arrows_visible_timeout() -> void:
	
	markersDisappear()
	arrowsPaused.start()

func _on_arrows_paused_timeout() -> void:
	if boss_area and !fullCharge:
		update_image()
		markersAppear()

func markFormat():
	var xOffset: int = 25
	var yOffset: int = 15
	
	arrowRect[0].position = Vector2(-522, -137)
	arrowRect[1].position = Vector2(-461, -137)
	arrowRect[2].position = Vector2(-522, -76)
	arrowRect[3].position = Vector2(-461, -76)
	
	for i in range(arrowRect.size()):
		arrowRect[i].size = Vector2(40, 40)
		arrowRect[i].texture = ImageTexture.new()
		arrowRect[i].expand_mode = TextureRect.EXPAND_FIT_WIDTH
		
		checkMarks[i].position = Vector2(arrowRect[i].position.x + xOffset, \
		arrowRect[i].position.y + yOffset)
		arrowRect[i].scale = Vector2(1, 1)
		checkMarks[i].scale = Vector2(0.1, 0.1)
		
		
func markersAppear():
	for i in range(arrowRect.size()):
		arrowRect[i].visible = true
		
	label_1.visible = true
	label_2.visible = true
	label_3.visible = true
	label_4.visible = true

func markersDisappear():
	for i in range(arrowRect.size()):
		arrowRect[i].visible = false
		checkMarks[i].visible = false
		arrowOrder[i] = "";
	
	label_1.visible = false
	label_2.visible = false
	label_3.visible = false
	label_4.visible = false	
	
	correctCount = 0
