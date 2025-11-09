class_name Pressure_Plate
extends Node2D



signal activated
signal deactivated


# 踩上去的物体个数
var bodies: int = 0
# 是否激活
var is_active: bool = false
# 压力板关闭时的图像偏移区域值
var off_rect: Rect2




@onready var activate_area: Area2D = $Area2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var activate_audio: AudioStream = preload("res://assets/audio/lever-01.wav")
@onready var deactivate_audio: AudioStream = preload("res://assets/audio/lever-02.wav")
@onready var sprite: Sprite2D = $Sprite2D




func _ready() -> void:
	
	activate_area.body_entered.connect(_on_body_entered)
	activate_area.body_exited.connect(_on_body_exited)
	# 存储压力板关闭时的图像偏移区域值
	off_rect = sprite.region_rect




func _on_body_entered(_b: Node2D):
	
	bodies += 1
	check_is_activated()



func _on_body_exited(_b: Node2D):
	
	bodies -= 1
	check_is_activated()



func check_is_activated():
	
	if bodies > 0 and is_active == false:
		is_active = true
		play_audio(activate_audio)
		sprite.region_rect.position.x = off_rect.position.x - 32
		activated.emit()
		
	elif bodies <= 0 and is_active == true:
		is_active = false
		play_audio(deactivate_audio)
		sprite.region_rect.position.x = off_rect.position.x
		deactivated.emit()



func play_audio(_stream: AudioStream):
	audio_player.stream = _stream
	audio_player.play()
