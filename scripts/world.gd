# 3.4 target
# TODO fetch switch item


extends Node2D

@onready var player = $Player
@onready var tile_map = $TileMap
@onready var kill = $UI/Kill
@onready var winning_scene = $UI/WinningScene
@onready var spawner = $Spawner
@onready var lose_scene = $UI/LoseScene
@onready var winning_sound = $WinningSound
@onready var map = $UI/Map

var kill_count = 0


# Called when the node enters the scene tree for the first time.
#   1
# 4   2
#   3
func _ready():
	randomize()
	_create_boime(-10, 10, -10, 10, map.map, 4, 4, 0, map.map_cord)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _create_boime(x1, x2, y1, y2, map, mx, my, from, cord):
	for x in range(x1, x2 + 1):
		for y in range(y1, y2 + 1):
			var chance = randi_range(1, 100 + 10 + 5)
			if chance <= 10:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), 0)
			elif chance <= 15:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0), 0)
			else:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 1), 0)
	var size = x2 - x1 + 1
	cord.append({"map": Vector2(mx, my), "top_left": Vector2(x1, y1), "bottom_right": Vector2(x2, y2)})
	# generate plain
	if from != 3 and map[mx + 1][my] == 1:
		_create_boime(x1, x2, y1 + size, y2 + size, map, mx + 1, my, 1, cord)
	if from != 2 and map[mx][my + 1] == 1:
		_create_boime(x1 + size, x2 + size, y1, y2, map, mx, my + 1, 4, cord)
	if from != 1 and map[mx - 1][my] == 1:
		_create_boime(x1, x2, y1 - size, y2 - size, map, mx - 1, my, 3, cord)
	if from != 4 and map[mx][my - 1] == 1:
		_create_boime(x1 - size, x2 - size, y1, y2, map, mx, my - 1, 2, cord)
	# generate wall
	if from != 3 and map[mx + 1][my] == 0:
		for x in range(x1, x2 + 1):
			tile_map.set_cell(0, Vector2i(x, y2 + 1), 0, Vector2i(0, 2), 0)
	if from != 2 and map[mx][my + 1] == 0:
		for y in range(y1, y2 + 1):
			tile_map.set_cell(0, Vector2i(x2 + 1, y), 0, Vector2i(0, 2), 0)
	if from != 1 and map[mx - 1][my] == 0:
		for x in range(x1, x2 + 1):
			tile_map.set_cell(0, Vector2i(x, y1 - 1), 0, Vector2i(0, 2), 0)
	if from != 4 and map[mx][my - 1] == 0:
		for y in range(y1, y2 + 1):
			tile_map.set_cell(0, Vector2i(x1 - 1, y), 0, Vector2i(0, 2), 0)

func _on_player_hero_death():
	lose_scene.visible = true

func _on_mob_death():
	kill_count += 1
	kill.text = "KILL " + str(kill_count)
	if kill_count > 10:
		spawner.level = 2
	if kill_count == 20:
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
