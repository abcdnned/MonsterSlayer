extends Node2D

@onready var damage_zone = $damage_zone


@export var dis = 800.0
@export var speed = 2000.0

func _ready():
	pass # Replace with function body.

func _process(delta):
	dis = clamp(dis - speed * delta, 0.0, dis)
	if dis == 0:
		queue_free()
	else:
		position += Vector2(cos(rotation), sin(rotation)) * speed * delta


func _on_damage_zone_hit():
	visible = false
	damage_zone.set_deferred("monitoring", false)

func _on_timer_timeout():
	queue_free()
