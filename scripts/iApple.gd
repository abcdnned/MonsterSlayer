extends Lootable

var p = null
const FLYING_DAGGER = preload("res://scenes/flying_dagger.tscn")
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func _ready():
	lootable = true

func shoot():
	p.heal(1.0)
	reparent(get_tree().current_scene, true)
	p = null
	visible = false
	audio_stream_player_2d.play()

func loot(player):
	if visible and player.item_handle.get_child_count() == 0:
		reparent(player.item_handle, false)
		position = Vector2(0, 0)
		player.gaven_new_item(self)
		p = player


func _on_timer_timeout():
	queue_free()
