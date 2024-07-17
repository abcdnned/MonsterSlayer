extends Unit

const SPEED = 400
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_yell = $death_yell
@onready var ray_cast_2d = $Sprite2D/RayCast2D
@onready var dagger_attack_sound = $dagger_attack_sound
@onready var damage_zone = $Sprite2D/damage_zone
@onready var dagger_sprite = $Sprite2D/DaggerSprite
@onready var target_finder = $TargetFinder
@onready var wandering = $Wandering
@onready var item_back = $Sprite2D/ItemBack

var alert_range = 500.0

	
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
			if target_finder.target:
				var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
				sprite.look_at(navigation_agent_2d.get_next_path_position())
				velocity = direction * SPEED
				move_and_slide()
			else:
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
	if target_finder.target:
		navigation_agent_2d.target_position = target_finder.target.global_position
	else:
		navigation_agent_2d.target_position = wandering.wandering_loc
	
func _dagger_attack():
	dagger_attack_sound.play()
		
func _sub_dead():
	dagger_sprite.lootable = true
	death_yell.play()
	drop_key()

func drop_key():
	if item_back.get_child_count() == 1:
		var key = item_back.get_child(0)
		key.lootable = true
		key.reparent(get_tree().current_scene, true)
		key.rotation_degrees = 0
				
