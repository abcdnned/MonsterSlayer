extends Node
class_name BoimeSpawner

@export var enable = true
var area_spawn_count = 10
var apple_count = 2
var tree_count = 50
var tree_min_size = 3
var tree_max_size = 6
var apple_rate: float = 0

const GOBLIN = preload("res://scenes/goblin.tscn")
const I_HEAVY_SPEAR = preload("res://scenes/i_heavy_spear.tscn")
const GOBLIN_ARCHER = preload("res://scenes/goblin_archer.tscn")
const GOBLIN_WARRIOR_SPEAR = preload("res://scenes/goblin_warrior_spear.tscn")
const I_APPLE = preload("res://scenes/i_apple.tscn")
const I_COIN_SMALL = preload("res://scenes/i_coin_small.tscn")

func _ready():
	if not enable:
		return
	await owner.ready
	apple_rate = float(apple_count) / ((float(tree_min_size) + float(tree_max_size)) / 2.0 * float(tree_count))
	spawn_tree()
	spawn_goblin()

func spawn_tree():
	for i in range(tree_count):
		var top_left = owner.map.cord_to_tile[owner.map.level_cord["starter_plain"]["top_left"]]["top_left"]
		var bottom_right = owner.map.cord_to_tile[owner.map.level_cord["starter_plain"]["bottom_right"]]["bottom_right"]
		var x = randi_range(top_left.x, bottom_right.x)
		var y = randi_range(top_left.y, bottom_right.y)
		spawn_tree_snake(x, y)

func spawn_tree_snake(x, y):
	var cur = Vector2i(x, y)
	var c = randi_range(tree_min_size, tree_max_size)
	for i in range(c):
		owner.tile_map.set_cell(0, cur, 0, Vector2i(0, 2), 0)
		if randf_range(0, 1) <= apple_rate:
			var p = owner.tile_map.to_global(owner.tile_map.map_to_local(cur))
			spawn_apple(p)
		var d = randi_range(1, 4)
		if d == 1:
			cur = Vector2i(cur.x + 1, cur.y)
		elif d == 2:
			cur = Vector2i(cur.x - 1, cur.y)
		elif d == 3:
			cur = Vector2i(cur.x, cur.y + 1)
		else:
			cur = Vector2i(cur.x, cur.y - 1)

func spawn_apple(p):
	var a = I_APPLE.instantiate()
	a.position = p
	owner.add_child(a)

func spawn_goblin():
	for i in range(area_spawn_count):
		var top_left = tile_to_global(owner.map.cord_to_tile[owner.map.level_cord["starter_plain"]["top_left"]]["top_left"])
		var bottom_right = tile_to_global(owner.map.cord_to_tile[owner.map.level_cord["starter_plain"]["bottom_right"]]["bottom_right"])
		var mob = owner.spawn(GOBLIN, top_left, bottom_right)
		mob.death.connect(owner._on_mob_death)

func tile_to_global(v):
	return owner.tile_map.to_global(owner.tile_map.map_to_local(v))


