class_name Notification_UI
extends Control


var notification_queue: Array

@onready var panel_container: PanelContainer = $PanelContainer
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var title_label: Label = $PanelContainer/VBoxContainer/Label
@onready var message_label: Label = $PanelContainer/VBoxContainer/Label2


func _ready() -> void:
	panel_container.visible = false
	anim_player.animation_finished.connect(notification_anim_finished)





# 添加一个通知内容到队列
func add_notification_to_queue(_title: String, _message: String):
	notification_queue.append({
		title = _title,
		message = _message
	})
	
	if anim_player.is_playing():
		return
	
	display_notification()





# 显示通知
func display_notification():
	# 获取并移除通知数组中的第一个通知内容
	var _n = notification_queue.pop_front()
	
	if _n == null:
		return
	
	title_label.text = _n.title
	message_label.text = _n.message
	anim_player.play("show_notification")




# 通知消息结束
func notification_anim_finished(_anim: String):
	display_notification()
