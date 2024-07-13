extends Node2D

@onready var damage_zone = $damage_zone


var dis = 800.0
const SPEED = 2000.0

func _ready():
	pass # Replace with function body.

func _process(delta):
	dis = clamp(dis - SPEED * delta, 0.0, dis)
	if dis == 0:
		queue_free()
	else:
		position += Vector2(cos(rotation), sin(rotation)) * SPEED * delta


func _on_damage_zone_hit():
	visible = false
	damage_zone.monitoring = false

func _on_timer_timeout():
	queue_free()
