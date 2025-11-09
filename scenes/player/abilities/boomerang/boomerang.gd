class_name Boomerang
extends Node2D



enum State {INACTIVE, THROW, RETURN}


# 玩家引用
var player: Player
# 飞行方向
var direction: Vector2
# 当前速度
var speed: float = 0
# 当前状态
var current_state


# 加速度
@export var acceleration: float = 500.0
# 最大速度
@export var max_speed: float = 500.0
# 回旋镖扔出和收回的音效
@export var catch_audio: AudioStream



@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D






func _ready() -> void:
	
	visible = false
	current_state = State.INACTIVE
	player = PlayerManager.player







func _physics_process(delta: float) -> void:
	
	if current_state == State.THROW:
		# 根据不断减少的速度移动其位置
		speed -= acceleration * delta
		position += direction * speed * delta
		# 速度为0时，进入返回状态
		if speed <= 0:
			current_state = State.RETURN
		
	elif current_state == State.RETURN:
		# 将返回方向锁定为朝向玩家的方向
		direction = global_position.direction_to(player.global_position + Vector2(0, -10))
		# 根据不断增加的速度移动其位置
		speed += acceleration * delta
		position += direction * speed * delta
		# 如果回旋镖的位置与玩家的距离小于10，就销毁回旋镖
		if global_position.distance_to(player.global_position + Vector2(0, -10)) <= 10:
			PlayerManager.play_audio(catch_audio)
			queue_free()
	
	# 根据移动速度比率调整音效的音调和动画播放速度
	var speed_ratio = speed / max_speed
	audio_player.pitch_scale = speed_ratio * 0.7 + 0.6
	animation_player.speed_scale = speed_ratio * 0.7 + 0.6





# 扔出回旋镖
func throw(throw_dir: Vector2):
	
	direction = throw_dir
	speed = max_speed
	current_state = State.THROW
	animation_player.play("boomerang")
	PlayerManager.play_audio(catch_audio)
	visible = true
