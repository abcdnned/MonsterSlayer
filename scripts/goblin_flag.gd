extends CharacterBody2D

const GOBLIN_WARRIOR_SPEAR = preload("res://scenes/goblin_warrior_spear.tscn")
@onready var timer = $Timer
@onready var collision_shape_2d = $CollisionShape2D

func _take_damage(d, v, source_position, tick):
	visible = false
	collision_shape_2d.disabled = true
	timer.start()
	return [false, d]

func _on_timer_timeout():
	var mob = get_tree().current_scene.spawn(GOBLIN_WARRIOR_SPEAR, global_position, global_position)
	mob.death.connect(get_tree().current_scene._on_mob_death)
	queue_free()
