extends Node
class_name BoimeSpawner

@export var area_spawn_count = 5

const GOBLIN = preload("res://scenes/goblin.tscn")

func _ready():
	await owner.ready
	for cord in owner.map.map_cord:
		for i in range(area_spawn_count):
			var top_left = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["top_left"].x, cord["top_left"].y)))
			var bottom_right = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["bottom_right"].x, cord["bottom_right"].y)))
			var x = randi_range(top_left.x, bottom_right.x)
			var y = randi_range(top_left.y, bottom_right.y)
			spawn_mob(GOBLIN, Vector2(x, y))
			
func spawn_mob(type, spawn_position):
	var mob = type.instantiate()
	mob.position = spawn_position
	owner.add_child(mob)
	mob.death.connect(owner._on_mob_death)
