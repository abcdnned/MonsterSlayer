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
	for t in map_cord:
		if t["top_left"].x <= p.x and t["top_left"].y <= p.y and t["bottom_right"].x >= p.x and t["bottom_right"].y >= p.y:
			tiles[t["map"].x][t["map"].y].add_child(player)
			break

