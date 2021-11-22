extends "res://entities/enemy.gd"

export var MAXIMUM_VELOCITY = 80
export var ACCELERATION = 40
export var FRICTION = 200

enum {
	IDLE,
	MOVING,
	ATTACK,
	ATTACKING
}
var state = IDLE
var gun_ready = true

var velocity = Vector2.ZERO
var jump_point = null
var distance_to_target = Vector2.ZERO


var bullet = preload("res://chronos/bullet.tscn")
var health = 8

func _physics_process(delta):
	distance_to_target = target.global_position.distance_to(global_position)
	match state:
		IDLE:
			if distance_to_target < 64:
				state = MOVING
		MOVING:
			move(delta)
			if distance_to_target < 96 and gun_ready:
				state = ATTACK
				velocity *= 0
		ATTACK:
			state = ATTACKING
			$gun_charge.start()

func move(delta):
	var direction = (target.global_position - global_position).normalized()
	
	if distance_to_target < 32:
		direction *= -1
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAXIMUM_VELOCITY, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)

func _on_gun_cd_timeout():
	gun_ready = true

func _on_gun_charge_timeout():
	shoot(bullet)
	
	gun_ready = false
	$gun_cd.start()
	state = MOVING
