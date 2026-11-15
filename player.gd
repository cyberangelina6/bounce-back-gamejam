extends CharacterBody2D

const SPEED = 400.0
const JUMP_FORCE = -750.0
const GRAVITY = 2200.0

func _physics_process(delta):
	velocity.x = SPEED
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if is_on_floor() and Input.is_action_pressed("ui_accept"):
		velocity.y = JUMP_FORCE
	move_and_slide()
