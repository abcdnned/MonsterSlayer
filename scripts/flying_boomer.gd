extends Sprite2D

@onready var count_down_timer = $CountDownTimer
var is_blinking = false
var blink_speed = .2

@onready var damage_zone = $damage_zone
@export var dis = 800.0
@export var speed = 2000.0
const EXPLOD = preload("res://scenes/explod.tscn")

func _process(delta):
	if dis != 0:
		position += Vector2(cos(rotation), sin(rotation)) * speed * delta
		dis = clamp(dis - speed * delta, 0.0, dis)

func _on_damage_zone_hit():
	damage_zone.monitoring = false

func _on_timer_timeout():
	queue_free()

func _on_explod_timer_timeout():
	visible = false
	var e = EXPLOD.instantiate()
	e.global_position = global_position
	e.play("spawn")
	get_tree().current_scene.add_child(e)
	damage_zone.monitoring = true

# Called when the node enters the scene tree for the first time.
func _ready():
	count_down_timer.connect("timeout", _on_blink_timeout)
	count_down_timer.set_wait_time(blink_speed)
	count_down_timer.start()

# Timer timeout callback function
func _on_blink_timeout():
	is_blinking = not is_blinking
	get_material().set_shader_parameter("blink", is_blinking)
	count_down_timer.set_wait_time(blink_speed)
	count_down_timer.start()

func shoot():
	global_rotation = get_parent().get_parent().global_rotation
	reparent(get_tree().current_scene, true) # Add the instance to the root node first
	dis = get_global_mouse_position().distance_to(get_tree().current_scene.player.global_position)
	Tool.play_sound_2d(get_tree().current_scene, "res://sounds/weapon/dagger_woosh.mp3", global_position)

func _on_final_count_down_timer_timeout():
	blink_speed = .1
