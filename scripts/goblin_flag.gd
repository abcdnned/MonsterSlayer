extends CharacterBody2D

@export var level = 1

signal trigger_level(level)

const GOBLIN_WARRIOR_SPEAR = preload("res://scenes/goblin_warrior_spear.tscn")
@onready var timer = $Timer
@onready var collision_shape_2d = $CollisionShape2D

func _take_damage(d, v, source_position, tick):
	visible = false
	collision_shape_2d.disabled = true
	timer.start()
	return [false, d]

func _on_timer_timeout():
	emit_signal("trigger_level", 1)

func _on_goblin_army_1_spawner_level_1_finish():
	visible = true
	collision_shape_2d.disabled = false
