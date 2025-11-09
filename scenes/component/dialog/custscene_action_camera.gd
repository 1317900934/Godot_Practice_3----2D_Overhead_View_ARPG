@icon("res://assets/npc_and_dialog/icons/cutscene_camera.svg")
@tool

class_name Custscene_Action_Camera
extends Custscene_Action



enum Method {DURATION, SEPPD}


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



var camera: Camera2D
var start_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var distance_to_target: float = 0






func _ready() -> void:
	target_pos = global_position







func play():
	
	camera = get_viewport().get_camera_2d()
	
	if camera:
		camera.process_mode = Node.PROCESS_MODE_ALWAYS
		# 获取需要移动到的目标位置
		start_pos = camera.global_position
		distance_to_target = start_pos.distance_to(target_pos)
		
		# 创建并设置相机需要跟随的定位点到玩家同层级
		var follow_node: Node2D = Node2D.new()
		PlayerManager.player.add_sibling(follow_node)
		follow_node.global_position = start_pos
		
		# 将定位点设置为相机的父节点
		camera.reparent(follow_node)
		
		# 如果是移速模式，就计算移动时间，否则计算移动速度
		if move_method == Method.SEPPD:
			move_duration = distance_to_target / move_speed
		else:
			move_speed = distance_to_target / move_duration
		
		
		var tween: Tween = create_tween()
		# 根据设置开始活动
		tween.set_ease(easing_method)
		tween.set_trans(transition_type)
		tween.tween_property(follow_node, "global_position", target_pos, move_duration)
		tween.tween_callback(_on_tween_finished)
		
		
	else:
		finished.emit()






func _on_tween_finished():
	
	
	finished.emit()










func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 3, Color(0.07, 0.437, 0.846, 1.0))
		draw_circle(Vector2.ZERO, 10, Color(0.303, 0.336, 0.681, 0.906), false, 1.0)
