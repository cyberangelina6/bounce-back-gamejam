extends Node
# Crossfades every sprite in the level between its day and night art.
# Created by the player script; nothing needs to be added to the scene.

# day texture -> night texture. Add a line here for any new art.
const NIGHT_ART = {
	"res://skybg.png": "res://skybgnight.png",
	"res://dayclouds.png": "res://nightclouds.png",
	"res://dayblock.png": "res://nightblock2.png",
	"res://dayblock (2).png": "res://nightblock2.png",
	"res://dayportal.png": "res://nightportal.png",
	"res://daybunny_static1.png": "res://nightbunny_static.png",
	"res://daybunny_jump.png": "res://nightbunny_jump.png",
	"res://daybunny_walk.png": "res://nightbunny_walk.png",
}

const BANNER_FONT = preload("res://Pixelify_Sans/static/PixelifySans-Bold.ttf")

var banner: Label
var banner_tween: Tween
var pairs = []  # [day sprite, night sprite laid over it]
var amount = 0.0  # 0 = day, 1 = night
var fade: Tween

# Finds every sprite under `level` that has night art and lays the night
# version over it, invisible until set_night(true).
func setup(level: Node):
	for day in level.find_children("*", "Sprite2D", true, false):
		if day.texture == null or not NIGHT_ART.has(day.texture.resource_path):
			continue
		var night = Sprite2D.new()
		night.texture = load(NIGHT_ART[day.texture.resource_path])
		night.centered = day.centered
		night.offset = day.offset
		# Cover exactly the same area even if the night image is a different size
		night.scale = day.texture.get_size() / night.texture.get_size()
		night.modulate.a = 0.0
		day.add_child(night)
		pairs.append([day, night])

	# Animated sprites: build a night copy of every animation that has night art
	for day in level.find_children("*", "AnimatedSprite2D", true, false):
		var night_frames = _night_frames(day.sprite_frames)
		if night_frames == null:
			continue
		var night = AnimatedSprite2D.new()
		night.sprite_frames = night_frames
		night.centered = day.centered
		night.offset = day.offset
		night.modulate.a = 0.0
		day.add_child(night)
		pairs.append([day, night])

# Copies a SpriteFrames, swapping each frame's sheet for its night version.
# Frames keep the same region, so day and night sheets must share a layout.
# Returns null if none of the frames have night art.
func _night_frames(day_frames: SpriteFrames) -> SpriteFrames:
	if day_frames == null:
		return null
	var frames = day_frames.duplicate()
	var swapped = false
	for anim in frames.get_animation_names():
		for i in frames.get_frame_count(anim):
			var tex = frames.get_frame_texture(anim, i)
			var night_tex = null
			if tex is AtlasTexture and tex.atlas and NIGHT_ART.has(tex.atlas.resource_path):
				night_tex = tex.duplicate()
				night_tex.atlas = load(NIGHT_ART[tex.atlas.resource_path])
			elif tex and NIGHT_ART.has(tex.resource_path):
				night_tex = load(NIGHT_ART[tex.resource_path])
			if night_tex:
				frames.set_frame(anim, i, night_tex, frames.get_frame_duration(anim, i))
				swapped = true
	return frames if swapped else null

func set_night(on: bool, time := 0.6):
	if fade:
		fade.kill()
	fade = create_tween()
	fade.tween_method(_apply, amount, 1.0 if on else 0.0, time)
	_show_banner("NIGHT BOUNCE!" if on else "DAY BOUNCE!", on)

# Pops the mode name up in the middle of the screen, then fades it out.
# It sits on its own CanvasLayer so it stays upright when the view flips.
func _show_banner(text: String, night: bool):
	if banner == null:
		var layer = CanvasLayer.new()
		layer.layer = 50
		add_child(layer)
		banner = Label.new()
		banner.add_theme_font_override("font", BANNER_FONT)
		banner.add_theme_font_size_override("font_size", 110)
		banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		banner.set_anchors_preset(Control.PRESET_FULL_RECT)
		banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(banner)
	banner.text = text
	# Pale text at night, dark blue by day
	banner.add_theme_color_override("font_color", Color("f3e9ff") if night else Color("45658a"))
	banner.modulate.a = 0.0
	if banner_tween:
		banner_tween.kill()
	banner_tween = create_tween()
	banner_tween.tween_property(banner, "modulate:a", 1.0, 0.15)
	banner_tween.tween_interval(0.4)
	banner_tween.tween_property(banner, "modulate:a", 0.0, 0.3)

func _apply(value: float):
	amount = value
	for pair in pairs:
		pair[0].self_modulate.a = 1.0 - value  # fades the day art only
		pair[1].modulate.a = value

func _process(_delta):
	# Keep the night art facing the same way as the day art (the bunny flips)
	# and, for animated sprites, on the same animation frame
	for pair in pairs:
		pair[1].flip_h = pair[0].flip_h
		pair[1].flip_v = pair[0].flip_v
		if pair[0] is AnimatedSprite2D:
			pair[1].animation = pair[0].animation
			pair[1].frame = pair[0].frame
