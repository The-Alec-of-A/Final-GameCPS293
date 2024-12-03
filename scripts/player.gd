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
@onready var playerBody: CollisionShape2D = $CollisionShape2D
@onready var hurtTime: Timer = $hurtTime
@onready var playerBound: Area2D = $playerBound
@onready var playerHealthBar: TextureProgressBar = %"health bar"

var inputSeq: String
var playerOffset: int = 28
var multi_isplaying: bool = false
var count = 0
var leftFlipped: bool = false
var rightFlipped: bool = true
var health = 100
var maxHealth = 100
var can_take_damage: bool = true
var attack_type: String
var attackCollision
var dead: bool = false
var knockbackStun: bool = false
var death_animation_finished: bool = false

var enemy: CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -750.0
const GRAVITY = 2200.0
const FALL_GRAVITY = 2400.0
const BACKFORCE = -400

func _ready() -> void:
	Global.playerBody = self
	Global.playerAlive = true
	attack_hitbox.disabled = true

func gravity(velocity: Vector2):
	if velocity.y < 0:
		return GRAVITY
	return FALL_GRAVITY

func _physics_process(delta: float) -> void:
	Global.playerDamageZone = dealDamageZone
	enemy = Global.enemyBody

	if !dead:
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity(velocity) * delta
	
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor() and !knockbackStun:
			velocity.y = JUMP_VELOCITY
	
		if Input.is_action_just_released("jump") and velocity.y < -420 and !knockbackStun:
			velocity.y = JUMP_VELOCITY / 4
	
		var direction = Input.get_axis("move_left", "move_right")
		
		if boss_area.entered and arrowsPaused.is_stopped() and (Input.is_action_just_pressed( \
		"down_arrow") or Input.is_action_just_pressed("up_arrow") or \
		Input.is_action_just_pressed("left_arrow") or Input \
		.is_action_just_pressed("right_arrow")):
			check_input()
	
		# flip the sprite
		if Input.is_action_pressed("move_right") and !Input.is_action_pressed("move_left") and !knockbackStun:
			animated_sprite.flip_h = false
			dealDamageZone.scale.x = 1
			rightFlipped = true
			if(leftFlipped):
				animated_sprite.position.x += playerOffset
				attack_hitbox.position.x += 36
				leftFlipped = false
		
		elif Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right") and !knockbackStun:
			animated_sprite.flip_h = true
			dealDamageZone.scale.x = -1
			leftFlipped = true
			if(rightFlipped):
				animated_sprite.position.x -= playerOffset
				attack_hitbox.position.x -= 36
				rightFlipped = false

		if direction and !knockbackStun:
			velocity.x = direction * SPEED
		else:
			if !knockbackStun:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	
		if punchDelay.is_stopped() and multiDelay.is_stopped() and hurtTime.is_stopped() and !knockbackStun:
			if is_on_floor():
				if direction == 0:
					animated_sprite.play("idle")
				else:
					animated_sprite.play("run")
			else:
				animated_sprite.play("jump_")

		if Input.is_action_just_pressed("punch") and punchDelay.is_stopped() and !knockbackStun:
			punchDelay.start()
			animated_sprite.play("punch_")
			attack_type = "punch"
			toggle_damage_collision()
			set_damage()
				
		if arrow_set.fullCharge and Input.is_action_just_pressed("multiAttack") and !knockbackStun:
			animated_sprite.play("multi_attack")
			multiDelay.start()
			arrow_set.fullCharge = false
			arrow_set.markersDisappear()
			arrow_set.power_bar.value = 0
			attack_type = "multi"
			toggle_damage_collision()
			set_damage()
			
		check_hitbox()

	elif dead and !death_animation_finished:
		velocity.y += gravity(velocity) * delta
		if hurtTime.is_stopped():
			velocity.x = 0
			animated_sprite.play("death")
			await get_tree().create_timer(1.5).timeout
			death_animation_finished = true
			animated_sprite.pause()
			await get_tree().create_timer(1.5).timeout
			get_tree().reload_current_scene()
		
	if !death_animation_finished and !killzone.died:
		move_and_slide()

func toggle_damage_collision():
	attackCollision = dealDamageZone.get_node("attack_hitbox")
	attackCollision.disabled = false

func set_damage():
	var damage_to_deal: int
		
	if attack_type == "punch":
		damage_to_deal = 1
		
	if attack_type == "multi":
		damage_to_deal = 3
		
	Global.playerDamageAmount = damage_to_deal
	Global.attackType = attack_type

func takeDamage(damage):
	if damage != 0:
		animated_sprite.play("hit")

		if health > 0:
			health -= damage
			playerHealthBar.value += damage
		
		if health <= 0:
			health = 0
			dead = true
			Global.playerAlive = false
			
		if can_take_damage:
			knockbackStun = true
			var knockback = BACKFORCE
			if position.x <= enemy.position.x:
				velocity.x = knockback
				velocity.y = knockback * 0.75
			else:
				velocity.x = -knockback
				velocity.y = knockback * 0.75

		can_take_damage = false
		hurtTime.start()


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

func check_hitbox():
	var hitArea = playerBound.get_overlapping_areas()
	var damage: int
	if hitArea:
		var hitbox = hitArea.back()
		if hitbox.get_parent() is CultistEnemy:
			damage = Global.enemyDamageAmount
		
	if can_take_damage:
		takeDamage(damage)
	
func _on_multi_delay_timeout() -> void:
	arrow_set.fullCharge = false
	arrow_set.arrowsPaused.start()

func _on_punch_delay_timeout() -> void:
	attackCollision.disabled = true

func _on_hurt_time_timeout() -> void:
	can_take_damage = true
	knockbackStun = false
