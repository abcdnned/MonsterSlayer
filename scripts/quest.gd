extends Label

@onready var quest_display = $QuestDisplay

func display_text(txt):
	text = txt
	visible = true
	quest_display.start()

func _on_quest_display_timeout():
	visible = false
