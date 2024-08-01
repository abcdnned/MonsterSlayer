extends Sprite2D

@onready var count_down_timer = $CountDownTimer
var is_blinking = false
var blink_speed = .4
var min_blink_speed = 0.06
var deceleration_factor = 0.04

# Called when the node enters the scene tree for the first time.
func _ready():
	count_down_timer.connect("timeout", _on_blink_timeout)
	count_down_timer.set_wait_time(blink_speed)
	count_down_timer.start()

# Timer timeout callback function
func _on_blink_timeout():
	is_blinking = not is_blinking
	get_material().set_shader_parameter("blink", is_blinking)

	# Increase the blink speed
	blink_speed = max(min_blink_speed, blink_speed - deceleration_factor)
	count_down_timer.set_wait_time(blink_speed)
	count_down_timer.start()

