extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var boss_area: Area2D = %bossArea
@onready var arrow_set: Sprite2D = $arrowSet
@onready var punchDelay: Timer = $punchDelay
@onready var multiDelay: Timer = $multiDelay
@onready var arrowsPaused: Timer = $arrowSet/arrowsPaused
@onready var killzone: Area2D = %killzone
@onready var ghoul: CharacterBody2D = %Ghoul
@onready var dealDamageZone = $attack_move
@onready var attack_hitbox: CollisionShape2D = $attack_move/attack_hitbox

var inputSeq: String
var playerOffset: int = 28
var multi_isplaying: bool = false
var count = 0
var leftFlipped: bool = false
var rightFlipped: bool = true
var attack_type

const SPEED = 300.0
const JUMP_VELOCITY = -700.0
const GRAVITY = 2200.0
const FALL_GRAVITY = 2400.0

func _ready() -> void:
	attack_hitbox.disabled = true

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
	
	# flip the sprite
	if Input.is_action_pressed("move_right") and !Input.is_action_pressed("move_left"):
		animated_sprite.flip_h = false
		dealDamageZone.scale.x = 1
		rightFlipped = true
		if(leftFlipped):
			animated_sprite.position.x += playerOffset
			attack_hitbox.position.x += 36
			leftFlipped = false
		
	elif Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
		animated_sprite.flip_h = true
		dealDamageZone.scale.x = -1
		leftFlipped = true
		if(rightFlipped):
			animated_sprite.position.x -= playerOffset
			attack_hitbox.position.x -= 36
			rightFlipped = false

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
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
		attack_type = "punch_"
		
		set_damage()
		
	if arrow_set.fullCharge and Input.is_action_just_pressed("multiAttack"):
		animated_sprite.play("multi_attack")
		multiDelay.start()
		arrow_set.fullCharge = false
		arrow_set.markersDisappear()
		arrow_set.power_bar.value = 0

func set_damage():
	var damage_to_deal: int
		
	if attack_type == "punch_":
		damage_to_deal = 1
		
	Global.playerDamageAmount = damage_to_deal

func check_input():
	if Input.is_action_just_pressed("right_arrow"):
		inputSeq = "rightArrow"
	elif Input.is_action_just_pressed("left_arrow"):
		inputSeq = "leftArrow"
	elif Input.is_action_just_pressed("up_arrow"):
		inputSeq = "upArrow"
	else:
		inputSeq = "downArrow"
	
	if arrowsPaused.is_stopped():
		arrow_set.arrowCheck(inputSeq)
	
func _on_multi_delay_timeout() -> void:
	arrow_set.fullCharge = false
	arrow_set.arrowsPaused.start()
