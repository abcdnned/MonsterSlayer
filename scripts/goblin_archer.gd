extends Unit

const SPEED := 400.0
const CHARGE_DIS := 800.0
@export var target: Node2D
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_yell = $death_yell
@onready var ray_cast_2d = $Sprite2D/RayCast2D
@onready var shoot_pos = $Sprite2D/ShootPos
@onready var arrow_woosh = $arrow_woosh
@onready var bow_release = $bow_release
const ARROW = preload("res://scenes/flying_arrow.tscn")


func _sub_ready():
	if not target:
		_find_target()

func _find_target():
	var nodes_in_group = get_tree().get_nodes_in_group("human")
	for node in nodes_in_group:
		if node.is_in_group("death"):
			continue
		target = node
		break

func _physics_process(delta):
	match state_machine.get_current_node():
		"chasing":
			animation_tree.set("parameters/conditions/chasing", false)
			if is_in_group("lose"):
				return
			if global_position.distance_to(target.global_position) <= CHARGE_DIS * .8:
				animation_tree.set("parameters/conditions/charge", true)
			elif not target.is_in_group("dead") and not is_in_group("lose"):
				var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
				sprite.look_at(navigation_agent_2d.get_next_path_position())
				velocity = direction * SPEED
				move_and_slide()
		"charge":
			animation_tree.set("parameters/conditions/charge", false)
			if ray_cast_2d.is_colliding() and state_machine.get_current_play_position() >= 1.2:
				if ray_cast_2d.get_collider().is_in_group("human"):
					animation_tree.set("parameters/conditions/shoot", true)
			else:
				if global_position.distance_to(target.global_position) > CHARGE_DIS:
					animation_tree.set("parameters/conditions/chasing", true)
				else:
					sprite.look_at(target.global_position)
		"dying":
			animation_tree.set("parameters/conditions/dying", false)
			var direction = knock_back_source_position.direction_to(global_position).normalized()
			velocity = direction * knock_back_force
			knock_back_force = clamp(knock_back_force - 10.0, 0.0, knock_back_force)
			move_and_slide()
		"shoot":
			animation_tree.set("parameters/conditions/shoot", false)


func _on_timer_timeout():
	navigation_agent_2d.target_position = target.global_position
	
func _play_dying_sound():
	death_yell.play()
	
func shoot():
	var arrow = ARROW.instantiate()
	arrow.global_position = shoot_pos.global_position
	arrow.global_rotation = shoot_pos.global_rotation
	bow_release.play()
	arrow_woosh.play()
	get_parent().add_child(arrow)
