extends Node

const SFX_PLAYER = preload("res://scenes/sfx_player.tscn")
const SHORT_LIVE = preload("res://scenes/short_live.tscn")

# Static method to play a 2D sound
static func play_sound_2d(parent: Node, sound_path: String, position: Vector2):
	# Preload the audio file
	var sound = load(sound_path)
	
	# Create an instance of AudioStreamPlayer2D
	var audio_player = AudioStreamPlayer2D.new()
	
	# Set the audio stream to the preloaded sound
	audio_player.stream = sound
	
	# Set the position where you want to play the sound
	audio_player.position = position
	
	# Add the audio player to the scene
	parent.add_child(audio_player)
	
	# Play the sound
	audio_player.play()
	var short_life = SHORT_LIVE.instantiate()
	audio_player.add_child(short_life)
	
static func remove_all_children(p):
	for child in p.get_children():
		p.remove_child(child)
		child.queue_free()
