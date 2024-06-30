extends Control

@onready var grid_container = $GridContainer

var map = []
var map_cord = []
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
	# Plain garrlery
	set_plain_tile(x, y)
	set_plain_tile(x + 1, y)
	set_plain_tile(x + 1, y + 1)
	set_plain_tile(x + 1, y + 2)
	set_plain_tile(x + 1, y + 3)
	set_plain_tile(x - 1, y)
	set_plain_tile(x, y - 1)
	# Goblin Forntie
	x -= 3
	set_plain_tile(x, y, true)
	set_plain_tile(x - 1, y, true)
	set_plain_tile(x - 1, y + 1, true)
	set_plain_tile(x, y + 1, true)
	set_plain_tile(x + 1, y + 1, true)
	set_plain_tile(x + 1, y, true)
	set_plain_tile(x + 1, y - 1, true)
	set_plain_tile(x, y - 1, true)
	set_plain_tile(x - 1, y - 1, true)
	
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
	for t in map_cord:
		if t["top_left"].x <= p.x and t["top_left"].y <= p.y and t["bottom_right"].x >= p.x and t["bottom_right"].y >= p.y:
			tiles[t["map"].x][t["map"].y].add_child(player)
			var top_left = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(t["top_left"].x, t["top_left"].y)))
			var bottom_right = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(t["bottom_right"].x, t["bottom_right"].y)))
			owner.spawner.top_left = top_left
			owner.spawner.bottom_right = bottom_right
			break

