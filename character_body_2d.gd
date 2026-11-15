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

# The level ends when the bunny touches this node (or any node in the "end" group)
@export var end_node_name = "award"
var finished = false

# Falling onto the cloud bottom opens the "Use Bounce Back?" popup.
# YES is only offered this many times; after that the only option is RESTART.
@export var bounce_backs = 2
@export var bounce_back_velocity = -1100.0
@onready var bounce_popup = get_parent().get_node_or_null("BouncePopup")
var cloud_touches = 0
var popup_open = false

func _ready():
	for node in get_parent().get_children():
		if node is Sprite2D and node.name.to_lower().begins_with("portal"):
			portals.append(node)
	day_night = preload("res://day_night.gd").new()
	add_child(day_night)
	day_night.setup(get_parent())
	if bounce_popup:
		bounce_popup.get_node("YesButton").pressed.connect(_on_bounce_back_yes)
		bounce_popup.get_node("NoButton").text = "RESTART"
		bounce_popup.get_node("NoButton").pressed.connect(_on_restart)
		var font = preload("res://Pixelify_Sans/static/PixelifySans-Bold.ttf")
		for button in [bounce_popup.get_node("YesButton"), bounce_popup.get_node("NoButton")]:
			button.add_theme_font_override("font", font)
			button.add_theme_font_size_override("font_size", 32)

func _physics_process(delta):

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Left and right movement
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	
	if is_on_floor() and direction != 0:
		anim.play("walk")

	# Face the way we're moving (keeps the last facing when idle)
	if direction != 0:
		anim.flip_h = direction < 0

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
		if collider.name == end_node_name or collider.is_in_group("end"):
			_finish_level()
			return
		if collider.name == "cloud_bottom":
			touch_cloud_bottom()
			return
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

# Stops the bunny and shows the end screen with its restart button.
func _finish_level():
	if finished:
		return
	finished = true
	set_physics_process(false)
	anim.stop()
	add_child(preload("res://endscreen.gd").new())

# Called when the bunny lands on the cloud bottom (also by area_2d.gd).
# Freezes the bunny and asks whether to bounce back or restart.
func touch_cloud_bottom():
	if popup_open or finished:
		return
	if bounce_popup == null:
		velocity.y = bounce_back_velocity
		return
	popup_open = true
	cloud_touches += 1
	set_physics_process(false)
	anim.stop()
	bounce_popup.get_node("YesButton").visible = cloud_touches <= bounce_backs
	_center_bounce_popup()
	bounce_popup.visible = true

# Puts the popup in the middle of the screen, whatever the window size:
# the pink panel centred, the buttons side by side in its lower half.
func _center_bounce_popup():
	var screen = get_viewport().get_visible_rect().size
	var center = screen / 2
	var dim = bounce_popup.get_node("ColorRect")
	dim.position = Vector2.ZERO
	dim.size = screen
	# The pink panel sits slightly up-left of the image's centre, so nudge it
	var art = bounce_popup.get_node("UseBounceBack")
	art.position = center + Vector2(105, 103) * art.scale
	var yes = bounce_popup.get_node("YesButton")
	var restart = bounce_popup.get_node("NoButton")
	var button_size = Vector2(210, 54)
	var gap = 30.0
	var y = center.y + 90
	yes.size = button_size
	restart.size = button_size
	if yes.visible:
		yes.position = Vector2(center.x - gap / 2 - button_size.x, y)
		restart.position = Vector2(center.x + gap / 2, y)
	else:
		restart.position = Vector2(center.x - button_size.x / 2, y)

func _on_bounce_back_yes():
	bounce_popup.visible = false
	popup_open = false
	velocity = Vector2(0, bounce_back_velocity)
	set_physics_process(true)

func _on_restart():
	get_tree().reload_current_scene()
