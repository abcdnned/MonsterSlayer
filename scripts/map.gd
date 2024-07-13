extends Control

@onready var grid_container = $GridContainer

var map = []
var cord = []
var tile_to_cord = {}
const START = Vector2(4, 4)
const MAP_H = 20
const MAP_V = 20
var tiles = []
var war_eye = []
const MAP_TILE = preload("res://scenes/map_tile.tscn")
var player = null
const KNIGHT_POTRIAT = preload("res://scenes/knight_potriat.tscn")

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
	create_plain_chambler(x, y, false)
	# Gallery to first small boss
	set_plain_tile(x + 2, y)
	set_plain_tile(x + 3, y)
	set_plain_tile(x + 4, y)
	# Goblin Forntie
	x += 6
	create_plain_chambler(x, y, true)


func create_plain_chambler(x, y, war_eye = false):
	set_plain_tile(x, y, war_eye)
	set_plain_tile(x - 1, y, war_eye)
	set_plain_tile(x - 1, y + 1, war_eye)
	set_plain_tile(x, y + 1, war_eye)
	set_plain_tile(x + 1, y + 1, war_eye)
	set_plain_tile(x + 1, y, war_eye)
	set_plain_tile(x + 1, y - 1, war_eye)
	set_plain_tile(x, y - 1, war_eye)
	set_plain_tile(x - 1, y - 1, war_eye)
	

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
	for t in cord:
		if t["top_left"].x <= p.x and t["top_left"].y <= p.y and t["bottom_right"].x >= p.x and t["bottom_right"].y >= p.y:
			tiles[t["map"].x][t["map"].y].add_child(player)
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
	cord.append({"map": Vector2(mx, my), "top_left": Vector2(x1, y1), "bottom_right": Vector2(x2, y2)})
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
