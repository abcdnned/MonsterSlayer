extends CharacterBody2D
class_name Unit

var state_machine
var previous_state = ""

@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var animation_tree = $AnimationTree

var health := 2.0
@export var max_health := 3.0
var stamina := 3
@export var max_stamina := 3
var knock_back_force
var stun_ticks
var knock_back_source_position
@export var stamina_restore_time: float = 2.0
var stamina_restore_timer: Timer

signal health_change(health)
signal max_health_change(max_health)
signal stamina_change(stamina)
signal max_stamina_change(max_stamina)
signal death

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	health = max_health
	stamina = max_stamina
	emit_signal("health_change", health)
	emit_signal("max_health_change", max_health)
	emit_signal("stamina_change", stamina)
	emit_signal("max_stamina_change", max_stamina)
	# Create and configure the StaminaRestoreTimer
	stamina_restore_timer = Timer.new()
	stamina_restore_timer.set_wait_time(stamina_restore_time)
	stamina_restore_timer.autostart = false
	stamina_restore_timer.set_one_shot(true)
	add_child(stamina_restore_timer)

	# Connect the timeout signal
	stamina_restore_timer.connect("timeout", _on_StaminaRestoreTimer_timeout)
	_sub_ready()

func _sub_ready():
	pass

func _process(delta):
	if stun_ticks && stun_ticks > 0:
		stun_ticks -= 1
		var direction = knock_back_source_position.direction_to(global_position).normalized()
		velocity = direction * knock_back_force
		knock_back_force = clamp(knock_back_force - 10.0, 0.0, knock_back_force)
		move_and_slide()
	else:
		animation_tree.set("parameters/conditions/unstun", true)
	_check_state_change()

func _check_state_change():
	var current_state = state_machine.get_current_node()
	if current_state != previous_state:
		_on_state_exited(previous_state)
		_on_state_entered(current_state)
		previous_state = current_state

func _on_state_entered(state_name: String):
	if state_name == "stun":
		_apply_stun_shader()
		_set_damage_zone_monitoring(false)

func _on_state_exited(state_name: String):
	if state_name == "stun":
		_clear_stun_shader()
		_set_damage_zone_monitoring(true)

func _set_damage_zone_monitoring(monitoring: bool):
	for child in get_children():
		if child is Area2D and child.get_filename() == "res://scenes/damage_zone.tscn":
			child.monitoring = monitoring
	
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
		state_machine.start("stun")
	return [false, d]
		
func _apply_dying_shader():
	var shader = load("res://shader/dying.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	sprite.material = shader_material

func _clear_stun_shader():
	sprite.material = null

func _apply_stun_shader():
	var shader = load("res://shader/stun.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	sprite.material = shader_material
	shader_material.set_shader_parameter("hit_effect", .35)
	
func _sub_dead():
	pass
	
func heal(h):
	health = clampf(health + h, 0, max_health)
	emit_signal("health_change", health)

func increase_max_health(h):
	max_health += h
	emit_signal("max_health_change", max_health)
	heal(h)
		
func consume(s):
	if stamina < s:
		return false
	stamina -= s
	emit_signal("stamina_change", stamina)
	stamina_restore_timer.start()
	return true

func increase_max_stamina(s):
	max_stamina += s
	emit_signal("max_stamina_change", max_stamina)
	stamina = stamina + s
	emit_signal("stamina_change", stamina)
	
func _on_StaminaRestoreTimer_timeout():
	stamina = max_stamina
	emit_signal("stamina_change", stamina)

