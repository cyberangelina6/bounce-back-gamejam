extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -600.0
@export var jump_cut_multiplier = 0.4

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = $AnimatedSprite2D

# Portals: every Sprite2D in the level whose name starts with "portal"
@export var flip_time = 0.6
@onready var camera: Camera2D = $Camera2D
var portals = []
var in_portal = false
var upside_down = false
var day_night

func _ready():
	for node in get_parent().get_children():
		if node is Sprite2D and node.name.to_lower().begins_with("portal"):
			portals.append(node)
	day_night = preload("res://day_night.gd").new()
	add_child(day_night)
	day_night.setup(get_parent())

func _physics_process(delta):

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Left and right movement
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	# Face the way we're moving (keeps the last facing when idle)
	if direction != 0:
		$Sprite2D.flip_h = direction < 0

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		anim.play("jump")
	# Variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

	# Move player
	move_and_slide()

	# Check for bounce pad collision
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name == "cloud_bottom":
			velocity.y= -1100
		if collider.name == "cloud_bounce":
			if collision.get_normal().y < -0.5:
				velocity.y = -950.0

	_check_portal()

# Each time the bunny enters a portal: turn the whole view upside down and
# fade to the night art, or turn back upright and fade to day.
func _check_portal():
	var inside = false
	for portal in portals:
		if portal.get_rect().has_point(portal.to_local(global_position)):
			inside = true
	if inside and not in_portal:
		upside_down = not upside_down
		camera.ignore_rotation = false
		var t = create_tween()
		t.tween_property(camera, "rotation", PI if upside_down else 0.0, flip_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		day_night.set_night(upside_down, flip_time)
	in_portal = inside
