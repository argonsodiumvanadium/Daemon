extends "res://entities/enemy.gd"

export var MAXIMUM_VELOCITY = 200
export var ACCELERATION = 350
export var FRICTION = 1000
export var NUMBER_OF_SHOTS = 3

enum {
	IDLE,
	JUMP,
	JUMPING,
	JUMPED,
	ATTACK,
	ATTACKING
	HEAL
}
var state = IDLE

var velocity = Vector2.ZERO
var jump_point = null

var bullet = preload("res://derailer/bullet.tscn")
var health = 5


func _physics_process(delta):
	match state:
		IDLE:
			if target.global_position.distance_to(global_position) < 128:
				state = JUMP
		JUMP:
			state = JUMPING
			if jump_point == null:
				jump_point = get_jump_point()
				
				if jump_point == Vector2.ZERO:
					state = JUMPED
			continue
		JUMPING:
			reposition(delta,jump_point)
		
		JUMPED:
			jump_point = null
			if health < 3 and randi() % 3 < 2:
				state = HEAL
			else:
				state = ATTACK
		
		ATTACK:
			$charge_timer.start()
			state = ATTACKING
		
		ATTACKING:
			pass
			# $gun.look_at(predict_location())
			# work on predicting where hero goes to make the bots more of a threat
		HEAL:
			health += 1

func predict_location():
	var slope = (target.position.y - position.y) / (target.position.x - position.x)
	slope = -1 / slope
	
	var theta = atan(slope)
	var phi = atan2(target.velocity.y, target.velocity.x)
	
	var angle_with_x = theta - phi
	var angle_with_y = PI/2 - angle_with_x
	
	var vec_perp = target.velocity.project(Vector2.RIGHT.rotated(angle_with_x))
	var vec_len = vec_perp.length()
	var value = sqrt (MAXIMUM_VELOCITY * MAXIMUM_VELOCITY - vec_len * vec_len)
	var vec_parr = Vector2.UP * value
	vec_parr = vec_parr.rotated(angle_with_y)
	
	var direction = (vec_parr + vec_perp) + position
	if vec_parr.dot(vec_perp) != 0:
		print ("ITS NOT WORKING")
	
	return direction

func get_jump_point() -> Vector2 :
	var potential_jump_points = []
	var jump_point_dot_products = []
	var nearby_jump_points = []
	
	for raycast in raycasts:
		var dot = raycast.cast_to.normalized().dot((target.position - position).normalized())
		
		if dot > 0.3 and dot < 0.8:
			nearby_jump_points.append((0.5 * raycast.cast_to)  + position)
			if ! raycast.is_colliding() :
				potential_jump_points.append(0.5 * raycast.cast_to + position)
				jump_point_dot_products.append(dot)
	
	var gjpindex = jump_point_dot_products.find(jump_point_dot_products.max())
	var good_jump_point = Vector2.ZERO
	
	if gjpindex != -1:
		good_jump_point = potential_jump_points[gjpindex]
	else :
		good_jump_point = nearby_jump_points[randi()%nearby_jump_points.size()]
	return good_jump_point

var prev_posn = Vector2.ZERO

func reposition(delta, jump_point):
	
	var direction_to_jump_point = jump_point - position
	var direction = direction_to_jump_point.normalized()
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAXIMUM_VELOCITY, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)
	
	if position.distance_to(jump_point) < 8 or velocity.length() < 1:
		state = JUMPED
		
		velocity = Vector2.ZERO
	
	prev_posn = position

var bullets_to_shoot = 0

func _on_shoot_timer_timeout():
	bullets_to_shoot -= 1
	
	if bullets_to_shoot > 0:
		shoot(bullet)
		$shoot_timer.start()
	else:
		state = JUMP



func _on_charge_timer_timeout():
	bullets_to_shoot = NUMBER_OF_SHOTS
	shoot(bullet)
	$shoot_timer.start()
