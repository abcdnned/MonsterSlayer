extends Unit

const SPEED = 400
@onready var collision_shape_2d = $CollisionShape2D

	

func _physics_process(delta):
	super._process(delta)
	match state_machine.get_current_node():
		"chasing":
			animation_tree.set("parameters/conditions/unstun", false)
		"stun":
			animation_tree.set("parameters/conditions/stun", false)
			if stun_ticks > 0:
				stun_ticks -= 1
				var direction = knock_back_source_position.direction_to(global_position).normalized()
				velocity = direction * knock_back_force
				knock_back_force = clamp(knock_back_force - 10.0, 0.0, knock_back_force)
				move_and_slide()
			else:
				animation_tree.set("parameters/conditions/unstun", true)
