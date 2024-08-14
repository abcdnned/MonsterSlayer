extends CharacterBody2D

@export var level = 1
@export var level_spawner: Spawner

const GOBLIN_WARRIOR_SPEAR = preload("res://scenes/goblin_warrior_spear.tscn")
@onready var timer = $Timer
var collision_shape_2d: CollisionShape2D

func _ready():
	# Create a CollisionShape2D child, set Shape to CircleShape2D and radius to 64.0 px
	create_collision_shape()
	add_to_group("Facility")
	
func create_collision_shape():
	# If there's an existing collision shape, free it first
	if collision_shape_2d:
		collision_shape_2d.queue_free()

	# Create a new CollisionShape2D
	collision_shape_2d = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 64.0
	collision_shape_2d.shape = circle_shape
	
	# Add the CollisionShape2D as a child of the character and ensure its position is set
	add_child(collision_shape_2d)
	collision_shape_2d.position = Vector2.ZERO

func _take_damage(d, v, source_position, tick):
	timer.start()
	# Delete the CollisionShape2D child
	for trigger in get_tree().get_nodes_in_group("Facility"):
		if trigger.collision_shape_2d:
				trigger.collision_shape_2d.queue_free()
				trigger.collision_shape_2d = null
		trigger.visible = false
	return [false, d]

func _on_timer_timeout():
	level_spawner._start_sapwner()

func _reset_trigger():
	for trigger in get_tree().get_nodes_in_group("Facility"):
		trigger.create_collision_shape()
		trigger.visible = true
