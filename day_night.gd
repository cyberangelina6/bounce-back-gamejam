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
}

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

func set_night(on: bool, time := 0.6):
	if fade:
		fade.kill()
	fade = create_tween()
	fade.tween_method(_apply, amount, 1.0 if on else 0.0, time)

func _apply(value: float):
	amount = value
	for pair in pairs:
		pair[0].self_modulate.a = 1.0 - value  # fades the day art only
		pair[1].modulate.a = value

func _process(_delta):
	# Keep the night art facing the same way as the day art (the bunny flips)
	for pair in pairs:
		pair[1].flip_h = pair[0].flip_h
		pair[1].flip_v = pair[0].flip_v
