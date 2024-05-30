extends Node
class_name Spawner

@export var unit_type: String = "res://scenes/goblin.tscn"
@export var internval_seconds = 10
@export var top_left = Vector2(-10, 10)
@export var bottom_right = Vector2(10, -10)
var enable = true


var spawn_count = 0
var MOB = null

func _ready():
	MOB = load(unit_type)

func _process(delta):
	if not enable:
		return
	spawn_count += 1
	if (spawn_count / 50 >= internval_seconds):
		print("spawn")
		spawn_count = 0
		var spawn_position = _get_spawn_position()
		var mob = MOB.instantiate()
		mob.position = spawn_position
		add_child(mob)
		mob.death.connect(owner._on_mob_death)

func _get_spawn_position():
	var x = randi_range(top_left.x, bottom_right.x)
	var y = randi_range(top_left.y, bottom_right.y)
	return Vector2(x, y)


