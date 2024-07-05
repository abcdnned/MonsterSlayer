extends Node
class_name BoimeSpawner

@export var enable = true
var area_spawn_count = 0
var archer_spawn_count = 0
var apple_count = 2
var tree_count = 5
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
	spawn_goblin()
	spawn_goblin_archer()
	spawn_coins()
	spawn_tree()

func spawn_coins():
	for i in range(10):
		owner.spawn(I_COIN_SMALL, owner.GOBLIN_ARMY_TOP_LEFT, owner.GOBLIN_ARMY_BOTTOM_RIGHT)

func spawn_tree():
	for cord in owner.map.map_cord:
		for i in range(tree_count):
			var x = randi_range(cord["top_left"].x, cord["bottom_right"].x)
			var y = randi_range(cord["top_left"].y, cord["bottom_right"].y)
			spawn_tree_snake(x, y, cord)

func spawn_tree_snake(x, y, cord):
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

func spawn_goblin_warrior():
	var i = randi_range(0, owner.map.map_cord.size() - 1)
	var cord = owner.map.map_cord[i]
	var top_left = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["top_left"].x, cord["top_left"].y)))
	var bottom_right = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["bottom_right"].x, cord["bottom_right"].y)))
	var x = randi_range(top_left.x, bottom_right.x)
	var y = randi_range(top_left.y, bottom_right.y)
	spawn_mob(GOBLIN_WARRIOR_SPEAR, Vector2(x, y))

func spawn_goblin():
	for cord in owner.map.map_cord:
		for i in range(area_spawn_count):
			var top_left = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["top_left"].x, cord["top_left"].y)))
			var bottom_right = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["bottom_right"].x, cord["bottom_right"].y)))
			var x = randi_range(top_left.x, bottom_right.x)
			var y = randi_range(top_left.y, bottom_right.y)
			spawn_mob(GOBLIN, Vector2(x, y))	

func spawn_goblin_archer():
	for cord in owner.map.map_cord:
		for i in range(archer_spawn_count):
			var top_left = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["top_left"].x, cord["top_left"].y)))
			var bottom_right = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["bottom_right"].x, cord["bottom_right"].y)))
			var x = randi_range(top_left.x, bottom_right.x)
			var y = randi_range(top_left.y, bottom_right.y)
			spawn_mob(GOBLIN_ARCHER, Vector2(x, y))

func spawn_heavy_spear():
	var i = randi_range(0, owner.map.map_cord.size() - 1)
	var cord = owner.map.map_cord[i]
	var top_left = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["top_left"].x, cord["top_left"].y)))
	var bottom_right = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["bottom_right"].x, cord["bottom_right"].y)))
	var x = randi_range(top_left.x, bottom_right.x)
	var y = randi_range(top_left.y, bottom_right.y)
	spawn_weapon(Vector2(x, y))

func spawn_mob(type, spawn_position):
	var mob = type.instantiate()
	mob.position = spawn_position
	owner.add_child(mob)
	mob.death.connect(owner._on_mob_death)
	
func spawn_weapon(spawn_position):
	var i = I_HEAVY_SPEAR.instantiate()
	i.position = spawn_position
	owner.add_child(i)
