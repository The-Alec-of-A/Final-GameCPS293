extends CharacterBody2D

class_name CultistEnemy

@onready var enemyBounds: Area2D = $enemyBounds
@onready var enemy_anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var punched: AudioStreamPlayer2D = $punched
@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var enemy_hitbox: CollisionShape2D = $enemyBounds/enemy_hitbox
@onready var dealDamageArea: Area2D = $DealDamageArea

@onready var disappearDelay: Timer = $disappearDelay
@onready var bossHealthBar: TextureProgressBar = %"boss health bar"
@onready var hurtTime: Timer = $hurtTime
@onready var navAgent:= $NavigationAgent2D as NavigationAgent2D

const SPEED = 45
const GRAVITY = 1200

var health = 10
var maxHealth = 10
var inArea: bool = false
var taking_damage = false
var is_enemy_chase: bool = true
var is_roaming: bool = true
var dead: bool = false
var is_dealing_damage: bool = false
var move: Vector2
var leftFlipped: bool = true
var rightFlipped: bool = false
var spriteFlipOffset: int = 21
var isIdle: bool = true
var damage_to_deal: int = 8

var player: CharacterBody2D

func _on_ready() -> void:
	Global.enemyBody = self

func _process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.x = 0
	
	player = Global.playerBody
	Global.enemyDamageAmount = damage_to_deal
	Global.enemyDamageZone = dealDamageArea
	
	movement(delta)
	move_and_slide()
	
func movement(delta):
	
	if Global.playerAlive:
		if velocity.x == 0 and !dead and hurtTime.is_stopped():
			enemy_anim.play("idle")
	
		elif velocity.x != 0 and !dead and hurtTime.is_stopped():
			enemy_anim.play("walk")
	
		if !dead and hurtTime.is_stopped():
			if !is_enemy_chase:
				velocity += move * SPEED * delta
			elif is_enemy_chase and !taking_damage and Global.playerAlive:
				var directionToPlayer = position.direction_to(player.position) * SPEED
				velocity.x = directionToPlayer.x
			
			is_roaming = true
		 
		elif dead:
			velocity.x = 0
			
		if !dead and !taking_damage and !is_dealing_damage:
			if player.position.x > position.x + 25 and leftFlipped:
				enemy_anim.flip_h = true
				leftFlipped = false
				rightFlipped = true
				position.x += spriteFlipOffset
				collisionShape.position.x -= 4 #enemy collision borders align with enemy after movement offset
				enemy_hitbox.position.x -= 4

			elif player.position.x <= position.x - 25 and rightFlipped:
				enemy_anim.flip_h = false
				rightFlipped = false
				leftFlipped = true
				position.x -= spriteFlipOffset
				collisionShape.position.x += 4
				enemy_hitbox.position.x -= 4
			
		if !dead and taking_damage and !is_dealing_damage and Global.attackType == "punch":
			enemy_anim.play("hit")
			hurtTime.start()
			taking_damage = false
	
		if !dead and !taking_damage and !is_dealing_damage and Global.attackType == "multi":
			taking_damage = false
	
		if dead and is_roaming:
			is_roaming = false
			enemy_anim.play("die")
			collision_layer = 2
			await get_tree().create_timer(1.1).timeout #1.1 because the death animation takes 1.1 secs
			enemy_anim.pause()
			disappearDelay.start()
			
	else:
		velocity.x = 0
		enemy_anim.play("idle")
		
func _on_enemy_bounds_area_entered(area: Area2D) -> void:
	var damage = Global.playerDamageAmount
	if area == Global.playerDamageZone:
		inArea = true
		hit(damage)
	
func _on_enemy_bounds_area_exited(area: Area2D) -> void:
	if area == Global.playerDamageZone:
		inArea = false

func hit(damage):
	
	velocity.x = 0
	if Global.attackType == "punch":
		hurtTime.stop()
		bossHealthBar.value += 1
		punched.play()
		
	if Global.attackType == "multi":
		for i in range(5):
			if inArea:
				punched.play()
				enemy_anim.play("hit")
				bossHealthBar.value += damage
				health -= damage
				await get_tree().create_timer(0.2).timeout
		await get_tree().create_timer(0.3).timeout
	
		if inArea:
			damage = 15
			punched.play()
			bossHealthBar.value += damage
			health -= damage
				
	health -= damage
	taking_damage = true
	
	if health <= 0:
		health = 0
		dead = true
	
func rndDelay(timeArray):
	timeArray.shuffle()
	return timeArray.front()

func _on_disappear_delay_timeout() -> void:
	self.queue_free()

func _on_follow_player_timeout() -> void:
	navAgent.target_position = player.global_position
