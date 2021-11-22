extends KinematicBody2D

export var RAYCAST_LEN = 196

var target
var raycasts = []

func _ready():
	init()

# requrires a node in which the raycasts will be dumped
func init(parent : Node2D = self, num_of_raycasts : int = 12):
	for i in num_of_raycasts:
		var ray = RayCast2D.new()
		ray.enabled = true
		ray.cast_to = RAYCAST_LEN * Vector2.UP.rotated((2 * PI * i) / num_of_raycasts)
		
		parent.add_child(ray)
		raycasts.append(ray)
	

func _physics_process(delta):
	$gun.look_at(target.position)

func shoot (pkd_bullet : PackedScene):
	var transform = $gun/muzzle.global_transform
	
	var bullet = pkd_bullet.instance()
	bullet.global_transform = transform
	
	get_tree().get_current_scene().add_child(bullet)
