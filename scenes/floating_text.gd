extends Control

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", -200, 1).as_relative()

func _on_timer_timeout():
	queue_free()
