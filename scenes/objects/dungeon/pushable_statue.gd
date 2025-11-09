class_name Pushable_Statue
extends RigidBody2D


@export var push_speed: float = 50.0
@export var persistent: bool = false
@export var persistent_location: Vector2 = Vector2.ZERO
@export var target_loaction_size: Vector2 = Vector2(7, 7)


var push_direction: Vector2 = Vector2.ZERO: set = _set_push
var target_state: bool = false

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var on_target: Persistent_Data_Handler = $On_Target





func _ready() -> void:
	# 如果有持久数据值，就读取数据中的位置
	if on_target.data_value == true:
		position = persistent_location






func _physics_process(_delta: float) -> void:
	# 线性速度 = 推动方向 * 推动速度
	linear_velocity = push_direction * push_speed
	
	if persistent:
		var x_is_on: bool = abs(position.x - persistent_location.x) < 14 + target_loaction_size.x
		var y_is_on: bool = abs(position.y - persistent_location.y) < 7 + target_loaction_size.y
		
		if x_is_on and y_is_on and target_state == false:
			target_state = true
			on_target.set_value()
		elif (x_is_on == false or y_is_on == false) and target_state == true:
			target_state = false
			on_target.remove_value()






func _set_push(value: Vector2):
	push_direction = value
	
	if push_direction == Vector2.ZERO:
		audio_player.stop()
	else:
		audio_player.play()
