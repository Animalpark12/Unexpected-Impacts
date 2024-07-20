extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


@export var type: int
@export var flipped: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	match type:
		0:
			animated_sprite_2d.play("cancel")
		1:
			animated_sprite_2d.play("jump")
		2:
			animated_sprite_2d.play("speed")
		3:
			animated_sprite_2d.play("invincible")

	if flipped:
		animated_sprite_2d.flip_h = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	if body.has_method("powerup"):
		body.powerup(type)
		queue_free()
