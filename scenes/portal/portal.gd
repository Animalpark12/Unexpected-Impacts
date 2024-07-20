extends Area2D

var entered: bool = false

@export var next_world: PackedScene

func _process(_delta) -> void:
	if entered == true:
		if Input.is_action_pressed("change_world"):
			get_tree().change_scene_to_packed(next_world)

func _on_portal_body_entered(_body: CharacterBody2D) -> void:
	entered = true

func _on_portal_body_exited(_body: CharacterBody2D) -> void:
	entered = false
