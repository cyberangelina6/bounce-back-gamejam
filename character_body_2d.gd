
extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -600.0
@export var jump_cut_multiplier = 0.4

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Left and right movement
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	# Variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

	# Move player
	move_and_slide()

	# Check for bounce pad collision
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.name == "cloud_bounce":
			if collision.get_normal().y < -0.5:
				velocity.y = -950.0
