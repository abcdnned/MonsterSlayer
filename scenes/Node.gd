extends Node
class_name ShortLive

@export var life: float = 1
@onready var timer = $Timer

func _ready():
	timer.wait_time = life
	timer.start()

func _on_timer_timeout():
	get_parent().queue_free()
