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
	await fly.finished
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_quit():
	get_tree().quit()
