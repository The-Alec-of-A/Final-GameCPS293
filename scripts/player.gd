extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var boss_area: Area2D = %bossArea
@onready var arrow_set: Sprite2D = $arrowSet
@onready var punchDelay: Timer = $punchDelay

var inputSeq: Array[String] = ["", "", "", ""]
var offsetFix = false
var count: int = 0

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
		
	if boss_area.entered == true and (Input.is_action_just_pressed( \
	"down_arrow") or Input.is_action_just_pressed("up_arrow") or \
	Input.is_action_just_pressed("left_arrow") or Input \
	.is_action_just_pressed("right_arrow")):
		check_input()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	# flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	if Input.is_action_just_pressed("move_left") and offsetFix == false:
		animated_sprite.position.x -= 21
		offsetFix = true
	if Input.is_action_just_pressed("move_right") and offsetFix == true:
		animated_sprite.position.x += 21
		offsetFix = false
	
	if punchDelay.is_stopped() == true:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump_")
	
	if direction >= -1 and Input.is_action_just_pressed("punch") and \
	 punchDelay.is_stopped() == true:
		punchDelay.start()
		animated_sprite.play("punch_")
	
	if arrow_set.fullCharge == true and direction >= -1 and Input.\
	is_action_just_pressed("multiAttack"):
		animated_sprite.play("punch_")
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func check_input():
	
	if Input.is_action_just_pressed("right_arrow"):
		inputSeq[count] = "right_arrow"
	elif Input.is_action_just_pressed("left_arrow"):
		inputSeq[count] = "left_arrow"
	elif Input.is_action_just_pressed("up_arrow"):
		inputSeq[count] = "up_arrow"
	else:
		inputSeq[count] = "down_arrow"
	
	arrow_set.arrowCheck(inputSeq)
	
	if(inputSeq[count] == arrow_set.arrowKey[count]):
		count += 1
		if count == 4:
			count = 0
	
	else:
		count = 0
