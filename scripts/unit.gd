extends CharacterBody2D
class_name Unit

var state_machine

@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var animation_tree = $AnimationTree

var health := 2.0
@export var max_health := 3.0
var knock_back_force
var stun_ticks
var knock_back_source_position

signal health_change(health)
signal max_health_change(max_health)
signal death

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	health = max_health
	emit_signal("health_change", health)
	emit_signal("max_health_change", max_health)
	_sub_ready()

func _sub_ready():
	pass
	
func _take_damage(d, v, source_position, tick):
	self.knock_back_force = v
	self.knock_back_source_position = source_position
	self.stun_ticks = tick
	health -= d
	emit_signal("health_change", health)
	emit_signal("max_health_change", max_health)
	if health <= 0:
		knock_back_force = knock_back_force / 2
		animation_tree.set("parameters/conditions/dying", true)
		add_to_group("dead")
		emit_signal("death", self)
		_apply_dying_shader()
		_sub_dead()
	else:
		animation_tree.set("parameters/conditions/stun", true)
	return [false, d]
		
func _apply_dying_shader():
	var shader = load("res://shader/dying.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	sprite.material = shader_material
	
func _sub_dead():
	pass
	
func heal(h):
	health = clampf(health + h, 0, max_health)
	emit_signal("health_change", health)
		
