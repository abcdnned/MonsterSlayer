extends Node

const GOBLIN = preload("res://scenes/goblin.tscn")
const GOBLIN_ARCHER = preload("res://scenes/goblin_archer.tscn")
const GOBLIN_WARRIOR_HAMMER = preload("res://scenes/goblin_warrior_hammer.tscn")
const GOBLIN_WARRIOR_SPEAR = preload("res://scenes/goblin_warrior_spear.tscn")
const VAULT = preload("res://scenes/vault.tscn")

var spawnable_area = []
var pre_spawn = {}
var pre_spawn_type = {}
var pre_spawn_respawn = {}
var pre_spawn_spawned = {}

func init_random_spawn():
	var map = owner.map.map
	for x in range(owner.map.MAP_V):
		for y in range(owner.map.MAP_H):
			if map[x][y] == 1:
				spawnable_area.append(Vector2(x, y))
	for v in spawnable_area:
		var i = randf_range(1, 100)
		if i <= 100:
			set_pre_spawn_mob(GOBLIN, v)
		else:
			set_pre_spawn_mob(GOBLIN_ARCHER, v)
	make_up_spawn()

func random_spawn(mx, my):
	if !pre_spawn_spawned[Vector2(mx, my)] or pre_spawn_respawn[Vector2(mx, my)]:
		do_spawn(pre_spawn_type[Vector2(mx, my)], pre_spawn[Vector2(mx, my)], mx, my)

func set_pre_spawn_mob(type, v):
	set_pre_spawn("mob", type, v)
	
func set_pre_spawn_item(type, v):
	set_pre_spawn("item", type, v)
	
func set_pre_spawn(cata, type, v, respawn = true):
	pre_spawn_type[v] = cata
	pre_spawn[v] = type
	pre_spawn_respawn[v] = respawn
	pre_spawn_spawned[v] = false
	print(str(v) + " " + str(type.resource_path))
		
func make_up_spawn():
	var v1 = randf_range(0, spawnable_area.size() - 3)
	var v2 = randf_range(v1, spawnable_area.size() - 2)
	var v3 = randf_range(v2, spawnable_area.size() - 1 )
	set_pre_spawn("mob", GOBLIN_WARRIOR_HAMMER, spawnable_area[v1], false)
	set_pre_spawn("mob", GOBLIN_WARRIOR_SPEAR, spawnable_area[v2], false)
	set_pre_spawn("item", VAULT, spawnable_area[v3])
		
func spawn_mob(type, mx, my):
	var spawn_position = get_regin_center(mx, my)
	var mob = type.instantiate()
	mob.add_to_group("mob")
	mob.position = spawn_position
	owner.mobs.add_child(mob)
	mob.death.connect(owner._on_mob_death)
	return mob

func spawn_item(type, mx, my):
	var spawn_position = get_regin_center(mx, my)
	var item = type.instantiate()
	item.position = spawn_position
	owner.items.add_child(item)
	return item

func do_spawn(cata, type, mx, my):
	var spawn_position = get_regin_center(mx, my)
	var e = type.instantiate()
	e.position = spawn_position
	if cata == "mob":
		e.add_to_group("mob")	
		owner.mobs.add_child(e)
		e.death.connect(owner._on_mob_death)
	elif cata == "item":
		owner.items.add_child(e)

func get_regin_center(x, y):
	var top_left = owner.map.cord_to_tile[Vector2(x,y)]["top_left"]
	var bottom_right = owner.map.cord_to_tile[Vector2(x,y)]["bottom_right"]
	var tile = Vector2((top_left.x + bottom_right.x) / 2, (top_left.y + bottom_right.y) / 2)
	return owner.get_tile_map().to_global(owner.get_tile_map().map_to_local(tile))
