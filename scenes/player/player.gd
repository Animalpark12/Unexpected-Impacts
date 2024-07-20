extends CharacterBody2D

@onready var jump_velocity: float = ((2 * jump_height) / jump_time_to_peak) * -1
@onready var jump_gravity: float = ((-2 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1
@onready var fall_gravity: float = ((-2 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1

@onready var coyote_timer: Timer = $Coyote_Timer
@onready var jump_buffer_timer: Timer = $Jump_Buffer_Timer
@onready var hitbox_collision_shape_2d: CollisionShape2D = $HitBoxAttack/CollisionShape2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var speed: int = 150

var knockback_force: int = -100
var jump_height: float = 75
var jump_time_to_peak: float = 0.5
var jump_time_to_descent: float = 0.4
var coyote_time: float = 0.125
var jump_buffer_time: float = 0.2

var jump_available: bool = true
var jump_buffer: bool = false
var invincible: bool = false
var attacking: bool = false
var hurt: bool = false
var dead: bool = false

var enemy: CharacterBody2D

func _ready():
	Global.playerBody = self
	Global.playerAlive = true

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start(coyote_time)
		velocity.y += get_gravity() * delta
	elif is_on_floor():
		jump_available = true
		coyote_timer.stop()
		if jump_buffer:
			jump()
			jump_buffer = false

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if jump_available:
			jump()
		else:
			jump_buffer = true
			get_tree().create_timer(jump_buffer_time).timeout.connect(on_jump_buffer_timeout)
	elif Input.is_action_just_released("jump"):
		if velocity.y < 0:
			velocity.y = 0

	#Handle Attack
	if Input.is_action_pressed("attack"):
		attack()

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_backward", "move_foward")
	if direction:
		move(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if hurt:
		var knockback_dir = position.direction_to(enemy.position) * knockback_force
		velocity.x = knockback_dir.x

	handle_animation(direction, velocity.y)
	move_and_slide()

func move(direction: int) -> void:
	if !dead and !attacking:
		velocity.x = direction * speed
	elif attacking:
		velocity.x = 0

func handle_animation(direction: int, velocity: int) -> void:
	if !dead and !hurt and !attacking and is_on_floor():
		if direction == 0:
			animation_player.play("idle")
		else:
			animation_player.play("run")
		hitbox_collision_shape_2d.disabled = true
	elif !is_on_floor() and !dead:
		if velocity >= 0:
			animation_player.play("fall")
		elif velocity < 0:
			animation_player.play("jump")

	if direction <= -1 and !dead:
		sprite_2d.flip_h = true
		sprite_2d.offset.x = -9.25
		hitbox_collision_shape_2d.position.x = -22
	elif direction >= 1 and !dead:
		sprite_2d.flip_h = false
		sprite_2d.offset.x = 0
		hitbox_collision_shape_2d.position.x = 22

func attack() -> void:
	if !dead and is_on_floor():
		attacking = true
		animation_player.play("attack")
		await get_tree().create_timer(0.7).timeout
		attacking = false
		return

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0 else fall_gravity

func jump() -> void:
	if !dead:
		velocity.y = jump_velocity
		jump_available = false

func _on_coyote_timer_timeout() -> void:
	jump_available = false

func on_jump_buffer_timeout() -> void:
	jump_buffer = false

func powerup(type: int) -> void:
	match type:
		0:
			speed = 150
			jump_velocity = ((2 * jump_height) / jump_time_to_peak) * -1
			invincible = false
			animation_player.speed_scale = 0.9
			sprite_2d.modulate = Color("ffffff")
		1:
			speed = 110
			jump_velocity = 1.25*(((2 * jump_height) / jump_time_to_peak) * -1)
			invincible = false
			animation_player.speed_scale = 0.6
			sprite_2d.modulate = Color("ffffff")
		2:
			speed = 250
			jump_velocity = 0.85*(((2 * jump_height) / jump_time_to_peak) * -1)
			invincible = false
			animation_player.speed_scale = 1.15
			sprite_2d.modulate = Color("ffffff")
		3:
			speed = 150
			jump_velocity = ((2 * jump_height) / jump_time_to_peak) * -1
			invincible = true
			animation_player.speed_scale = 0.9
			sprite_2d.modulate = Color("ffffff32")

func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("Hit"):
		body.take_damage()

func take_damage(position: CharacterBody2D) -> void:
	if !invincible:
		Global.playerHealth -= 1
		enemy = position
		hurt = true
		animation_player.play("hit")
		$UI.update_health_bar(Global.playerHealth)
		await get_tree().create_timer(0.3).timeout
		hurt = false
		if Global.playerHealth <= 0:
			dead = true
			Global.playerAlive = false
			hitbox_collision_shape_2d.disabled = true
			velocity.x = 0
			animation_player.play("death")
			await get_tree().create_timer(1.25).timeout
			get_tree().reload_current_scene()
