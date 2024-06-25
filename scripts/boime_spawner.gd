extends Node
class_name BoimeSpawner

@export var area_spawn_count = 2
@export var archer_spawn_count = 1
@export var heavy_spear_count = 1
@export var enable = true

const GOBLIN = preload("res://scenes/goblin.tscn")
const I_HEAVY_SPEAR = preload("res://scenes/i_heavy_spear.tscn")
const GOBLIN_ARCHER = preload("res://scenes/goblin_archer.tscn")
const GOBLIN_WARRIOR_SPEAR = preload("res://scenes/goblin_warrior_spear.tscn")

func _ready():
	if not enable:
		return
	await owner.ready
	#region Spawn Goblin
	for cord in owner.map.map_cord:
		for i in range(area_spawn_count):
			var top_left = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["top_left"].x, cord["top_left"].y)))
			var bottom_right = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["bottom_right"].x, cord["bottom_right"].y)))
			var x = randi_range(top_left.x, bottom_right.x)
			var y = randi_range(top_left.y, bottom_right.y)
			spawn_mob(GOBLIN, Vector2(x, y))
	#endregion
	#region Spawn Goblin archer
	for cord in owner.map.map_cord:
		for i in range(archer_spawn_count):
			var top_left = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["top_left"].x, cord["top_left"].y)))
			var bottom_right = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["bottom_right"].x, cord["bottom_right"].y)))
			var x = randi_range(top_left.x, bottom_right.x)
			var y = randi_range(top_left.y, bottom_right.y)
			spawn_mob(GOBLIN_ARCHER, Vector2(x, y))
	#endregion
	var i
	var cord
	var top_left
	var bottom_right
	var x
	var y
	#region Spawn Heavy Spear
	i = randi_range(0, owner.map.map_cord.size() - 1)
	cord = owner.map.map_cord[i]
	top_left = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["top_left"].x, cord["top_left"].y)))
	bottom_right = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["bottom_right"].x, cord["bottom_right"].y)))
	x = randi_range(top_left.x, bottom_right.x)
	y = randi_range(top_left.y, bottom_right.y)
	spawn_weapon(Vector2(x, y))
	#endregion
	#region Spawn Goblin Warrior
	i = randi_range(0, owner.map.map_cord.size() - 1)
	cord = owner.map.map_cord[i]
	top_left = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["top_left"].x, cord["top_left"].y)))
	bottom_right = owner.tile_map.to_global(owner.tile_map.map_to_local(Vector2(cord["bottom_right"].x, cord["bottom_right"].y)))
	x = randi_range(top_left.x, bottom_right.x)
	y = randi_range(top_left.y, bottom_right.y)
	spawn_mob(GOBLIN_WARRIOR_SPEAR, Vector2(x, y))
	#endregion
func spawn_mob(type, spawn_position):
	var mob = type.instantiate()
	mob.position = spawn_position
	owner.add_child(mob)
	mob.death.connect(owner._on_mob_death)
	
func spawn_weapon(spawn_position):
	var i = I_HEAVY_SPEAR.instantiate()
	i.position = spawn_position
	owner.add_child(i)
