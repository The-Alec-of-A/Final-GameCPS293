extends CharacterBody2D

@onready var enemy_bounds: Area2D = $enemyBounds
@onready var enemy_animation: AnimatedSprite2D = $AnimatedSprite2D

var health = 10
var inArea = false
var taking_damage = true
var is_roaming: bool

func _on_ready() -> void:
	Global.enemyDamageZone = enemy_bounds

func _on_enemy_hitbox_area_entered(area: Area2D) -> void:
	var damage = Global.playerDamageAmount
	if area == Global.playerDamageZone:
		hit(damage)
	
func hit(damage: int):
	health -= damage
	enemy_animation.play("hit")
	taking_damage = true
	print(health)
	
	if(health <= 0):
		enemy_animation.play("die")
	#Global.punchInRange = false
