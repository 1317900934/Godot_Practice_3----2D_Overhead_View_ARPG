@icon("res://assets/npc_and_dialog/icons/cutscene_actor.svg")
@tool

class_name Custscene_Action_Move
extends Custscene_Action



enum Method {DURATION, SPEED}


# 移动方式
@export var move_method: Method = Method.DURATION
# 要进行移动的对象
@export var object_to_move: Node2D
# 运动时动画的差值类型
@export var transition_type: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
# 运动时动画的差值速度变化
@export var easing_method: Tween.EaseType = Tween.EaseType.EASE_IN_OUT

# 移动时间
@export_range(0.0, 10, 0.05, "s") var move_duration: float = 0.5
# 移动速度
@export_range(10, 1000, 1, "px/s") var move_speed: float = 300
# 动画播放速度
@export var anim_speed_factor: float = 40.0



var target_pos: Vector2 = Vector2.ZERO
var move_dir: Vector2 = Vector2.ZERO
var distance_to_target: float = 0






func _ready() -> void:
	target_pos = global_position







func play():
	if object_to_move:
		object_to_move.process_mode = Node.PROCESS_MODE_ALWAYS
		# 获取目标距离和移动方向
		distance_to_target = calculate_distance_to_target()
		get_move_dir()
		
		# 如果是移速模式，就计算移动时间，否则计算移动速度
		if move_method == Method.SPEED:
			move_duration = distance_to_target / move_speed
		else:
			move_speed = distance_to_target / move_duration
		
		# 如果移动对象是NPC，就使其播放对应的行走动画
		if object_to_move is NPC:
			var npc: NPC = object_to_move
			npc.do_behavior = false
			npc.state = "walk"
			npc.direction = move_dir
			npc.update_dir(target_pos)
			npc.update_anim()
			npc.anim_player.speed_scale = move_speed / anim_speed_factor * 0.3
		
		
		
		var tween: Tween = create_tween()
		# 根据设置开始活动
		tween.set_ease(easing_method)
		tween.set_trans(transition_type)
		tween.tween_property(object_to_move, "global_position", target_pos, move_duration)
		tween.tween_callback(_on_tween_finished)
		
		
	else:
		finished.emit()






func _on_tween_finished():
	object_to_move.process_mode = Node.PROCESS_MODE_INHERIT
	
	# 如果移动对象是NPC，就使其播放对应的行走动画
	if object_to_move is NPC:
		var npc: NPC = object_to_move
		npc.do_behavior = true
		npc.state = "idle"
		npc.anim_player.speed_scale = 1
		npc.do_behavior_on.emit()
		npc.process_mode = Node.PROCESS_MODE_INHERIT
	
	finished.emit()








# 获取移动方向
func get_move_dir():
	if object_to_move:
		move_dir = object_to_move.global_position.direction_to(target_pos)







# 计算目标距离
func calculate_distance_to_target() -> float:
	return object_to_move.global_position.distance_to(target_pos)









func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 3, Color(0.592, 0.174, 0.021, 1.0))
		draw_circle(Vector2.ZERO, 10, Color(0.568, 0.252, 0.116, 0.837), false, 1.0)
