extends Node
class_name WhatAmIThinking

var thinking:int = 0

func _process(delta):
	thinking = (thinking + 1) % 100
