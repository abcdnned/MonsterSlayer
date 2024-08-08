extends CharacterBody2D

@export var level = 1

signal trigger_level(level)

const GOBLIN_WARRIOR_SPEAR = preload("res://scenes/goblin_warrior_spear.tscn")
@onready var timer = $Timer
var collision_shape_2d: CollisionShape2D

func _ready():
	# Create a CollisionShape2D child, set Shape to CircleShape2D and radius to 64.0 px
	create_collision_shape()
	
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
	visible = false
	timer.start()
	# Delete the CollisionShape2D child
	if collision_shape_2d:
		collision_shape_2d.queue_free()
		collision_shape_2d = null
	return [false, d]

func _on_timer_timeout():
	emit_signal("trigger_level", 1)

func _on_goblin_army_1_spawner_level_1_finish():
	visible = true
	# Re-create the CollisionShape2D child, set Shape to CircleShape2D and radius to 64.0 px
	create_collision_shape()
	print("level finish")
