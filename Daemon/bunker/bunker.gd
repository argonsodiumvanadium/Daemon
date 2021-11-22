extends Node2D

var derailer = preload("res://derailer/derailer.tscn")
var chronos = preload("res://chronos/chronos.tscn")
var human = preload("res://humans/human.tscn")
onready var hero = $YSort/hero

# map generation variables
var noise
var map_size = Rect2(Vector2.ZERO,Vector2(80,80))
var floor_cap = 0.4 # value of noise for which the floor will be placed
var entity_threshold = Vector2(0,0.1)
var human_threshold = Vector2(0.1,0.4)

onready var minimap_node = $CanvasLayer/minimap
var minimap
var map
var minimap_texture

var hero_position # this stores hero's position based on tilemap's mapping convn
var area = 0

func _ready():
	hero.minimap = minimap_node
	
	map = Image.new()
	minimap = Image.new()
	minimap_texture = ImageTexture.new()
	
	map.create(map_size.size.x,map_size.size.y,false,Image.FORMAT_RGBA8)
	minimap.create(map_size.size.x,map_size.size.y,false,Image.FORMAT_RGBA8)
	
	
	minimap.lock()
	map.lock()

	minimap.fill(Color.black)
	
	generate_bunker()
	
	map.save_png("map.png")

func _physics_process(delta):
	minimap.lock()
	var hero_x = hero.position.x/$environment.cell_size.x
	var hero_y = hero.position.y/$environment.cell_size.y
	
	for xt in 5:
		for yt in 5:
			var x = xt + int(hero_x - 2.5)
			var y = yt + int(hero_y - 2.5)
			
			if x > 0 and y > 0:
				minimap.set_pixel(x,y,map.get_pixel(x,y))
	
	minimap.set_pixel(hero_x,hero_y, Color.royalblue)
	
	var mini_img = Image.new()
	mini_img.create(12,12,false,Image.FORMAT_RGBA8)
	
	mini_img.blit_rect(minimap,
		Rect2(Vector2(int(hero_x - 6), int (hero_y - 6)), Vector2(int (hero_x + 6),int(hero_y + 6))),
		Vector2.ZERO
	)
	
	minimap.unlock()
	
	mini_img.resize(144,144,Image.INTERPOLATE_NEAREST)
	
	minimap_texture.create_from_image(mini_img)
	hero.minimap.texture_rect.texture = minimap_texture


func generate_bunker () -> void:
	var walls = []
	
	randomize()
	
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	
	noise.octaves = 1.0
	noise.period = 3
	noise.persistence = 0.5
	
	walls = make_floor()
	make_walls(walls)
	
	spawn_entities()
	
	initialise_area()
	if area < 1000:
		generate_bunker()
		return
	
	$environment.update_bitmask_region(map_size.position,map_size.end)

func make_floor() -> Array :
	var hero_is_not_placed = true
	var walls = []
	
	for x in map_size.end.x:
		for y in map_size.end.y:
			var a = noise.get_noise_2d(x,y)
			if a < floor_cap:
				randomize()
				if hero_is_not_placed and (randi() % 2000 < 2):
					
					hero_position = Vector2(x,y)
					hero.position = Vector2(x,y) * $environment.cell_size + Vector2.ONE * 16
					hero_is_not_placed = false
				
				if randi() % 5 < 2:
					spawn_human(x,y)
				map.set_pixel(x,y, Color.gray)
				
				$environment.set_cell(x,y,0)
				walls.append(Vector2(x,y-1))
	
	return walls

func make_walls(walls : Array):
	for xt in map_size.end.x + 2:
		for yt in map_size.end.y + 2:
			var x = xt - 1
			var y = yt - 1
			if ! noise.get_noise_2d(x,y) < floor_cap or !map_size.has_point(Vector2(x,y)):
				$environment.set_cell(x,y,2)
				map.set_pixel(x,y, Color.darkgray)
				
	for wall in walls:
		if ! noise.get_noise_2d(wall.x,wall.y) < floor_cap  or !map_size.has_point(wall):
			$environment.set_cell(wall.x,wall.y,1)
			map.set_pixel(wall.x,wall.y, Color.lightslategray)
			

func spawn_entities() :
	for x in map_size.end.x:
		for y in map_size.end.y:
			var n = noise.get_noise_2d(x,y)

			if n < entity_threshold.y and n > entity_threshold.x:
				var r = randi()%10
				if r == 1: # for derailers
					var d = derailer.instance()
					d.target = hero
					d.position =  Vector2(x,y)* $environment.cell_size + Vector2.ONE * 16
					
					$YSort.add_child(d)
				elif r == 6 : # for chronos
					var c = chronos.instance()
					c.target = hero
					c.position =  Vector2(x,y)* $environment.cell_size + Vector2.ONE * 16
					
					$YSort.add_child(c)

func spawn_human(x,y) :
	var h = human.instance()
	var vec_r = Vector2.RIGHT * (randi()%int($environment.cell_size.x))
	vec_r += Vector2.UP * (randi()%int($environment.cell_size.y))
	h.position =  Vector2(x,y)* $environment.cell_size + Vector2.ONE * 16
	h.position -= vec_r
	
	$YSort.add_child(h)

func initialise_area ():
	area = 0
	
	get_playable_area(hero_position)

# uses boundary fill (4 directions) to get area
func get_playable_area (tile : Vector2) :
	if ! is_floor(tile) or area > 1000:
		return
	else:
		area = area + 1
		
		get_playable_area(tile + Vector2.RIGHT)
		get_playable_area(tile + Vector2.UP)
		get_playable_area(tile + Vector2.LEFT)
		get_playable_area(tile + Vector2.DOWN)

func is_floor (position : Vector2) -> bool:
	return 0 == $environment.get_cell(position.x, position.y)
