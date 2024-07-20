extends CanvasLayer

@onready var label: Label = $Control/Label

func _ready():
	if Global.playerHealth <= 0:
		label.text = "You are Dead"
	else:
		label.text = "The end"


func _on_play_again_button_up():
	get_tree().change_scene_to_file("res://scenes/level/main.tscn")


func _on_quit_button_up():
	get_tree().quit()
