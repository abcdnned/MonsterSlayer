extends Node
class_name Spawner

@export var internval_seconds = 3
@export var top_left = Vector2(-10, 10) * 128.0
@export var bottom_right = Vector2(10, -10) * 128.0
@export var enable = false

var wave = 1
var spawn_count = 0
const GOBLIN = preload("res://scenes/goblin.tscn")
const GOBLIN_ARCHER = preload("res://scenes/goblin_archer.tscn")
const GOBLIN_WARRIOR_SPEAR = preload("res://scenes/goblin_warrior_spear.tscn")

func _process(delta):
	if not enable:
		return
	spawn_count += 1
	if (spawn_count / 50 >= internval_seconds):
		spawn_count = 0
		do_spawn()

func _get_spawn_position():
	var x = randf_range(top_left.x, bottom_right.x)
	var y = randf_range(bottom_right.y, top_left.y)
	var p = owner.tile_map.local_to_map(owner.tile_map.to_local(Vector2(x, y)))
	while owner.tile_map.get_cell_atlas_coords(0, p) == Vector2i(0, 2):
		x = randf_range(top_left.x, bottom_right.x)
		y = randf_range(bottom_right.y, top_left.y)
		p = owner.tile_map.local_to_map(owner.tile_map.to_local(Vector2(x, y)))
	return Vector2(x, y)
	
func do_spawn():
	if wave <= 5 and get_alive_mob_count("melee_mob") + get_alive_mob_count("range_mob") < 9:
		spawn_tracker(GOBLIN, "melee_mob")
		spawn_tracker(GOBLIN, "melee_mob")
		spawn_tracker(GOBLIN, "melee_mob")
		wave += 1
	elif wave <= 10 and get_alive_mob_count("melee_mob") + get_alive_mob_count("range_mob") < 9:
		spawn_tracker(GOBLIN, "melee_mob")
		spawn_tracker(GOBLIN, "melee_mob")
		spawn_tracker(GOBLIN_ARCHER, "range_mob")
		wave += 1
	elif wave == 11 and get_alive_mob_count("melee_mob") + get_alive_mob_count("range_mob") < 1:
		spawn_tracker(GOBLIN_WARRIOR_SPEAR, "melee_mob")
		wave += 1
	else:
		enable = false

func get_alive_mob_count(type):
	var mob_count = 0
	for mob in get_tree().get_nodes_in_group(type):
		if not mob.is_in_group("dead"):
			mob_count += 1
	return mob_count

func spawn_tracker(type, group):
	var mob = spawn_mob(type, group)
	mob.alert_range = 1000000

func spawn_mob(type, group):
	var spawn_position = _get_spawn_position()
	var mob = type.instantiate()
	mob.add_to_group(group)
	mob.position = spawn_position
	owner.add_child(mob)
	mob.death.connect(owner._on_mob_death)
	return mob


