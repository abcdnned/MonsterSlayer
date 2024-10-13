extends Control

@onready var grid_container = $GridContainer
var map = []
var entity = []
var cord_to_tile = {}
var tile_to_cord = {}
var level_cord = {}
var gate := {}
const START = Vector2(0, 0)
const MAP_H = 20
const MAP_V = 20
const TILE_REGION_SIZE = 20
var tiles = []
var war_eye = []
const MAP_TILE = preload("res://scenes/map_tile.tscn")
var player = null
const KNIGHT_POTRIAT = preload("res://scenes/knight_potriat.tscn")
const KEY_HOLE = preload("res://scenes/key_hole.tscn")
const OBSTACLE_AGENT = preload("res://scenes/obstacle_agent.tscn")

func _ready():
	init_map()
	create_boime()
	for x in range(0, MAP_V):
		print(map[x])
	
func _process(delta):
	if Input.is_action_pressed("tab"):
		visible = true
	else:
		visible = false

func init_map():
	for y in range(MAP_H):
		var row = []
		for x in range(MAP_V):
			row.append(0)  # 0 represents a default tile type
		map.append(row)
	for y in range(MAP_H):
		var row = []
		for x in range(MAP_V):
			row.append(0)  # 0 represents a default tile type
		war_eye.append(row)
	for x in range(MAP_H):
		var row = []
		for y in range(MAP_V):
			var tile = MAP_TILE.instantiate()
			grid_container.add_child(tile)
			tile.color = Color.BURLYWOOD
			row.append(tile)
		tiles.append(row)
	for x in range(MAP_V):
		var row = []  # Initialize the row array
		for y in range(MAP_H):
			row.append({})  # Optionally initialize inner values, e.g., with null or a specific initial value
		entity.append(row)  # Append the row to the main array
	init_map_to_tile_cord()
	print(cord_to_tile)
	
	
func create_gate(x, y, d):
	gate[Vector2(x, y)] = d

func create_plain_chambler(top_left, bottom_right, war_eye = false):
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			set_plain_tile(x, y, war_eye)

func create_half_plain_chambler(bottom_left, war_eye = false):
	set_plain_tile(bottom_left.x, bottom_left.y, war_eye)
	set_plain_tile(bottom_left.x - 1, bottom_left.y, war_eye)
	set_plain_tile(bottom_left.x, bottom_left.y + 1, war_eye)
	set_plain_tile(bottom_left.x - 1, bottom_left.y + 1, war_eye)
	

func set_plain_tile(x, y, is_war_eye = false):
	map[x][y] = 1
	tiles[x][y].color = Color(.2, .8, .2, .5)
	if is_war_eye:
		war_eye[x][y] = 1

func init_map_to_tile_cord():
	var top_left = Vector2(0, 0)
	var bottom_right = Vector2(TILE_REGION_SIZE - 1, TILE_REGION_SIZE - 1)
	for x in range(0, MAP_H):
		for y in range(0, MAP_V):
			cord_to_tile[Vector2(x, y)] = {"top_left": Vector2(top_left.x + x * TILE_REGION_SIZE, top_left.y + y * TILE_REGION_SIZE), "bottom_right": Vector2(bottom_right.x + x * TILE_REGION_SIZE, bottom_right.y + y * TILE_REGION_SIZE)}

func _on_player_map_pos_change(x, y):
	if player:
		player.queue_free()
	player = KNIGHT_POTRIAT.instantiate()
	var p = owner.get_tile_map().local_to_map(owner.get_tile_map().to_local(Vector2(x, y)))
	for key in cord_to_tile:
		if cord_to_tile[key]["top_left"].x <= p.x and cord_to_tile[key]["top_left"].y <= p.y and cord_to_tile[key]["bottom_right"].x >= p.x and cord_to_tile[key]["bottom_right"].y >= p.y:
			tiles[key.y][key.x].add_child(player)
			active_entities(key.x, key.y)	
			break

func active_entities(x, y):
	for k in entity[x][y]:
		entity[x][y][k].process_mode = PROCESS_MODE_INHERIT
		print(entity[x][y][k].name)

func get_spawn_border_position(top_left, bottom_right):
	var get_random_x = func():
		var x = randf_range(-128, 128)
		if x < 0:
			x = bottom_right.x + x - 128
		else:
			x = top_left.x + x + 128
		return x
	var get_random_y = func():
		var y = randf_range(-128, 128)
		if y < 0:
			y = bottom_right.y + y - 128
		else:
			y = top_left.y + y + 128
		return y
	var x = get_random_x.call()
	var y = get_random_y.call()
	while not can_spawn(x, y):
		x = get_random_x.call()
		y = get_random_y.call()
	return Vector2(x, y)

func get_spawn_position(top_left, bottom_right):
	var x = randf_range(top_left.x, bottom_right.x)
	var y = randf_range(bottom_right.y, top_left.y)
	while not can_spawn(x, y):
		x = randf_range(top_left.x, bottom_right.x)
		y = randf_range(bottom_right.y, top_left.y)
	return Vector2(x, y)

func can_spawn(x, y):
	var p = owner.tile_map.local_to_map(owner.tile_map.to_local(Vector2(x, y)))
	return owner.tile_map.get_cell_atlas_coords(0, p) != Vector2i(0, 2)

func create_boime():
	for x in range(0, MAP_H):
		for y in range(0, MAP_V):
			var chance = randi_range(1, 100)
			if chance <= 6:
				map[x][y] = 2
				tiles[y][x].color = Color(0.133333, 0.545098, 0.133333, .75)
			elif chance <= 12:
				map[x][y] = 3
				tiles[y][x].color = Color(0.533333, 0.345098, 0.133333, .75)
			else:
				map[x][y] = 1
				tiles[y][x].color = Color(0.133333, 0.545098, 0.133333, .4)
	for x in range(0, MAP_H):
		for y in range(0, MAP_V):
			if map[x][y] == 2  and x + 1 < MAP_H and y - 1 >= 0 and map[x + 1][y - 1] == 2 and map[x + 1][y] != 2 and map[x][y - 1] != 2:
				map[x][y - 1] = 2
				tiles[y][x].color = Color(0.133333, 0.545098, 0.133333, .75)
			elif map[x][y] == 2 and x - 1 >= 0 and y - 1 >= 0 and map[x - 1][y - 1] == 2 and map[x - 1][y] != 2 and map[x][y - 1] != 2:
				map[x][y - 1] = 2
				tiles[y][x].color = Color(0.133333, 0.545098, 0.133333, .75)
	map[0][0] = 1
	tiles[0][0].color = Color(0.133333, 0.545098, 0.133333, .4)
	for x in range(0, MAP_H):
		for y in range(0, MAP_V):
			create_region(cord_to_tile[Vector2(x, y)]["top_left"], cord_to_tile[Vector2(x, y)]["bottom_right"], x, y)


func create_region(top_left, bottom_right, mx, my):
	var x1 = top_left.x
	var x2 = bottom_right.x
	var y1 = top_left.y
	var y2 = bottom_right.y
	for x in range(x1, x2 + 1):
		for y in range(y1, y2 + 1):
			if map[mx][my] == 1:
				var chance = randi_range(1, 100 + 10 + 5)
				tile_to_cord[Vector2(x, y)] = Vector2(mx, my)
				if chance <= 10:
					owner.get_tile_map().set_cell(Vector2i(x, y), 0, Vector2i(0, 0), 0)
				elif chance <= 15:
					owner.get_tile_map().set_cell(Vector2i(x, y), 0, Vector2i(1, 0), 0)
				else:
					owner.get_tile_map().set_cell(Vector2i(x, y), 0, Vector2i(0, 1), 0)	
			elif map[mx][my] == 2:
				owner.get_tile_map().set_cell(Vector2i(x, y), 0, Vector2i(0, 2), 0)
			elif map[mx][my] == 3:
				if randi_range(1, 100) <= 2:
					owner.get_tile_map().set_cell(Vector2i(x, y), 0, Vector2i(0, 2), 0)
					var p = owner.get_tile_map().to_global(owner.get_tile_map().map_to_local(Vector2(x, y)))
					spawn_apple(p, mx, my)
	# generate wall
	if my + 1 >= MAP_V:
		for x in range(x1, x2 + 1):
			owner.get_tile_map().set_cell(Vector2i(x, y2), 0, Vector2i(0, 2), 0)
	if mx + 1 >= MAP_H:
		for y in range(y1, y2 + 1):
			owner.get_tile_map().set_cell(Vector2i(x2, y), 0, Vector2i(0, 2), 0)
	if my - 1 < 0:
		for x in range(x1, x2 + 1):
			owner.get_tile_map().set_cell(Vector2i(x, y1), 0, Vector2i(0, 2), 0)
	if mx - 1 < 0:
		for y in range(y1, y2 + 1):
			owner.get_tile_map().set_cell(Vector2i(x1, y), 0, Vector2i(0, 2), 0)
	# generate gate
	if gate.has(Vector2(mx, my)):
		match gate[Vector2(mx, my)]:
			1:
				var center = (x2 + x1 + 1) / 2
				for x in range(x1 + 1, x2):
					if x == center:
						owner.get_tile_map().set_cell(Vector2i(x, y1), 0, Vector2i(1, 2), 0)
						var keyHole = KEY_HOLE.instantiate()
						keyHole.global_position = owner.get_tile_map().to_global(owner.get_tile_map().map_to_local(Vector2(x, y1)))
						keyHole.door.append(Vector2(x, y1))
						keyHole.door.append(Vector2(x - 2, y1))
						keyHole.door.append(Vector2(x - 1, y1))
						keyHole.door.append(Vector2(x + 1, y1))
						keyHole.door.append(Vector2(x + 2, y1))
						get_tree().current_scene.add_child(keyHole)
					elif x >= center - 2 and x <= center + 2 and x != center:
						owner.get_tile_map().set_cell(Vector2i(x, y1), 0, Vector2i(2, 0), 0)
					else:
						owner.get_tile_map().set_cell(Vector2i(x, y1), 0, Vector2i(1, 1), 0)
			3:
				var center = (x2 + x1 + 1) / 2
				for x in range(x1 + 1, x2):
					if x == center:
						owner.get_tile_map().set_cell(Vector2i(x, y2), 0, Vector2i(1, 2), 0)
						var keyHole = KEY_HOLE.instantiate()
						keyHole.global_position = owner.get_tile_map().to_global(owner.tile_map.map_to_local(Vector2(x, y2)))
						keyHole.door.append(Vector2(x, y1))
						keyHole.door.append(Vector2(x - 2, y1))
						keyHole.door.append(Vector2(x - 1, y1))
						keyHole.door.append(Vector2(x + 1, y1))
						keyHole.door.append(Vector2(x + 2, y1))
						get_tree().current_scene.add_child(keyHole)
					elif x >= center - 2 and x <= center + 2 and x != center:
						owner.get_tile_map().set_cell(Vector2i(x, y2), 0, Vector2i(2, 0), 0)
					else:
						owner.get_tile_map().set_cell(Vector2i(x, y2), 0, Vector2i(1, 1), 0)

const I_APPLE = preload("res://scenes/i_apple.tscn")

func spawn_apple(p, mx, my):
	var a = I_APPLE.instantiate()
	a.position = p
	owner.add_child(a)
	entity[mx][my][a.get_path()] = a
