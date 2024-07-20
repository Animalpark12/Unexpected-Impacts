extends CharacterBody2D

class_name SkeletonEnemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $SkeletonDealDamageArea/CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


var speed: int = 5
var health: int = 5
var damage_to_deal: int = 1
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_chased: bool = false
var dead: bool = false
var taking_damage: bool = false
var is_dealing_damage: bool = false
var is_roaming: bool = true
var player_in_area: bool = false

var direction: Vector2

var player: CharacterBody2D

var knockback_force = -65

func _ready():
	animated_sprite_2d.play("idle")

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0

	move(delta)
	handle_animation()
	move_and_slide()

func move(delta):
	if !dead:
		if !is_chased:
			velocity += direction * speed * delta
		elif !Global.playerAlive:
			is_chased = false
		elif is_chased and !taking_damage and Global.playerAlive:
			speed = 30
			var dir_to_player = position.direction_to(player.position) * speed
			var distance_to_player = abs(player.global_position.x - global_position.x)
			velocity.x = dir_to_player.x
			direction.x = abs(velocity.x) / velocity.x
			if distance_to_player <= 30:
				is_dealing_damage = true
				velocity.x = 0

		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
		is_roaming = true
	elif dead:
		velocity.x = 0

func handle_animation() -> void:
	if !dead and !taking_damage and !is_dealing_damage:
		if direction.x == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("walk")
			collision_shape_2d.disabled = true
		if direction.x <= -1:
			animated_sprite_2d.flip_h = true
			collision_shape_2d.position.x = -43.333
		elif direction.x >= 1:
			animated_sprite_2d.flip_h = false
			collision_shape_2d.position.x = 43.333
	elif !dead and !taking_damage and is_dealing_damage:
		animated_sprite_2d.play("attack")
		if animated_sprite_2d.frame == 7 or animated_sprite_2d.frame == 8:
			collision_shape_2d.disabled = false
		elif animated_sprite_2d.frame >= 6:
			audio_stream_player_2d.play()
		is_dealing_damage = false
	elif !dead and taking_damage and !is_dealing_damage:
		animated_sprite_2d.play("hit")
		await get_tree().create_timer(0.542).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		animated_sprite_2d.play("death")
		await get_tree().create_timer(1).timeout
		handle_death()

func handle_death() -> void:
	self.queue_free()

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_chased:
		direction = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func _on_skeleton_hit_box_area_entered(_area) -> void:
	take_damage(1)

func take_damage(damage) -> void:
	health -= damage
	taking_damage = true
	if health <= 0:
		dead = true

func _on_detect_area_body_entered(_body) -> void:
	is_chased = true
	player = Global.playerBody

func _on_detect_area_body_exited(_body) -> void:
	is_chased = false
	player = null

func _on_skeleton_deal_damage_area_body_entered(body) -> void:
	if body.has_method("take_damage"):
		body.take_damage(self)


func _on_deal_damage_near_body_entered(body) -> void:
	if body.has_method("take_damage"):
		body.take_damage(self)
