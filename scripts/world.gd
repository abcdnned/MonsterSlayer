# 2.0 Target
# Extract knock_back to a class
# Add sub class to inherit CharacterBody2D
# Goblin with bow

extends Node2D

@onready var player = $Player
@onready var tile_map = $TileMap
@onready var kill = $UI/Kill
@onready var winning_scene = $UI/WinningScene
@onready var spawner = $Spawner
@onready var lose_scene = $UI/LoseScene

const over_draw = 10
var kill_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_create_boime(-20, 20, -20, 20)
	randomize()

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
	if kill_count == 10:
		_win()

func _win():
	winning_scene.visible = true
	spawner.enable = false
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		mob.add_to_group("lose")
		
