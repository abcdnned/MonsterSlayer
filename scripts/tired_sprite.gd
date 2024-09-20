extends Sprite2D

func _ready():
	position = Vector2(70, -70)

func _process(delta):
	if owner.stamina == 0:
		visible = true
	else:
		visible = false
		
