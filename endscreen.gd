extends CanvasLayer
# The "Nice job!" screen with a restart button. Built in code and shown by
# the player script when the bunny reaches the end of the level.

const FONT = preload("res://Pixelify_Sans/static/PixelifySans-Bold.ttf")
const ART = preload("res://endscreen.png")
# The part of endscreen.png that holds the pink panel (the rest is empty)
const ART_REGION = Rect2(810, 890, 3980, 3640)
const PANEL_SIZE = Vector2(480, 440)

func _ready():
	layer = 60

	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# Dim the level behind the panel (also blocks clicks on anything below)
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var art = AtlasTexture.new()
	art.atlas = ART
	art.region = ART_REGION
	var panel = TextureRect.new()
	panel.texture = art
	panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.custom_minimum_size = PANEL_SIZE
	center.add_child(panel)

	# Restart button in the lower part of the panel, under the text
	var restart = Button.new()
	restart.text = "RESTART"
	restart.add_theme_font_override("font", FONT)
	restart.add_theme_font_size_override("font_size", 32)
	restart.custom_minimum_size = Vector2(220, 0)
	restart.anchor_left = 0.5
	restart.anchor_right = 0.5
	restart.anchor_top = 0.74
	restart.anchor_bottom = 0.74
	restart.grow_horizontal = Control.GROW_DIRECTION_BOTH
	restart.grow_vertical = Control.GROW_DIRECTION_BOTH
	restart.pressed.connect(_on_restart)
	panel.add_child(restart)
	restart.grab_focus()  # so Enter / Space restarts too

	root.modulate.a = 0.0
	create_tween().tween_property(root, "modulate:a", 1.0, 0.4)

func _on_restart():
	get_tree().reload_current_scene()
