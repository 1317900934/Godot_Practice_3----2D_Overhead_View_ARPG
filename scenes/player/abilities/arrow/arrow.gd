class_name Arrow
extends Node2D


@export var move_speed: float = 300.0

@export var fire_audio: AudioStream



var move_dir: Vector2 = Vector2.RIGHT


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2
@onready var hit_box: Hit_Box = $Hit_Box
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D



func _ready() -> void:
	hit_box.did_damage.connect(_on_did_damage)
	get_tree().create_timer(5.0).timeout.connect(_on_timeout)
	if fire_audio:
		audio_player.stream = fire_audio
		audio_player.play()






func _process(delta: float) -> void:
	position += move_dir * move_speed * delta






func fire(fire_dir: Vector2):
	move_dir = fire_dir
	rotate_nodes()





func rotate_nodes():
	var angle: float = move_dir.angle()
	sprite_2d.rotation = angle
	sprite_2d_2.rotation = angle
	hit_box.rotation = angle







func _on_did_damage():
	queue_free()





func _on_timeout():
	queue_free()
