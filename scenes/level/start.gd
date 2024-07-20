extends CanvasLayer

@onready var label: Label = $Control/Label


func _on_play_again_button_up():
	get_tree().change_scene_to_file("res://scenes/level/main.tscn")


func _on_quit_button_up():
	get_tree().quit()
