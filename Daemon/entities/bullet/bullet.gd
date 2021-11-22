extends Area2D

export var target_groups = ""
export var friendly_groups = ""
export var speed = 500

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_Bullet_body_entered(body):
	if body.is_in_group(target_groups):
		pass
	elif body.is_in_group(friendly_groups):
		return
	queue_free()
