extends Node
class_name Spawner

@export var internval_seconds = 3
@export var enable = false

signal level_1_finish

var wave = 1
const MAX_WAVE = 11
var spawn_count = 0
const GOBLIN = preload("res://scenes/goblin.tscn")
const GOBLIN_ARCHER = preload("res://scenes/goblin_archer.tscn")
const GOBLIN_WARRIOR_HAMMER = preload("res://scenes/goblin_warrior_hammer.tscn")

func _process(delta):
	if not enable:
		return
	spawn_count += 1
	if (spawn_count / 50 >= internval_seconds):
		spawn_count = 0
		do_spawn()
	
func do_spawn():
	if wave == 1 and get_alive_mob_count("melee_mob") + get_alive_mob_count("range_mob") < 3:
		spawn_tracker(GOBLIN, "melee_mob")
		spawn_tracker(GOBLIN, "melee_mob")
		spawn_tracker(GOBLIN, "melee_mob")
		wave += 1
	elif wave <= MAX_WAVE - 1 and get_alive_mob_count("melee_mob") + get_alive_mob_count("range_mob") < 3:
		spawn_tracker(GOBLIN, "melee_mob")
		spawn_tracker(GOBLIN, "melee_mob")
		spawn_tracker(GOBLIN_ARCHER, "range_mob")
		wave += 1
	elif wave == MAX_WAVE and get_alive_mob_count("melee_mob") + get_alive_mob_count("range_mob") < 1:
		spawn_tracker(GOBLIN_WARRIOR_HAMMER, "melee_mob")
		wave += 1
	elif get_alive_mob_count("melee_mob") + get_alive_mob_count("range_mob") == 0:
		enable = false
		emit_signal("level_1_finish")
		owner.war_eye.visible = false
		

func get_alive_mob_count(type):
	var mob_count = 0
	for mob in get_tree().get_nodes_in_group(type):
		if not mob.is_in_group("dead"):
			mob_count += 1
	return mob_count

func spawn_tracker(type, group):
	var mob = spawn_mob(type, group)
	mob.alert_range = 100000

func spawn_mob(type, group):
	var top_left = get_spawn_top_left()
	var bottom_right = get_spawn_bottom_right()
	var spawn_position = owner.map.get_spawn_position(top_left, bottom_right)
	var mob = type.instantiate()
	mob.add_to_group(group)
	mob.position = spawn_position
	owner.add_child(mob)
	mob.death.connect(owner._on_mob_death)
	return mob

func get_spawn_top_left():
	var tile = owner.map.cord_to_tile[owner.map.level_cord["starter_plain"]["top_left"]]["top_left"]
	return owner.tile_map.to_global(owner.tile_map.map_to_local(tile))

func get_spawn_bottom_right():
	var tile = owner.map.cord_to_tile[owner.map.level_cord["starter_plain"]["bottom_right"]]["bottom_right"]
	return owner.tile_map.to_global(owner.tile_map.map_to_local(tile))

func _on_goblin_flag_1_trigger_level(level):
	print("level start")
	enable = true
	owner.war_eye.visible = true
	wave = 1
