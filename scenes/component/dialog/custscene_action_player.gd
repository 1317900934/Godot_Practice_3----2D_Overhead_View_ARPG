@icon("res://assets/npc_and_dialog/icons/cutscene_player.svg")
@tool

class_name Custscene_Action_Player
extends Custscene_Action



enum Method {DURATION, SPEED}



# 需要玩家进入的动画名称
@export var anim_name: String = "move"
# 过场结束时玩家朝向
@export_enum("up", "down", "left", "right") var finish_dir: String = "down"
# 是否拉回相机镜头到玩家
@export var reset_camera_to_player: bool = true
# 移动方式
@export var move_method: Method = Method.DURATION
# 运动时动画的差值类型
@export var transition_type: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
# 运动时动画的差值速度变化
@export var easing_method: Tween.EaseType = Tween.EaseType.EASE_IN_OUT

# 移动时间
@export_range(0.0, 10, 0.05, "s") var move_duration: float = 0.5
# 移动速度
@export_range(10, 1000, 1, "px/s") var move_speed: float = 300
# 动画播放速度
@export var anim_speed_factor: float = 200.0
# 是否调整动画播放速度
@export var scale_anim_speed: bool = false



var start_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var move_dir: Vector2 = Vector2.ZERO
var distance_to_target: float = 0






func _ready() -> void:
	target_pos = global_position







func play():
	
	var player: Player = PlayerManager.player
	
	var camera: Camera2D = get_viewport().get_camera_2d()
	camera.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 获取玩家当前位置
	start_pos = player.global_position
	# 获取目标距离和方向
	distance_to_target = start_pos.distance_to(target_pos)
	move_dir = start_pos.direction_to(target_pos)
	
	player.move_direction = move_dir
	player.set_direction()
	player.update_animation(anim_name)
	
	if reset_camera_to_player:
		PlayerManager.reset_camera_on_player()
	
	
	# 如果是移速模式，就计算移动时间，否则计算移动速度
	if move_method == Method.SPEED:
		move_duration = distance_to_target / move_speed
	else:
		move_speed = distance_to_target / move_duration
	
	
	if scale_anim_speed:
		var anim_speed_scale: float = move_speed / anim_speed_factor
		player.animation_player.speed_scale = anim_speed_scale
	
	
	
	var tween: Tween = create_tween()
	# 根据设置开始活动
	tween.set_ease(easing_method)
	tween.set_trans(transition_type)
	tween.tween_property(player, "global_position", target_pos, move_duration)
	tween.tween_callback(_on_tween_finished)
	







func _on_tween_finished():
	var player: Player = PlayerManager.player
	player.animation_player.speed_scale = 1.0
	player.move_direction = get_facing_direction()
	player.set_direction()
	player.update_animation("idle")
	
	
	finished.emit()







func get_facing_direction() -> Vector2:
	match finish_dir:
		"up":
			return Vector2.UP
		
		"down":
			return Vector2.DOWN
		
		"left":
			return Vector2.LEFT
		
		"right":
			return Vector2.RIGHT
		
		_:
			return Vector2.DOWN









func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 3, Color(0.085, 0.406, 0.171, 1.0))
		draw_circle(Vector2.ZERO, 10, Color(0.08, 0.422, 0.257, 0.837) , false, 1.0)
