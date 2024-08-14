extends CharacterBody2D

var collision_shape_2d: CollisionShape2D

func _ready():
	create_collision_shape()
	add_to_group("Facility")
	
func create_collision_shape():
	# If there's an existing collision shape, free it first
	if collision_shape_2d:
		collision_shape_2d.queue_free()
