extends Unit

const SPEED := 600.0
const CHARGE_DIS := 800.0
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_yell = $death_yell
@onready var ray_cast_2d = $Sprite2D/RayCast2D
@onready var shoot_pos = $Sprite2D/ShootPos
@onready var arrow_woosh = $arrow_woosh
@onready var bow_release = $bow_release
const ARROW = preload("res://scenes/flying_arrow.tscn")
@onready var target_finder = $TargetFinder
@onready var wandering = $Wandering

var alert_range = 800.0

func _physics_process(delta):
	match state_machine.get_current_node():
		"wandering":
			if target_finder.target:
				animation_tree.set("parameters/conditions/target", true)
				animation_tree.set("parameters/conditions/wandering", false)
			else:
				animation_tree.set("parameters/conditions/target", false)
				animation_tree.set("parameters/conditions/wandering", true)
				if global_position.distance_to(navigation_agent_2d.get_next_path_position()) > 10.0:
					var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
					sprite.look_at(navigation_agent_2d.get_next_path_position())
					velocity = direction * SPEED
					move_and_slide()
		"chasing":
			animation_tree.set("parameters/conditions/chasing", false)
			if stamina == 0:
				animation_tree.set("parameters/conditions/run", true)
			if is_in_group("lose"):
				return
			if target_finder.target:
				if should_charge():
					if global_position.distance_to(target_finder.target.global_position) < 120:
						move_queue(2)
					else:
						animation_tree.set("parameters/conditions/charge", true)
				if not target_finder.target.is_in_group("dead") and not is_in_group("lose"):
					var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
					sprite.look_at(navigation_agent_2d.get_next_path_position())
					velocity = direction * SPEED
					move_and_slide()
			else:
				animation_tree.set("parameters/conditions/wandering", true)
				animation_tree.set("parameters/conditions/target", false)
		"charge":
			animation_tree.set("parameters/conditions/charge", false)
			if obstacle():
				animation_tree.set("parameters/conditions/chasing", true)
			if ray_cast_2d.is_colliding() and state_machine.get_current_play_position() >= 1.2 and consume(1):
				animation_tree.set("parameters/conditions/shoot", true)
			else:
				if global_position.distance_to(target_finder.target.global_position) > CHARGE_DIS:
					animation_tree.set("parameters/conditions/chasing", true)
				else:
					sprite.look_at(target_finder.target.global_position)
		"dying":
			animation_tree.set("parameters/conditions/dying", false)
			var direction = knock_back_source_position.direction_to(global_position).normalized()
			velocity = direction * knock_back_force
			knock_back_force = clamp(knock_back_force - 10.0, 0.0, knock_back_force)
			move_and_slide()
		"shoot":
			animation_tree.set("parameters/conditions/shoot", false)
		"run":
			if target_finder.target && stamina == 0:
				var direction = target_finder.target.global_position.direction_to(global_position).normalized()
				sprite.look_at(global_position + direction)
				velocity = direction * SPEED
				move_and_slide()
			else:
				animation_tree.set("parameters/conditions/unrun", true)

func should_charge():
	var dis = global_position.distance_to(target_finder.target.global_position) <= CHARGE_DIS * .8
	var hit = ray_cast()
	var obstacle = hit.size() > 0 and not hit.collider.is_in_group("human")
	return dis and not obstacle

func obstacle():
	if !ray_cast().collider:
		return false
	return not ray_cast().collider.is_in_group("human")

func ray_cast():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, target_finder.target.global_position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return result

func _on_timer_timeout():
	if target_finder.target:
		navigation_agent_2d.target_position = target_finder.target.global_position
	else:
		navigation_agent_2d.target_position = wandering.wandering_loc
	
func _sub_dead():
	death_yell.play()
	
func shoot():
	var arrow = ARROW.instantiate()
	arrow.global_position = shoot_pos.global_position
	arrow.global_rotation = shoot_pos.global_rotation
	bow_release.play()
	arrow_woosh.play()
	get_parent().add_child(arrow)

func _sub_ready():
	if level == 2:
		max_health = 4
		health = max_health
		max_stamina = 4
		stamina = max_health

func move_queue(t: int) -> void:
	var conditions = ["charge", "swap"]
	for i in range(t, 0, -1):  # This iterates from t to 0
		if consume(i):
			animation_tree.set("parameters/conditions/" + conditions[i - 1], true)
			return
