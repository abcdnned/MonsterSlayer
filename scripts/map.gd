extends Control

@onready var grid_container = $GridContainer
var map = []
var cord_to_tile = {}
var tile_to_cord = {}
var level_cord = {}
var gate := {}
const START = Vector2(4, 4)
const MAP_H = 20
const MAP_V = 20
var tiles = []
var war_eye = []
const MAP_TILE = preload("res://scenes/map_tile.tscn")
var player = null
const KNIGHT_POTRIAT = preload("res://scenes/knight_potriat.tscn")
const KEY_HOLE = preload("res://scenes/key_hole.tscn")
const OBSTACLE_AGENT = preload("res://scenes/obstacle_agent.tscn")

func _ready():
	init_map()
	init_plain_boime()
	for x in range(0, 20):
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
	for y in range(MAP_H):
		var row = []
		for x in range(MAP_V):
			var tile = MAP_TILE.instantiate()
			grid_container.add_child(tile)
			tile.color = Color.BURLYWOOD
			row.append(tile)
		tiles.append(row)
		
func init_plain_boime():
	var x = START.x
	var y = START.y
	# Start Plain
	create_plain_chambler(Vector2(x - 1, y - 1), Vector2(x + 1, y + 1), false)
	level_cord["starter_plain"] = {"top_left": Vector2(x - 1, y - 1), "bottom_right": Vector2(x + 1, y + 1)}
	# Create Start Plain Sourth Gate
	create_gate(x + 1, y, 3)
	## Gallery to first small boss
	#set_plain_tile(x + 2, y)
	#set_plain_tile(x + 3, y)
	#set_plain_tile(x + 4, y)
	## Goblin Forntie
	#x += 6
	#create_plain_chambler(Vector2(x - 1, y - 1), Vector2(x + 1, y + 1), true)
	#level_cord["goblin_fontier"] = {"top_left": Vector2(x - 1, y - 1), "bottom_right": Vector2(x + 1, y + 1)}
	## Gallery to peaceful boime
	#set_plain_tile(x, y + 2)
	#set_plain_tile(x, y + 3)
	#set_plain_tile(x, y + 4)
	#y += 5
	#create_half_plain_chambler(Vector2(x, y), false)
	#level_cord["peaceful_boime"] = {"top_left": Vector2(x - 1, y), "bottom_right": Vector2(x, y + 1)}
	## Gallery to orb1
	#set_plain_tile(x + 1, y)
	#set_plain_tile(x + 2, y)
	#set_plain_tile(x + 3, y)
	## Gallery to orb2
	#set_plain_tile(x - 2, y + 1)
	#set_plain_tile(x - 3, y + 1)
	#set_plain_tile(x - 4, y + 1)
	#set_plain_tile(x - 5, y + 1)
	## Gallery to orb3
	#set_plain_tile(x - 4, y + 2)
	#set_plain_tile(x - 4, y + 3)
	#set_plain_tile(x - 4, y + 4)
	## final Gallery
	#set_plain_tile(x, y + 2)
	#set_plain_tile(x, y + 3)
	#set_plain_tile(x, y + 4)
	
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


func _on_player_map_pos_change(x, y):
	if player:
		player.queue_free()
	player = KNIGHT_POTRIAT.instantiate()
	var p = owner.tile_map.local_to_map(owner.tile_map.to_local(Vector2(x, y)))
	for key in cord_to_tile:
		if cord_to_tile[key]["top_left"].x <= p.x and cord_to_tile[key]["top_left"].y <= p.y and cord_to_tile[key]["bottom_right"].x >= p.x and cord_to_tile[key]["bottom_right"].y >= p.y:
			tiles[key.x][key.y].add_child(player)
			break


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

func create_boime(x1, x2, y1, y2, mx, my, from, route):
	for x in range(x1, x2 + 1):
		for y in range(y1, y2 + 1):
			var chance = randi_range(1, 100 + 10 + 5)
			tile_to_cord[Vector2(x, y)] = Vector2(mx, my)
			if chance <= 10:
				owner.tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), 0)
			elif chance <= 15:
				owner.tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0), 0)
			else:
				owner.tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 1), 0)
	route[Vector2(mx, my)] = null
	var size = x2 - x1 + 1
	if not cord_to_tile.has(Vector2(mx, my)):
		cord_to_tile[Vector2(mx, my)] = []
	cord_to_tile[Vector2(mx, my)] = {"top_left": Vector2(x1, y1), "bottom_right": Vector2(x2, y2)}
	# generate plain
	if from != 3 and map[mx + 1][my] == 1 and not route.has(Vector2(mx + 1, my)):
		create_boime(x1, x2, y1 + size, y2 + size, mx + 1, my, 1, route)
	if from != 2 and map[mx][my + 1] == 1 and not route.has(Vector2(mx, my + 1)):
		create_boime(x1 + size, x2 + size, y1, y2, mx, my + 1, 4, route)
	if from != 1 and map[mx - 1][my] == 1 and not route.has(Vector2(mx - 1, my)):
		create_boime(x1, x2, y1 - size, y2 - size, mx - 1, my, 3, route)
	if from != 4 and map[mx][my - 1] == 1 and not route.has(Vector2(mx, my - 1)):
		create_boime(x1 - size, x2 - size, y1, y2, mx, my - 1, 2, route)
	# generate wall
	if from != 3 and map[mx + 1][my] == 0:
		for x in range(x1, x2 + 1):
			owner.tile_map.set_cell(0, Vector2i(x, y2), 0, Vector2i(0, 2), 0)
	if from != 2 and map[mx][my + 1] == 0:
		for y in range(y1, y2 + 1):
			owner.tile_map.set_cell(0, Vector2i(x2, y), 0, Vector2i(0, 2), 0)
	if from != 1 and map[mx - 1][my] == 0:
		for x in range(x1, x2 + 1):
			owner.tile_map.set_cell(0, Vector2i(x, y1), 0, Vector2i(0, 2), 0)
	if from != 4 and map[mx][my - 1] == 0:
		for y in range(y1, y2 + 1):
			owner.tile_map.set_cell(0, Vector2i(x1, y), 0, Vector2i(0, 2), 0)
	# generate gate
	if gate.has(Vector2(mx, my)):
		match gate[Vector2(mx, my)]:
			1:
				var center = (x2 + x1 + 1) / 2
				for x in range(x1 + 1, x2):
					if x == center:
						owner.tile_map.set_cell(0, Vector2i(x, y1), 0, Vector2i(1, 2), 0)
						var keyHole = KEY_HOLE.instantiate()
						keyHole.global_position = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(x, y1)))
						keyHole.door.append(Vector2(x, y1))
						keyHole.door.append(Vector2(x - 2, y1))
						keyHole.door.append(Vector2(x - 1, y1))
						keyHole.door.append(Vector2(x + 1, y1))
						keyHole.door.append(Vector2(x + 2, y1))
						get_tree().current_scene.add_child(keyHole)
					elif x >= center - 2 and x <= center + 2 and x != center:
						owner.tile_map.set_cell(0, Vector2i(x, y1), 0, Vector2i(2, 0), 0)
					else:
						owner.tile_map.set_cell(0, Vector2i(x, y1), 0, Vector2i(1, 1), 0)
			3:
				var center = (x2 + x1 + 1) / 2
				for x in range(x1 + 1, x2):
					if x == center:
						owner.tile_map.set_cell(0, Vector2i(x, y2), 0, Vector2i(1, 2), 0)
						var keyHole = KEY_HOLE.instantiate()
						keyHole.global_position = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(x, y2)))
						keyHole.door.append(Vector2(x, y1))
						keyHole.door.append(Vector2(x - 2, y1))
						keyHole.door.append(Vector2(x - 1, y1))
						keyHole.door.append(Vector2(x + 1, y1))
						keyHole.door.append(Vector2(x + 2, y1))
						get_tree().current_scene.add_child(keyHole)
					elif x >= center - 2 and x <= center + 2 and x != center:
						owner.tile_map.set_cell(0, Vector2i(x, y2), 0, Vector2i(2, 0), 0)
					else:
						owner.tile_map.set_cell(0, Vector2i(x, y2), 0, Vector2i(1, 1), 0)


