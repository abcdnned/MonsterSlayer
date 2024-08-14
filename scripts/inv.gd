extends Control

var hover: Panel
@onready var inv_slots = $GridContainer/InvSlots
@onready var inv_slots_2 = $GridContainer/InvSlots2
@onready var inv_slots_3 = $GridContainer/InvSlots3
@onready var inv_slots_4 = $GridContainer/InvSlots4

func _ready():
	inv_slots.connect("mouse_entered", _on_inv_slots_mouse_entered)
	inv_slots.connect("mouse_exited", _on_inv_slots_mouse_exited)
	inv_slots_2.connect("mouse_entered", _on_inv_slots_2_mouse_entered)
	inv_slots_2.connect("mouse_exited", _on_inv_slots_2_mouse_exited)
	inv_slots_3.connect("mouse_entered", _on_inv_slots_3_mouse_entered)
	inv_slots_3.connect("mouse_exited", _on_inv_slots_3_mouse_exited)
	inv_slots_4.connect("mouse_entered", _on_inv_slots_4_mouse_entered)
	inv_slots_4.connect("mouse_exited", _on_inv_slots_4_mouse_exited)
	

func _process(delta):
	if Input.is_action_pressed("tab"):
		visible = true
	else:
		visible = false

func _on_inv_slots_mouse_entered():
	hover = inv_slots

func _on_inv_slots_mouse_exited():
	hover = null

func _on_inv_slots_2_mouse_entered():
	hover = inv_slots_2

func _on_inv_slots_2_mouse_exited():
	hover = null

func _on_inv_slots_3_mouse_entered():
	hover = inv_slots_3

func _on_inv_slots_3_mouse_exited():
	hover = null

func _on_inv_slots_4_mouse_entered():
	hover = inv_slots_4

func _on_inv_slots_4_mouse_exited():
	hover = null
