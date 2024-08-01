extends Node2D

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
