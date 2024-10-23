extends Node

const GOBLIN = preload("res://scenes/goblin.tscn")
const GOBLIN_ARCHER = preload("res://scenes/goblin_archer.tscn")
const GOBLIN_WARRIOR_HAMMER = preload("res://scenes/goblin_warrior_hammer.tscn")

func random_spawn(mx, my):
	spawn_mob(GOBLIN, mx, my)
		
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
