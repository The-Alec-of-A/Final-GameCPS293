
extends Sprite2D

var rng = RandomNumberGenerator.new()
var images: Array = ["res://assets/other/arrow down.png",
 "res://assets/other/arrow up.png", "res://assets/other/arrow left.png",
 "res://assets/other/arrow right.png"]
var nums = ["1", "2", "3", "4"]
var arrowPoint: Array[String] = ["downArrow", "upArrow", "leftArrow", "rightArrow"]
var arrowOrder: Array[String] = ["", "", "", ""]
var correctCount: int = 0
var powerCharge: int = 0
var fullCharge: bool = false
var checkMarks: Array[Sprite2D] = []
var arrow2D: Array[Sprite2D] = []
var labelSet: Array[Label] = []

@onready var label1: Label = $Label
@onready var label2: Label = $Label2
@onready var label3: Label = $Label3
@onready var label4: Label = $Label4
@onready var player: CharacterBody2D = %Player
@onready var boss_area: Area2D = %bossArea
@onready var arrowsVisible: Timer = $arrowsVisible
@onready var arrowsPaused: Timer = $arrowsPaused
@onready var power_bar: TextureProgressBar = %"Power bar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if arrow2D.size() < 4:
		for i in range(nums.size()):
			
			var arrowTexture = Sprite2D.new()
			add_child(arrowTexture)
			arrow2D.append(arrowTexture)
			
			var markTexture = Sprite2D.new()
			markTexture.texture = preload("res://assets/other/checkmark.png")
			add_child(markTexture)
			checkMarks.append(markTexture)
			checkMarks[i].visible = false
			checkMarks[i].z_index = 2
			
			var arrowLabel = Label.new()
			add_child(arrowLabel)
			labelSet.append(arrowLabel)
			
		markFormat()

func update_image():
	
	nums.shuffle()
	print(nums)
	
	for i in range(arrow2D.size()):
		var rndIndex = rng.randi_range(0, arrowPoint.size() - 1)
		arrow2D[int(nums[i])-1].texture = load(images[rndIndex])
		labelSet[int(nums[i])-1].text = str(i+1)
		arrowOrder[i] = arrowPoint[rndIndex]
	
	markersAppear()
	arrowsVisible.start()

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
	
	arrow2D[0].position = Vector2(-504, -115)
	arrow2D[1].position = Vector2(-443, -115)
	arrow2D[2].position = Vector2(-504, -54)
	arrow2D[3].position = Vector2(-443, -54)
	
	labelSet[0].position = label1.position
	labelSet[1].position = label2.position
	labelSet[2].position = label3.position
	labelSet[3].position = label4.position
	
	for i in range(arrow2D.size()):
		arrow2D[i].texture = CompressedTexture2D.new()
		arrow2D[i].scale = Vector2(0.07, 0.07)

		checkMarks[i].position = Vector2(arrow2D[i].position.x, \
		arrow2D[i].position.y)
		checkMarks[i].scale = Vector2(0.09, 0.09)
		
func markersAppear():
	for i in range(arrow2D.size()):
		arrow2D[i].visible = true
		labelSet[i].visible = true

func markersDisappear():
	for i in range(arrow2D.size()):
		arrow2D[i].visible = false
		checkMarks[i].visible = false
		arrow2D[i].texture = null
		labelSet[i].visible = false
	
	correctCount = 0
