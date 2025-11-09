@tool
class_name Patrol_Location
extends Node2D



signal transform_changed





@export var wait_time: float = 0.0:
	set(v):
		wait_time = v
		_update_wait_time_label()


# 目标点位置
var target_pos: Vector2 = Vector2.ZERO





# 节点进入场景树时，使其全局变换发生改变时发出一个提示
func _enter_tree() -> void:
	set_notify_transform(true)





# 收到全局变换发生改变的提示时发射信号
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		transform_changed.emit()








func _ready() -> void:
	target_pos = global_position
	_update_wait_time_label()
	
	if Engine.is_editor_hint():
		return
	
	$Sprite2D.queue_free()





# 更新巡逻点标签
func update_label(_text: String):
	$Sprite2D/Label.text = _text





# 更新巡逻路线
func update_line(next_location: Vector2):
	var line: Line2D = $Sprite2D/Line2D
	
	line.points[1] = next_location - position







# 更新等待时间标签
func _update_wait_time_label():
	if Engine.is_editor_hint():
		$Sprite2D/Label2.text = "停留: " + str(snappedf(wait_time, 0.01)) + "秒"
