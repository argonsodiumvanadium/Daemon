extends KinematicBody2D

export var ACCELERATION = 250
export var FRICTION = 550
export var MAXIMUM_VELOCITY = 75

var occupation

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
	var direction = Vector2.RIGHT
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAXIMUM_VELOCITY, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)

