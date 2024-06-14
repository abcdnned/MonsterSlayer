extends Unit

const SPEED = 400
@export var target: Node2D
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_yell = $death_yell
@onready var ray_cast_2d = $Sprite2D/RayCast2D
@onready var dagger_attack_sound = $dagger_attack_sound
@onready var damage_zone = $Sprite2D/damage_zone
@onready var dagger_sprite = $Sprite2D/DaggerSprite
@onready var wandering_timer = $WanderingTimer

var alert_range = 200.0
var wandering_loc = Vector2.ZERO

func _sub_ready():
	if not target:
		_find_target()
	wandering_loc = global_position
	wandering_timer.wait_time = randf_range(5, 10)

func _find_target():
	var nodes_in_group = get_tree().get_nodes_in_group("human")
	if target:
		return
	for node in nodes_in_group:
		if node.is_in_group("death"):
			continue
		if global_position.distance_to(node.global_position) <= alert_range:
			target = node
			break
	
func _process(delta):
	match state_machine.get_current_node():
		"chasing":
			if is_in_group("lose"):
				return
			if ray_cast_2d.is_colliding():
				if ray_cast_2d.get_collider().is_in_group("human"):
					animation_tree.set("parameters/conditions/attack", true)
		"attack":
			animation_tree.set("parameters/conditions/attack", false)

func _physics_process(delta):
	match state_machine.get_current_node():
		"wandering":
			_find_target()
			if target:
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
			if not target.is_in_group("dead") and not is_in_group("lose"):
				var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
				sprite.look_at(navigation_agent_2d.get_next_path_position())
				velocity = direction * SPEED
				move_and_slide()
			if global_position.distance_to(target.global_position) > alert_range * 2.0:
				target = null
				animation_tree.set("parameters/conditions/wandering", true)
				animation_tree.set("parameters/conditions/target", false)
		"dying":
			animation_tree.set("parameters/conditions/dying", false)
			var direction = knock_back_source_position.direction_to(global_position).normalized()
			velocity = direction * knock_back_force
			knock_back_force = clamp(knock_back_force - 10.0, 0.0, knock_back_force)
			move_and_slide()
			damage_zone.monitoring = false


func _on_timer_timeout():
	if target:
		navigation_agent_2d.target_position = target.global_position
	else:
		navigation_agent_2d.target_position = wandering_loc
	
func _dagger_attack():
	dagger_attack_sound.play()
		
func _sub_dead():
	dagger_sprite.lootable = true
	death_yell.play()


func _on_wandering_timer_timeout():
	var r = deg_to_rad(randf_range(0, 360.0))
	var d = randf_range(100.0, 1000.0)
	var x = global_position.x + cos(r) * d
	var y = global_position.y + sin(r) * d
	wandering_loc = Vector2(x, y)
	wandering_timer.wait_time = randf_range(5, 10)
				
