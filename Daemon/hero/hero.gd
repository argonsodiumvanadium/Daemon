extends KinematicBody2D

export var ACCELERATION = 250
export var FRICTION = 550
export var MAXIMUM_VELOCITY = 75

var minimap

# states
enum {
	MOVE,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO

func _ready():
	pass

func _physics_process(delta):
	match state:
		MOVE:
			move(delta)


func move(delta):
	var direction = get_direction()
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAXIMUM_VELOCITY, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)

func get_direction():
	var val = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_W):
		val += Vector2.UP
	if Input.is_key_pressed(KEY_A):
		val += Vector2.LEFT
	if Input.is_key_pressed(KEY_S):
		val += Vector2.DOWN
	if Input.is_key_pressed(KEY_D):
		val += Vector2.RIGHT
	
	return val.normalized()
