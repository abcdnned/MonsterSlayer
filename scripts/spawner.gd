extends Node
class_name Spawner

@export var unit_type: String = "res://scenes/goblin.tscn"
@export var internval_seconds = 3
@export var top_left = Vector2(-10, 10) * 128.0
@export var bottom_right = Vector2(10, -10) * 128.0
@export var enable = false

var level = 1
var spawn_count = 0
var MOB = null
const GOBLIN_ARCHER = preload("res://scenes/goblin_archer.tscn")
var max_melee: int = 3
var max_range: int = 1

func _ready():
	MOB = load(unit_type)

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
	return Vector2(x, y)
	
func do_spawn():
	if level == 1 and get_alive_mob_count("melee_mob") < max_melee:
		spawn_mob(MOB, "melee_mob")
	elif level == 2:
		max_melee = 2
		if get_alive_mob_count("melee_mob") < max_melee:
			spawn_mob(MOB, "melee_mob")
		if get_alive_mob_count("range_mob") < max_range:
			spawn_mob(GOBLIN_ARCHER, "range_mob")

func get_alive_mob_count(type):
	var mob_count = 0
	for mob in get_tree().get_nodes_in_group(type):
		if not mob.is_in_group("dead"):
			mob_count += 1
	return mob_count

func spawn_mob(type, group):
	var spawn_position = _get_spawn_position()
	var mob = type.instantiate()
	mob.add_to_group(group)
	mob.position = spawn_position
	owner.add_child(mob)
	mob.death.connect(owner._on_mob_death)


