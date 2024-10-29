extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var boss_area: Area2D = %bossArea
@onready var arrow_set: Sprite2D = $arrowSet
@onready var punchDelay: Timer = $punchDelay
@onready var texture_rect: TextureRect = $arrowSet/TextureRect
@onready var multiDelay: Timer = $multiDelay
@onready var arrowsPaused: Timer = $arrowSet/arrowsPaused
@onready var killzone: Area2D = %killzone

var inputSeq: Array[String] = ["", "", "", ""]
var playerOffset: int = 21
var multi_isplaying: bool = false
var count = 0

const SPEED = 300.0
const JUMP_VELOCITY = -750.0
const GRAVITY = 2200.0
const FALL_GRAVITY = 2400.0

func _ready() -> void:
	arrow_set = get_node("arrowSet")

func gravity(velocity: Vector2):
	if velocity.y < 0:
		return GRAVITY
	return FALL_GRAVITY

func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity(velocity) * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("jump") and velocity.y < -420:
		velocity.y = JUMP_VELOCITY / 4
	
	
	var direction = Input.get_axis("move_left", "move_right")
		
	if killzone.died:
		Input.action_release("move_left")
		Input.action_release("move_right")
		
	if boss_area.entered and arrowsPaused.is_stopped() and (Input.is_action_just_pressed( \
	"down_arrow") or Input.is_action_just_pressed("up_arrow") or \
	Input.is_action_just_pressed("left_arrow") or Input \
	.is_action_just_pressed("right_arrow")):
		check_input()
	# Get the input direction and handle the movement/ddeceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	# flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false

	elif direction < 0:
		animated_sprite.flip_h = true

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if Input.is_action_just_pressed("move_left") and Input.is_action_just_released(\
	"move_right"):
		animated_sprite.position.x -= playerOffset
	if Input.is_action_just_pressed("move_right") and Input.is_action_just_released(\
	"move_right"):
		animated_sprite.position.x += playerOffset
	
	if punchDelay.is_stopped() and multiDelay.is_stopped():
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump_")
	
	if Input.is_action_just_pressed("punch") and punchDelay.is_stopped():
		punchDelay.start()
		animated_sprite.play("punch_")
	
	if arrow_set.fullCharge and Input.is_action_just_pressed("multiAttack"):
		animated_sprite.play("multi_attack")
		multiDelay.start()
		arrow_set.fullCharge = false

func check_input():
	
	if Input.is_action_just_pressed("right_arrow"):
		inputSeq[count] = "right_arrow"
	elif Input.is_action_just_pressed("left_arrow"):
		inputSeq[count] = "left_arrow"
	elif Input.is_action_just_pressed("up_arrow"):
		inputSeq[count] = "up_arrow"
	else:
		inputSeq[count] = "down_arrow"
	
	arrow_set.arrowCheck(inputSeq[count])
	
	if inputSeq[count] == arrow_set.arrowKey[count]:
		count += 1
		
	if count == 4 or inputSeq[count] != arrow_set.arrowKey[count] or texture_rect.visible == false:
		count = 0
