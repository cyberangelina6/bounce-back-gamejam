extends Control

@onready var scenery = $Scenery
@onready var bunny = $Bunny

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit)

func _on_play():
	$VBoxContainer/PlayButton.disabled = true
	$VBoxContainer/QuitButton.disabled = true
	var tween = create_tween().set_parallel(true)
	tween.tween_property($VBoxContainer, "modulate:a", 0.0, 0.5)
	tween.tween_property(bunny, "position", Vector2(576, 324), 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(scenery, "position:y", scenery.position.y + 900.0, 1.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	var fly = create_tween()
	fly.tween_property(bunny, "position:y", -300.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_white_fade_to("res://level1.tscn")

# Fades the screen to white, swaps the scene, then fades the white away.
# The overlay lives on the root window so it survives the scene change.
func _white_fade_to(scene_path: String, fade_in := 1.0, fade_out := 0.8):
	var layer = CanvasLayer.new()
	layer.layer = 100
	var white = ColorRect.new()
	white.color = Color(1, 1, 1, 0)
	white.set_anchors_preset(Control.PRESET_FULL_RECT)
	white.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(white)
	get_tree().root.add_child(layer)
	var t = layer.create_tween()
	t.tween_property(white, "color:a", 1.0, fade_in)
	t.tween_callback(get_tree().change_scene_to_file.bind(scene_path))
	t.tween_interval(0.15)
	t.tween_property(white, "color:a", 0.0, fade_out)
	t.tween_callback(layer.queue_free)

func _on_quit():
	get_tree().quit()
