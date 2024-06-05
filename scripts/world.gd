# 3.0 Target
# Map generage
# level preset
# Tab Map UI
# area control
# win game condition change to control area

extends Node2D

signal map_change

@onready var player = $Player
@onready var tile_map = $TileMap
@onready var kill = $UI/Kill
@onready var winning_scene = $UI/WinningScene
@onready var spawner = $Spawner
@onready var lose_scene = $UI/LoseScene
@onready var winning_sound = $WinningSound

const over_draw = 10
var kill_count = 0
var map = []
const START = Vector2(4, 4)
const MAP_H = 10
const MAP_V = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_create_boime(-20, 20, -20, 20)
	init_map()
	player.current_map_tile = START

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _create_boime(x1, x2, y1, y2):
	for x in range(x1 - over_draw, x2 + 1 + over_draw):
		for y in range(y1 - over_draw, y2 + 1 + over_draw):
			if x == x1 or x == x2 or y == y1 or y == y2:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 2), 0)
			else:
				var chance = randi_range(1, 100 + 10 + 5)
				if chance <= 10:
					tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), 0)
				elif chance <= 15:
					tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0), 0)
				else:
					tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 1), 0)

func _on_player_hero_death():
	lose_scene.visible = true

func _on_mob_death():
	kill_count += 1
	kill.text = "KILL " + str(kill_count)
	if kill_count > 10:
		spawner.level = 2
	if kill_count == 2:
		_win()

func _win():
	winning_scene.visible = true
	spawner.enable = false
	winning_sound.play()
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		mob.add_to_group("lose")
		
func init_map():
	var width = 10
	var height = 10

	for y in range(MAP_H):
		var row = []
		for x in range(MAP_V):
			row.append(0)  # 0 represents a default tile type
		map.append(row)
	init_plain_boime(2)
	emit_signal("map_change")
		
func init_plain_boime(d):
	var x = START.x
	var y = START.y
	var dir = randi_range(0, 3)
	for i in range(0, d):
		map[x][y] = 1
		match dir:
			0:
				x += 1
			1:
				y += 1
			2:
				x -= 1
			3:
				y -= 1
		dir = (dir + randi_range(1, 3)) % 4
		
	
		
