extends Node

const GOBLIN = preload("res://scenes/goblin.tscn")
const GOBLIN_ARCHER = preload("res://scenes/goblin_archer.tscn")
const GOBLIN_WARRIOR_HAMMER = preload("res://scenes/goblin_warrior_hammer.tscn")
const GOBLIN_WARRIOR_SPEAR = preload("res://scenes/goblin_warrior_spear.tscn")

var spawnable_area = []
var pre_spawn_mob = {}

func init_random_spawn():
	var map = owner.map.map
	for x in range(owner.map.MAP_V):
		for y in range(owner.map.MAP_H):
			if map[x][y] == 1:
				spawnable_area.append(Vector2(x, y))
	for v in spawnable_area:
		var i = randf_range(1, 100)
		if i <= 100:
			pre_spawn_mob[v] = GOBLIN_WARRIOR_HAMMER
			print(str(v) + " GOBLIN")
		else:
			pre_spawn_mob[v] = GOBLIN_ARCHER
			print(str(v) + " GOBLIN_ARCHER")
	#make_up_spawn()

func random_spawn(mx, my):
	spawn_mob(pre_spawn_mob[Vector2(mx, my)], mx, my)
		
func make_up_spawn():
	var v1 = randf_range(0, spawnable_area.size() - 1)
	var v2 = randf_range(v1, spawnable_area.size() - 1)
	pre_spawn_mob[spawnable_area[v1]] = GOBLIN_WARRIOR_HAMMER
	pre_spawn_mob[spawnable_area[v2]] = GOBLIN_WARRIOR_SPEAR
	print(str(spawnable_area[v1]) + " GOBLIN_WARRIOR_HAMMER")
	print(str(spawnable_area[v2]) + " GOBLIN_WARRIOR_SPEAR")
		
func spawn_mob(type, mx, my):
	var spawn_position = get_regin_center(mx, my)
	var mob = type.instantiate()
	mob.add_to_group("mob")
	mob.position = spawn_position
	owner.mobs.add_child(mob)
	mob.death.connect(owner._on_mob_death)
	return mob

func get_regin_center(x, y):
	var top_left = owner.map.cord_to_tile[Vector2(x,y)]["top_left"]
	var bottom_right = owner.map.cord_to_tile[Vector2(x,y)]["bottom_right"]
	var tile = Vector2((top_left.x + bottom_right.x) / 2, (top_left.y + bottom_right.y) / 2)
	return owner.get_tile_map().to_global(owner.get_tile_map().map_to_local(tile))
