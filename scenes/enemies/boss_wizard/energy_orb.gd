class_name Energy_Orb
extends Node2D


@export var speed: float = 100
@export var shoot_audio: AudioStream
@export var hit_audio: AudioStream



var direction: Vector2 = Vector2.DOWN


@onready var hit_box: Hit_Box = $Hit_Box
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: Sprite2D = $Sprite2D





func _ready() -> void:
	hit_box.did_damage.connect(hit_player)
	play_audio(shoot_audio)
	get_tree().create_timer(4.0).timeout.connect(destroy)
	direction = global_position.direction_to(PlayerManager.player.global_position)
	flicker()





func _process(delta: float) -> void:
	position += direction * speed * delta





func flicker():
	modulate.a = randf() * 0.5 + 0.5
	await get_tree().create_timer(0.1).timeout
	flicker()






func hit_player():
	play_audio(hit_audio)
	destroy()
	





func play_audio(_audio: AudioStream):
	audio_player.stream = _audio
	audio_player.play()




func destroy():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:a", 0, 0.1)
	await tween.finished
	queue_free()
