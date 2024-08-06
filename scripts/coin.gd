extends Pickable

@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var timer = $Timer
@export var amount_min: int = 8
@export var amount_max: int = 12
@onready var floating_text_util = $FloatingTextUtil

func pickup(player):
	super.pickup(player)
	if not visible:
		return
	visible = false
	audio_stream_player_2d.play()
	var m = randi_range(amount_min, amount_max)
	get_tree().current_scene.get_money(m)
	timer.start()
	floating_text_util.create_floating_text(player.global_position, "+" + str(m), Color.GOLD)
	

func _on_timer_timeout():
	queue_free()


