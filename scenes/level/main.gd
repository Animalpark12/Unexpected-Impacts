extends Node2D

signal world_changed(current_world, next_world)

var entered: bool = false

@export var next_world: PackedScene

func _process(_delta) -> void:
	if entered == true:
		if Input.is_action_pressed("change_world"):
			emit_signal("world_changed", next_world)

func _on_portal_body_entered(body: CharacterBody2D) -> void:
	entered = true

func _on_portal_body_exited(body: CharacterBody2D) -> void:
	entered = false
