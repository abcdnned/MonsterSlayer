extends Node2D

func emit():
	$CPUParticles2D.emitting = true

func set_amount(n):
	$CPUParticles2D.amount = n
