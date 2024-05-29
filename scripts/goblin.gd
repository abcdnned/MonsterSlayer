extends CharacterBody2D

signal mob_death

const SPEED = 400
@export var target: Node2D
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var goblin_sprite = $GoblinSprite
@onready var animation_tree = $AnimationTree
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_yell = $death_yell
@onready var ray_cast_2d = $GoblinSprite/RayCast2D
@onready var dagger_attack_sound = $dagger_attack_sound

var state_machine
var source_position
var v

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	if not target:
		_find_target()

func _find_target():
	var nodes_in_group = get_tree().get_nodes_in_group("human")
	for node in nodes_in_group:
		if node.is_in_group("death"):
			continue
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
		"chasing":
			if not target.is_in_group("dead") and not is_in_group("lose"):
				var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
				goblin_sprite.look_at(navigation_agent_2d.get_next_path_position())
				velocity = direction * SPEED
				move_and_slide()
		"dying":
			animation_tree.set("parameters/conditions/dying", false)
			var direction = source_position.direction_to(global_position).normalized()
			velocity = direction * v
			v = clamp(v - 10.0, 0.0, v)
			move_and_slide()


func _on_timer_timeout():
	navigation_agent_2d.target_position = target.global_position
	
func _take_damage(d, v, source_position, ticks):
	self.v = v / 2
	self.source_position = source_position
	emit_signal("mob_death")
	animation_tree.set("parameters/conditions/dying", true)
	
func _apply_dying_shader():
	var shader = load("res://shader/dying.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	goblin_sprite.material = shader_material
	
func _play_dying_sound():
	death_yell.play()
	
func _dagger_attack():
	dagger_attack_sound.play()
