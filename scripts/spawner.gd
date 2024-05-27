extends Node
class_name Spawner

@export var unit_type: String = "res://scenes/goblin.tscn"
@export var internval_seconds = 10
@export var top_left = Vector2(-10, 10)
@export var bottom_right = Vector2(10, -10)
@onready var spawner = $"."
@onready var world = $".."
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
		mob.mob_death.connect(_on_mob_death)
		mob.position = spawn_position
		spawner.add_child(mob)

func _get_spawn_position():
	var x = randi_range(top_left.x, bottom_right.x)
	var y = randi_range(top_left.y, bottom_right.y)
	return Vector2(x, y)

func _on_mob_death():
	world._on_mob_death()

