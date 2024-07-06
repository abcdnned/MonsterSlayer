# 4.8 target
# TODO goblin warrior AI
# TODO new weapon design

# Backlogs
# Flag area, dangrous++
# Sheild charge
# goblin bomber
# goblin slow liquid thrower
# pickable enemy weapon
# notification when target spotted
# switch weapon
# pick order bug fix
# Goblin Flag generator
# no cycle tree
# war fog
# light
# multi items
# weapon tire
# rush gallary
# burnable wooden locked door
# key merchants boss
# goblin summoner
# treasure goblin sneaker
# world map related code move to map.gd
# white eye attack, purple eye attack

extends Node2D

@onready var player = null
@onready var tile_map = $TileMap
@onready var kill = $UI/Kill
@onready var coins = $UI/Coins
@onready var winning_scene = $UI/WinningScene
@onready var hearts = $UI/Life/Hearts
@onready var max_hearts = $UI/Life/MaxHearts
@onready var spawner = $GoblinArmy1Spawner
@onready var lose_scene = $UI/LoseScene
@onready var winning_sound = $WinningSound
@onready var map = $UI/Map
@onready var war_eye = $UI/WarEye
const PLAYER = preload("res://scenes/player.tscn")
const PLAYER_SPEAR = preload("res://scenes/player_spear.tscn")
const GOBLIN_ARMY_TOP_LEFT = Vector2(-3600, -4000)
const GOBLIN_ARMY_BOTTOM_RIGHT = Vector2(3600, -11000)
var money: int = 0
var kill_count = 0

# Called when the node enters the scene tree for the first time.
#   1
# 4   2
#   3
func _ready():
	randomize()
	load_player(PLAYER, Vector2(0, 0))
	var route := {}
	_create_boime(-10, 10, -10, 10, map.map, 4, 4, 0, map.map_cord, route)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _create_boime(x1, x2, y1, y2, map, mx, my, from, cord, route):
	for x in range(x1, x2 + 1):
		for y in range(y1, y2 + 1):
			var chance = randi_range(1, 100 + 10 + 5)
			self.map.tile_to_cord[Vector2(x, y)] = Vector2(mx, my)
			if chance <= 10:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), 0)
			elif chance <= 15:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0), 0)
			else:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 1), 0)
	route[Vector2(mx, my)] = null
	var size = x2 - x1 + 1
	cord.append({"map": Vector2(mx, my), "top_left": Vector2(x1, y1), "bottom_right": Vector2(x2, y2)})
	# generate plain
	if from != 3 and map[mx + 1][my] == 1 and not route.has(Vector2(mx + 1, my)):
		_create_boime(x1, x2, y1 + size, y2 + size, map, mx + 1, my, 1, cord, route)
	if from != 2 and map[mx][my + 1] == 1 and not route.has(Vector2(mx, my + 1)):
		_create_boime(x1 + size, x2 + size, y1, y2, map, mx, my + 1, 4, cord, route)
	if from != 1 and map[mx - 1][my] == 1 and not route.has(Vector2(mx - 1, my)):
		_create_boime(x1, x2, y1 - size, y2 - size, map, mx - 1, my, 3, cord, route)
	if from != 4 and map[mx][my - 1] == 1 and not route.has(Vector2(mx, my - 1)):
		_create_boime(x1 - size, x2 - size, y1, y2, map, mx, my - 1, 2, cord, route)
	# generate wall
	if from != 3 and map[mx + 1][my] == 0:
		for x in range(x1, x2 + 1):
			tile_map.set_cell(0, Vector2i(x, y2), 0, Vector2i(0, 2), 0)
	if from != 2 and map[mx][my + 1] == 0:
		for y in range(y1, y2 + 1):
			tile_map.set_cell(0, Vector2i(x2, y), 0, Vector2i(0, 2), 0)
	if from != 1 and map[mx - 1][my] == 0:
		for x in range(x1, x2 + 1):
			tile_map.set_cell(0, Vector2i(x, y1), 0, Vector2i(0, 2), 0)
	if from != 4 and map[mx][my - 1] == 0:
		for y in range(y1, y2 + 1):
			tile_map.set_cell(0, Vector2i(x1, y), 0, Vector2i(0, 2), 0)

func _on_player_hero_death():
	lose_scene.visible = true

func _on_mob_death(node):
	kill_count += 1
	kill.text = "KILL " + str(kill_count)
	if node.name == "GoblinWarrior":
		_win()

func _win():
	winning_scene.visible = true
	spawner.enable = false
	winning_sound.play()
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		mob.add_to_group("lose")


func _on_spawner_starter_timeout():
	spawner.enable = true

func load_player(player_type, position):
	if player != null:
		player.queue_free()
		player = null
	player = player_type.instantiate()
	player.global_position = position
	add_child(player)
	player.owner = self
	player.health_change.connect(hearts._on_player_health_change)
	player.max_health_change.connect(max_hearts._on_player_max_health_change)
	player.hero_death.connect(_on_player_hero_death)
	player.map_pos_change.connect(map._on_player_map_pos_change)
	player.map_pos_change.connect(_on_player_map_pos_change)
	player._ready()

func _on_player_map_pos_change(x, y):
	var p = tile_map.local_to_map(tile_map.to_local(Vector2(x, y)))
	var i = self.map.tile_to_cord[Vector2(p.x, p.y)]
	if i and map.war_eye[i.x][i.y] > 0:
		war_eye.visible = true
	else:
		war_eye.visible = false
	if i and map.war_eye[i.x][i.y] == 1:
		spawner.enable = true
	else:
		spawner.enable = false
	#print(Vector2(x, y)) # TODO get pos
		
func get_money(m):
	money += m
	coins.text = "Coins: " + str(money)

func spawn(type, top_left, bottom_right):
	var spawn_position = get_spawn_position(top_left, bottom_right)
	var thing = type.instantiate()
	thing.position = spawn_position
	add_child(thing)
	return thing

func get_spawn_position(top_left, bottom_right):
	var x = randf_range(top_left.x, bottom_right.x)
	var y = randf_range(bottom_right.y, top_left.y)
	while not can_spawn(x, y):
		x = randf_range(top_left.x, bottom_right.x)
		y = randf_range(bottom_right.y, top_left.y)
	return Vector2(x, y)

func can_spawn(x, y):
	var p = tile_map.local_to_map(tile_map.to_local(Vector2(x, y)))
	return tile_map.get_cell_atlas_coords(0, p) != Vector2i(0, 2)
	
